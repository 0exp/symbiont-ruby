# frozen_string_literal: true

module Symbiont
  # Special object that wraps your proc object from any place and provides
  # an ability to invoke this proc object lazily inside an any series of contexts.
  #
  # @api public
  # @since 0.3.0
  class Isolator
    # Is raised when closure is not provided.
    #
    # @see #initialize
    #
    # @api public
    # @since 0.3.0
    UnprovidedClosureAttributeError = Class.new(ArgumentError)

    # Instantiates isolator object with corresponding default direction and closure.
    #
    # @option default_direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts which is used as default
    #   context direction. Symbiont::Trigger::IOK is chosen by default.
    # @param closure [Proc]
    #   Proc object that will be evaluated in many contexts: initial, outer and kernel.
    #   Will be used as an outer-context for the method resolution.
    #
    # @api public
    # @since 0.3.0
    def initialize(default_direction: Trigger::IOK, &closure)
      raise UnprovidedClosureAttributeError, 'You should provide a closure' unless block_given?

      @default_direction = default_direction
      @closure = closure
    end

    # Starts execution of a proc object in the context of the passed object with the selected
    # direction of method dispatching. Delegates execution to a public trigger.
    #
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts.
    # @return [void]
    #
    # @see Symbiont::Trigger#__evaluate__
    # @see Symbiont::PublicTrigger
    #
    # @api public
    # @since 0.3.0
    def evaluate(*required_contexts, direction: default_direction)
      public_trigger(*required_contexts, direction: direction).__evaluate__
    end

    # Starts execution of a proc object in the context of the passed object with the selected
    # direction of method dispatching. Delegates execution to a private trigger.
    #
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts.
    # @return [void]
    #
    # @see Symbiont::Trigger#__evaluate__
    # @see Symbiont::PrivateTrigger
    #
    # @api public
    # @since 0.3.0
    def evaluate_private(*required_contexts, direction: default_direction)
      private_trigger(*required_contexts, direction: direction).__evaluate__
    end

    # Gets the method object taken from the context that can respond to it.
    # Considers only public methods.
    #
    # @param method_name [Symbol,String] A name of required method.
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts.
    # @return [Method]
    #
    # @see Symbiont::PublicTrigger
    # @see Symbiont::Trigger#method
    #
    # @api public
    # @since 0.3.0
    def public_method(method_name, *required_contexts, direction: default_direction)
      public_trigger(*required_contexts, direction: direction).method(method_name)
    end

    # Gets the method object taken from the context that can respond to it.
    # Considers private methods and public methods.
    #
    # @param method_name [Symbol,String] A name of required method.
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts.
    # @return [Method]
    #
    # @see Symbiont::PrivateTrigger
    # @see Symbiont::Trigger#method
    #
    # @api public
    # @since 0.3.0
    def private_method(method_name, *required_contexts, direction: default_direction)
      private_trigger(*required_contexts, direction: direction).method(method_name)
    end

    private

    # Proc object that will be evaluated in many contexts: initial, outer and kernel.
    # Will be used as an outer-context for the method resolution.
    #
    # @return [Proc]
    #
    # @api private
    # @since 0.3.0
    attr_reader :closure

    # An array of symbols that represents the direction of contexts. Used by default.
    #
    # @return [Array<Symbol>]
    #
    # @api private
    # @since 0.3.0
    attr_reader :default_direction

    # Factory method that instantiates a public trigger with the desired execution context,
    # the direction of method dispatching and the closure that needs to be performed.
    #
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts. Possible values:
    #
    #     - Symbiont::IOK
    #     - Symbiont::OIK
    #     - Symbiont::OKI
    #     - Symbiont::IKO
    #     - Symbiont::KOI
    #     - Symbiont::KIO
    # @return [Symbiont::PublicTrigger]
    #
    # @see Symbiont::PublicTrigger
    # @see Symbiont::Trigger
    #
    # @api public
    # @since 0.3.0
    def public_trigger(*required_contexts, direction: default_direction)
      PublicTrigger.new(*required_contexts, context_direction: direction, &closure)
    end

    # Factory method that instantiates a private trigger with the desired execution context,
    # the direction of method dispatching and the closure that needs to be performed.
    #
    # @param required_contexts [Array<Object>]
    #   A set of objects that should be used as the main context series for method resolving
    #   algorithm.
    # @param direction [Array<Symbol>]
    #   An array of symbols that represents the direction of contexts. Possible values:
    #
    #     - Symbiont::IOK
    #     - Symbiont::OIK
    #     - Symbiont::OKI
    #     - Symbiont::IKO
    #     - Symbiont::KOI
    #     - Symbiont::KIO
    # @return [Symbiont::PrivateTrigger]
    #
    # @see Symbiont::PrivateTrigger
    # @see Symbiont::Trigger
    #
    # @api public
    # @since 0.3.0
    def private_trigger(*required_contexts, direction: default_direction)
      PrivateTrigger.new(*required_contexts, context_direction: direction, &closure)
    end
  end
end
