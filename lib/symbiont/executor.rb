# frozen_string_literal: true

module Symbiont
  # Mediator service object that controls the logic of creating triggers and calling them.
  # Acts as a factory for trigerrs and a mediator for the proc invocation by them.
  #
  # @api public
  # @since 0.1.0
  module Executor
    class << self
      # Starts execution of a proc object in the context of the passed object with the selected
      # direction of method dispatching. Delegates execution to a public trigger.
      #
      # @param required_context [Object]
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return void
      #
      # @see Symbiont::Trigger#__evaluate__
      #
      # @api public
      # @since 0.1.0
      def evaluate(*required_contexts, context_direction: Trigger::IOK, &closure)
        public_trigger(*required_contexts, context_direction: context_direction, &closure).__evaluate__
      end

      # Starts execution of a proc object in the context of the passed object with the selected
      # direction of method dispatching. Delegates execution to a private trigger.
      #
      # @param required_context [Object]
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return void
      #
      # @see Symbiont::Trigger#__evaluate__
      #
      # @api public
      # @since 0.1.0
      def evaluate_private(*required_contexts, context_direction: Trigger::IOK, &closure)
        private_trigger(*required_contexts, context_direction: context_direction, &closure).__evaluate__
      end

      # Factory method that instantiates a public trigger with the desired execution context,
      # the direction of method dispatching and the closure that needs to be performed.
      #
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return [Symbiont::PublicTrigger]
      #
      # @see Symbiont::PublicTrigger
      # @see Symbiont::Trigger
      #
      # @api public
      # @since 0.1.0
      def public_trigger(*required_contexts, context_direction: Trigger::IOK, &closure)
        PublicTrigger.new(*required_contexts, context_direction: context_direction, &closure)
      end

      # Factory method that instantiates a private trigger with the desired execution context,
      # the direction of method dispatching and the closure that needs to be performed.
      #
      # @param required_context [Any]
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return [Symbiont::PrivateTrigger]
      #
      # @see Symbiont::PrivateTrigger
      # @see Symbiont::Trigger
      #
      # @api public
      # @since 0.1.0
      def private_trigger(*required_contexts, context_direction: Trigger::IOK, &closure)
        PrivateTrigger.new(*required_contexts, context_direction: context_direction, &closure)
      end

      # Gets the method object taken from the context that can respond to it.
      # Considers only public methods.
      #
      # @param method_name [Symbol,String]
      # @param required_context [Any]
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return [Method]
      #
      # @see Symbiont::Trigger#method
      #
      # @api public
      # @since 0.1.0
      def public_method(method_name, *required_contexts, context_direction: Trigger::IOK, &closure)
        public_trigger(*required_contexts, context_direction: context_direction, &closure).method(method_name)
      end

      # Gets the method object taken from the context that can respond to it.
      # Considers private methods and public methods.
      #
      # @param method_name [Symbol,String]
      # @param required_context [Any]
      # @param context_direction [Array<Symbol>]
      # @param closure [Proc]
      # @return [Method]
      #
      # @see Symbiont::Trigger#method
      #
      # @api public
      # @since 0.1.0
      def private_method(method_name, *required_contexts, context_direction: Trigger::IOK, &closure)
        private_trigger(*required_contexts, context_direction: context_direction, &closure).method(method_name)
      end
    end
  end
end
