# frozen_string_literal: true

# A class that controls the logic of closure execution in the context of other objects.
# Responsible for dispatching the methods which should be executed in a certain context.
# Delegation variations depends on the order of contexts.
#
# Trigger supports 3 contexts:
#
# * closure context;
# * passed object's context (or context of the each passed object);
# * global ::Kernel context.
#
# If no context is able to respond to the required method - ContextNoMethodError exception is raised
# (ContextNoMethodError inherits from NoMethodError).
#
# @api private
# @since 0.1.0
class Symbiont::Trigger < BasicObject
  # Indicates the direction of context method resolving algorithm.
  # Direction: initial context => outer context => kernel context.
  #
  # @return [Array<Symbol>]
  #
  # @api public
  # @since 0.1.0
  IOK = %i[__inner_contexts__ __outer_context__ __kernel_context__].freeze

  # Indicates the direction of context method resolving algorithm.
  # Direction: outer context => initial contexts => kernel context.
  #
  # @return [Array<Symbol>]
  #
  # @api public
  # @since 0.1.0
  OIK = %i[__outer_context__ __inner_contexts__ __kernel_context__].freeze

  # Indicates the direction of context method resolving algorithm.
  # Direction: outer context => kernel context => initial contexts.
  #
  # @return [Array<Symbol>]
  #
  # @api public
  # @since 0.1.0
  OKI = %i[__outer_context__ __kernel_context__ __inner_contexts__].freeze

  # Indicates the direction of context method resolving algorithm.
  # Direction: initial contexts => kernel context => outer context.
  #
  # @return [Array<Symbol>]
  #
  # @api public
  # @since 0.1.0
  IKO = %i[__inner_contexts__ __kernel_context__ __outer_context__].freeze

  # Indicates the direction of context method resolving algorithm.
  # Direction: kernel context => outer context => initial contexts.
  #
  # @return [Array<Symbol>]
  #
  # @api public
  # @since 0.1.0
  KOI = %i[__kernel_context__ __outer_context__ __inner_contexts__].freeze

  # Indicates the direction of context method resolving algorithm.
  # Direction: kernel context => initial contexts => outer context.
  #
  # @return [Array<Symbol>]
  #
  # api public
  # @since 0.1.0
  KIO = %i[__kernel_context__ __inner_contexts__ __outer_context__].freeze

  # Is raised when chosen direction (__context_direction__ instance attribute) is not supported
  # by a trigger. Supports only: OIK, OKI, IOK, IKO, KOI, KIO.
  #
  # @api public
  # @since 0.1.0
  IncompatibleContextDirectionError = ::Class.new(::ArgumentError)

  # Is raised when closure isnt passed.
  #
  # @api public
  # @since 0.2.0
  UnprovidedClosureAttributeError = ::Class.new(::ArgumentError)

  # Is raised when no one is able to respond to the required method.
  #
  # @see #__actual_context__
  #
  # @api public
  # @since 0.1.0
  ContextNoMethodError = ::Class.new(::NoMethodError)

  # Returns a set of objects that should be used as the main context series for
  # context method resolving algorithm. The order of object selection depends on
  # their order in a set.
  #
  # @return [Array<Object>]
  #
  # @since 0.1.0
  attr_reader :__inner_contexts__

  # Returns a binding object of corresponding closure (see __closure__).
  # Used as an outer context for context method resolving algorithm.
  #
  # @return [Object]
  #
  # @api private
  # @since 0.1.0
  attr_reader :__outer_context__

  # Returns Kernel object that will be used as Kernel context for
  # context method resolving algorithm.
  #
  # @return [::Kernel]
  #
  # @api private
  # @since 0.1.0
  attr_reader :__kernel_context__

  # Returns proc object that will be triggered in many contexts: initial, outer and kernel.
  #
  # @return [Proc]
  #
  # @api private
  # @since 0.1.0
  attr_reader :__closure__

  # Returns an array of symbols that represents the direction of contexts.
  # that represents an access method to each of them.
  #
  # @return [Array<Symbol>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :__context_direction__

  # Instantiates trigger object with corresponding initial contexts, closure and context resolving
  # direction.
  #
  # @param initial_contexts [Array<Object>]
  #   A set of main context objects which should be used for instance_eval on.
  #   An order of object selection depends on oredr which they are passed.
  # @param closure [Proc]
  #   closure that will be executed in a set of contexts (initial => outer => kernel by default).
  #   An actual context (#__actual_context__) will be passed to a closure as an attribute.
  # @raise UnprovidedClosureAttributeError
  #   Raises when closure attribte isnt passed.
  # @raise IncompatibleContextDirectionError
  #   Is raised when chosen direction is not supported by a trigger.
  #   Supports only OIK, OKI, IOK, IKO, KOI, KIO (see corresponding constant value above).
  #
  # @api private
  # @since 0.1.0
  def initialize(*initial_contexts, context_direction: IOK, &closure)
    # :nocov:
    unless ::Kernel.block_given?
      ::Kernel.raise(UnprovidedClosureAttributeError, 'block attribute should be provided')
    end
    # :nocov:

    # rubocop:disable Layout/SpaceAroundKeyword
    unless(context_direction == IOK || context_direction == OIK || context_direction == OKI ||
           context_direction == IKO || context_direction == KOI || context_direction == KIO)
      ::Kernel.raise(
        IncompatibleContextDirectionError,
        'Incompatible context direction attribute. ' \
        'You should use one of this: OIK, OKI, IOK, IKO, KOI, KIO.'
      )
    end
    # rubocop:enable Layout/SpaceAroundKeyword

    @__closure__           = closure
    @__context_direction__ = context_direction
    @__inner_contexts__    = initial_contexts
    @__outer_context__     = ::Kernel.eval('self', closure.binding)
    @__kernel_context__    = ::Kernel
  end

  # Triggers a closure in multiple contexts.
  #
  # @return void
  #
  # @see #method_missing
  #
  # @api private
  # @since 0.1.0
  def __evaluate__
    instance_eval(&__closure__)
  end

  # Returns a collection of the all contexts sorted by chosen direction.
  # Represents ordered single-dimentional array of objects (contexts).
  #
  # @return [Array<Object>]
  #
  # @see #__context_direction__
  #
  # @api private
  # @since 0.1.0
  def __directed_contexts__
    __context_direction__.map { |direction| __send__(direction) }.flatten
  end

  # Returns the first context that is able to respond to the required method.
  # The context is chosen in the context direction order (see #__context_direction__).
  # Raises NoMethodError excepition when no one of the contexts are able to respond to
  # the required method.
  # Basicaly, abstract implementation raises NoMethodError.
  #
  # @param method_name [Symbol,String] Method that a context should respond to.
  # @raise ContextNoMethodError
  #
  # @see #__context_direction__
  #
  # @api private
  # @since 0.1.0
  def __actual_context__(method_name)
    ::Kernel.raise ContextNoMethodError, "No one is able to respond to #{method_name}"
  end

  # Delegates method invocation to the corresponding actual context.
  #
  # @param method_name [String,Symbol] Method name
  # @param arguments [Mixed] Method arguments
  # @param block [Proc] Block
  # @raise ContextNoMethodError
  #   Is rased when no one of the contexts are able to respond tothe required method.
  # @return void
  #
  # @see #__actual_context__
  #
  # @api private
  # @since 0.1.0
  def method_missing(method_name, *arguments, &block)
    __actual_context__(method_name).__send__(method_name, *arguments, &block)
  end

  # Checks that the actual context is able to respond to a required method.
  #
  # @param method_name [String,Symbol] Method name
  # @param _include_private [Boolean] Include private methods
  # @raise NoMethodError
  #   Is raised when no one of the contexts are able to respond to the required method.
  # @return [Boolean] Is the actual context able to respond to the required method.
  #
  # @see #method_missing
  # @see #__actual_context__
  #
  # @api private
  # @since 0.1.0
  # :nocov:
  def respond_to_missing?(method_name, _include_private = false)
    !!__actual_context__(method_name)
  end
  # :nocov:

  # Should return a corresponding method object of the actual context.
  #
  # @param method_name [String,Symbol] Method name
  # @raise ContextNoMethodError
  #   Is raised when no one of the contexts able to respond to the required method.
  # @return [Method]
  #
  # @see #method_missing
  # @see #respond_to_missing?
  # @see #__actual_context__
  #
  # @see [Symbiont::PrivateTrigget#method]
  # @see [Symbiont::PublicTrigger#method]
  #
  # @api private
  # @since 0.1.0
  def method(method_name); end # :nocov:

  # Returns an internal singleton object of the passed object.
  #
  # @param object [Any] Extractable object
  # @return [Class] Singleton class of the passed object
  #
  # @api private
  # @sionce 0.5.0
  def __extract_singleton_class__(object)
    # NOTE: `<<` approach is used cuz BasicObject does not support #singleton_class method.
    class << object; self; end
  end
end
