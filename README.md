<p align="center"><img width="250" height="250" src="logo/symbiont_logo_circle.png" /></div>
<p align="center">
  <h1 align="center">
    Symbiont<br />
    <a href="https://badge.fury.io/rb/symbiont-ruby"><img src="https://badge.fury.io/rb/symbiont-ruby.svg"></a>
    <a href="https://travis-ci.org/0exp/symbiont-ruby"><img src="https://travis-ci.org/0exp/symbiont-ruby.svg?branch=master"></a>
    <a href="https://coveralls.io/github/0exp/symbiont-ruby?branch=master"><img src="https://coveralls.io/repos/github/0exp/symbiont-ruby/badge.svg?branch=master"></a>
  </h1>
</p>

**Symbiont** is a cool implementation of proc-objects execution algorithm: in the context of other object,
but with the preservation of the closed environment of the proc object and with the ability of control the method dispatch
inside it. A proc object is executed in three contexts: in the context of required object, in the context of
a closed proc's environment and in the global (Kernel) context.

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'symbiont-ruby'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install symbiont-ruby
```

After all:

```ruby
require 'symbiont'
```

# Table of contents

- [Problem and motivation](#problems-and-motivaiton)
- [Usage](#usage)
  - [Context management](#context-management)
  - [Supported method delegation directions](#supported-methods-delegation-directions)
  - [Proc object invokation](#proc-object-invokation)
    - [Considering public methods only (.evaluate)](#considering-public-methods-only-evaluate)
    - [Considering private and public methods (.evaluate_private)](#considering-private-and-public-methods-evaluate_private)
  - [Getting method-objects (Method)](#getting-method-objects-method)
    - [Considering public methods only (.public_method)](#considering-public-methods-only-public_method)
    - [Considering public and private methods (.private_method)](#considering-public-and-private-methods-private_method)
  - [Symbiont Mixin](#symbiont-mixin)
    - [Mixing a module with default delegation direction](#mixing-a-module-with-default-delegation-direction)
    - [Mixing a module with certain delegation direction](#mixing-a-module-with-certain-delegation-direction)
  - [Multiple inner contexts](#multiple-inner-contexts)
  - [Isolator - proc object isolation layer for delayed invocations](#isolator---proc-object-isolation-layer-for-delayed-invocations)

# Problems and motivaiton

The main problem of `instance_eval` / `instance exec` / `class_eval` / `class_exec` is that the binding (self)
inside a proc-objec is replaced with the object in where a proc object is executed. This allows you to delegate all methods closed by a proc to another object.
But this leads to the fact that the proc object loses access to the original closed environment.
Symbiont solves this problem by allowing to proc to be executed in the required context while maintaining access to the methods of the closed environemnt
(including the global context).

---

A prroblem with `instance_eval` / `instance_exec` / `class_eval` / `class_exec`:

```ruby
class TableFactory
  def initialize
    @primary_key = nil
  end

  def primary_key(key)
    @primary_key = key
  end
end

class Migration
  class << self
    def create_table(&block)
      TableFactory.new.tap do |table|
        table.instance_eval(&block) # NOTE: closure invokation
      end
    end
  end
end

class CreateUsers < Migration
  class << self
    def up
      create_table do # NOTE: failing closure
        primary_key(generate_pk(:id))
      end
    end

    def generate_pk(name)
      "secure_#{name}"
    end
  end
end

CreateUsers.up
# => NoMethodError: undefined method `generate_pk' for #<TableFactory:0x00007f8560ca4a58>
```

Symbiont solves this:

```ruby
require 'symbiont'

class Migration
  class << self
    def create_table(&block)
      TableFactory.new.tap do |table|
        Symbiont::Executor.evaluate(table, &block) # NOTE: intercept closure invokation by Symbiont
      end
    end
  end
end

CreateUsers.up
# => #<TableFactory:0x00007f990527f268 @primary_key="secure_id">
```

---

Proc-object is executed in three contexts at the same time:

- in the context of closure;
- in the context of required object;
- in the global context (Kernel).

Methods (called internally) are delegated to the context that is first able to respond.
The order of context selection depends on the corresponding context direction parameter.
By default the delegation order is: object context => closure context => global context.
If no context is able to respond to the method, an exception is thrown (`Symbiont::Trigger::ContextNoMethodError`).
Symbiont can consider the visiblity of methods when executing.


# Usage

## Context management

Imagine that in a real application we have the following gode and the corresponding closure:

```ruby
def object_data
  'outer_context'
end

class SimpleObject
  def format_data(data)
    "Data: #{data}"
  end

  def object_data
    'inner_context'
  end
end

class << Kernel
  def object_data
    'kernel_data'
  end
end

object = SimpleObject.new

