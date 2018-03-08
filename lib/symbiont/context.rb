# frozen_string_literal: true

module Symbiont
  class << self
    # Factory method for a mixin module that provides an ability to invoke procs and lambdas
    # in many contexts to any object. Mixes up special methods that delegate execution logic to
    # to a special mediator object (Symbiont::Executor).
    #
    # @param default_context_direction [Array<Symbol>] Delegation order.
    # @return [Module]
    #
    # @see Symbiont::Executor
    # @see Symbiont::Trigger
    # @see Symbiont::PublicTrigger
    # @see Symbiont::PrivateTrigger
    #
    # @api public
    # @since 0.1.0
    #
    # rubocop:disable Naming/MethodName, Metrics/LineLength
    def Context(default_context_direction = Trigger::IOK)
      Module.new do
        define_method :evaluate do |context_direction = default_context_direction, &closure|
          Executor.evaluate(self, context_direction, &closure)
        end

        define_method :evaluate_private do |context_direction = default_context_direction, &closure|
          Executor.evaluate_private(self, context_direction, &closure)
        end

        define_method :public_method do |method_name, context_direction = default_context_direction, &closure|
          Executor.public_method(self, method_name, context_direction, &closure)
        end

        define_method :private_method do |method_name, context_direction = default_context_direction, &closure|
          Executor.private_method(self, method_name, context_direction, &closure)
        end
      end
    end
    # rubocop:enable Naming/MethodName, Metrics/LineLength
  end

  # @see Symbiont.Context
  #
  # @api public
  # @since 0.1.0
  Context = Context()
end