closure = proc { format_data(object_data) } # NOTE: our closure
```

How a proc object will be processed, which context will be selected, how to make sure that nothing is broken - welcome to Symbiont.

## Supported methods delegation directions

Delegation order is set by a constant and passed as a parameter in the execution of the proc
and the generation of a special mixin module, allowing any class or instance to become a symbiont.

Supported contexts

- inner context  - an object where proc is executed;
- outer context  - external environment of the proc object;
- kernel context - global Kernel context.

Symbiont::IOK is chosen by default (`inner context => outer context => kernel context`)

```ruby
Symbiont::IOK # Inner Context  => Outer Context  => Kernel Context (DEFAULT)
Symbiont::OIK # Outer Context  => Inner Context  => Kernel Context
Symbiont::OKI # Outer Context  => Kernel Context => Inner Context
Symbiont::IKO # Inner Context  => Kernel Context => Outer Context
Symbiont::KOI # Kernel Context => Outer Context  => Inner Context
Symbiont::KIO # Kernel Context => Inner Context  => Outer Context
```

## Proc object invokation

`Symbiont::Executor` allows you to execute proc objects in two modes of the delegation:

- only public methods:
  - `evaluate(*required_contexts, [context_direction:], &closure)`
- public and private methods:
  - `evaluate_private(*required_contexts, [context_direction:], &closure)`

If no context is able to respond to the required method - `Symbiont::Trigger::ContextNoMethodError` exception is thrown.

In the case when an unsupported direction value is used - `Symbiont::Trigger::IncompatibleContextDirectionError` exception is thrown.

If proc object isnt passed to the executor - `Symbiont::Trigger::UnprovidedClosureAttributeError` exception is thrown.

#### Considering public methods only (.evaluate)

```ruby
# with default delegation order (Symbiont::IOK)
Symbiont::Executor.evaluate(object) do
  format_data(object_data)
end
# => "Data: inner_context"

# with a custom delegation order
Symbiont::Executor.evaluate(object, context_direction: Symbiont::KIO) do
  format_data(object_data)
end
# => "Data: kernel_context"

# SimpleObject#object_data is a private method (inner_context)
Symbiont::Executor.evaluate(object, context_direction: Symbiont::IOK) do
  format_data(object_data)
end
# => "Data: outer_context"
```

#### Considering private and public methods (.evaluate_private)

```ruby
# with default delegation order (Symbiont::IOK)
Symbiont::Executor.evaluate_private(object) do
  format_data(object_data)
end
# => "Data: inner_context"

# with a custom delegation order
Symbiont::Executor.evaluate_private(object, context_direction: Symbiont::KIO) do
  format_data(object_data)
end
# => "Data: kernel_context"

# SimpleObject#object_data is a private method (inner_context)
Symbiont::Executor.evaluate_private(object, context_direction: Symbiont::IOK) do
  format_data(object_data)
end
# => "Data: inner_data"
```

## Getting method-objects (Method)

`Symbiont::Executor` provides the possibility of obtaining the method object with consideration of the chosen delegation order:

- only public methods:
  - `public_method(method_name, *required_contexts, [context_direction:], &clojure)`
- public and private methods:
  - `private_method(method_name, *required_contexts, [context_direction:], &clojure)`

If no context is able to respond to the required method - `Symbiont::Trigger::ContextNoMethodError` exception is thrown.

In the case when an unsupported direction value is used - `Symbiont::Trigger::IncompatibleContextDirectionError` exception is thrown.

#### Considering public methods only (.public_method)

```ruby
# with default delegation order (Symbiont::IOK)
Symbiont::Executor.public_method(:object_data, object, &closure)
# => #<Method: SimpleObject#object_data>

# with a custom delegation order
Symbiont::Executor.public_method(:object_data, object, context_direction: Symbiont::OIK, &closure)
# => (main) #<Method: SimpleObject(object)#object_data>

# SimpleObject#object_data is a private method
Symbiont::Executor.public_method(:object_data, object, context_direction: Symbiont::IOK, &closure)
# => (main) #<Method: SimpleObject(object)#object_data>
```

#### Considering public and private methods (.private_method)

```ruby
# with default delegation order (Symbiont::IOK)
Symbiont::Executor.private_method(:object_data, object, &clojure)
# => #<Method: SimpleObject#object_data>

# with a custom delegation order
Symbiont::Executor.private_method(:object_data, object, context_direction: Symbiont::KIO, &clojure)
# => #<Method: Kernel.object_data>

# SimpleObject#object_data is a private_method
Symbiont::Executor.private_method(:object_data, object, context_direction: Symbiotn::IKO, &clojure)
# => #<Method: SimpleObject#object_data>
```

## Symbiont Mixin

`Symbiont::Context` is a mixin that allows any object to call proc objects in the context of itself as `Symbiont::Executor`.

You can specify the default direction of the context delegation. `Symbiont::IOK` is used by default.

#### Mixing a module with default delegation direction

```ruby
class SimpleObject
  include Symbiont::Context # Symbiont::IOK direction is used by default

  # #evaluate([context_direction = Symbiont::IOK], &closure)
  # #evaluate_private([context_direction = Symbiont::IOK], &closure)
  # #public_method(method_name, [context_direction = Symbiont::IOK])
  # #private_method(method_name, [context_direction = Symbiont::IOK])

  extend Symbiont::Context # Symbiont::IOK direction is used by default

  # .evaluate([context_direction = Symbiont::IOK], &closure)
  # .evaluate_private([context_direction = Symbiont::IOK], &closure)
  # .public_method(method_name, [context_direction = Symbiont::IOK])
  # .private_method(method_name, [context_direction = Symbiont::IOK])
end

def object_data
  'outer_context'
end

SimpleObject.new.evaluate { object_data }
# => object.object_data => "inner_context"

SimpleObject.new.evaluate(Symbiont::OIK) { object_data }
# => object_data() => "outer_context"
```

#### Mixing a module with certain delegation direction

```ruby
class SimpleObject
  include Symbiont::Context(Symboiont::KOI) # use a custom direction

  # #evaluate([context_direction = Symbiont::KOI], &closure)
  # #evaluate_private([context_direction = Symbiont::KOI], &closure)
  # #public_method(method_name, [context_direction = Symbiont::KOI])
  # #private_method(method_name, [context_direction = Symbiont::KOI])

  extend Symbiont::Context(Symbiont::KOI) # use a custom direction

  # .evaluate([context_direction = Symbiont::KOI], &closure)
  # .evaluate_private([context_direction = Symbiont::KOI], &closure)
  # .public_method(method_name, [context_direction = Symbiont::KOI])
  # .private_method(method_name, [context_direction = Symbiont::KOI])
end

SimpleObject.new.evaluate { object_data }
# => Kernel.object_data => "kernel_context"

SimpleObject.new.evaluate(Symbiont::IOK) { object_data }
# => object.object_data => "inner_context"
```

## Multiple inner contexts


`Symbiont::Executor` allows you to work with multiple inner contexts (can receive a set of objects instead of the one main object).
Each object will be used as an inner context in order they are passed.
The method will be addressed to the object that responds first (in accordance with a chosen delegation order).

```ruby
# Usage:

Symbiont::Executor.evaluate(object_a, object_b, context_direction: Symbiont::IOK, &closure)
Symbiont::Executor.evaluate_private(object_a, object_b, context_direction: Symbiont::IOK, &closure)
Symbiont::Executor.publc_method(:method_name, object_a, object_b, context_direction: Symbiont::IOK, &closure)
Symbiont::Executor.private_method(:method_name, object_a, object_b, context_direction: Symbiont::IOK, &closure)

# Example

object_a.info # => "object_info"
object_b.data # => "object_data"

closure = proc { "#{info} #{data}" }

Symbiont::Executor.evaluate(object_a, object_b, &closure) # => "object_info object_data"
Symbiont::Executor.public_method(:data, object_a, object_b, &closure).call # => "object_data"
Symbiont::Executor.public_method(:info, object_a, object_b, &closure).call # => "object_info"
```

## Isolator - proc object isolation layer for delayed invocations

`Symbiont::Isolator` is a special object that wraps your proc object from any place and provides
an ability to invoke this proc object lazily inside an any series of contexts.
All `Symbiont::Executor` features are supported (by the way, `Symbiont::Executor`
uses `Symbiont::Isolator` under the hood).

```ruby
# Usage:

# with default direction (Symbiont::IOK)
isolator = Symbiont::Isolator.new { call_any_method }

# with custom direction
isolator = Symbiont::Isolator.new(default_direction: Symbiont::KIO) { call_any_method }

# invocation
isolator.evaluate(object_a, object_b) # use default direction defined on instantiation
isolator.evaluate(object_a, object_b, direction: Symbiont::KOI) # use custom direction
# same for #.evaluate_private

# getting a method object
isolator.public_method(:call_any_method, object_a, object_b) # use default direction defined on instantiation
isolator.public_method(:call_any_method, object_a, object_b, direction: Symbiont::KIO) # use custom direction
isolator.private_method(...)
# same for #.private_method
```

# Contributing

- Fork it ( https://github.com/0exp/symbiont-ruby/fork )
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create new Pull Request

# License

Released under MIT License.

# Authors

[Logo](https://github.com/0exp/symbiont-ruby/tree/master/logo) was created by **Viktoria Karaulova** (my special thanks ^_^).

Project was created by **Rustam Ibragimov**.

