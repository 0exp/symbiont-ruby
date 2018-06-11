# frozen_string_literal: true

module Symbiont
  # Mediator service object that controls the logic of creating triggers and calling them.
  # Acts as a factory for trigerrs and an execution-mediator for procs.
  #
  # @api public
  # @since 0.1.0
  module Executor
    class << self
      # Starts execution of a proc object in the context of the passed object with the selected
      # direction of method dispatching. Delegates execution to a public trigger.
      #
      # @param required_contexts [Array<Object>]
      #   A set of objects that should be used as the main context series for method resolving
      #   algorithm.
      # @param context_direction [Array<Symbol>]
      #   An array of symbols that represents the direction of contexts. Possible values:
      #
      #    - Symbiont::IOK
      #    - Symbiont::OIK
      #    - Symbiont::OKI
      #    - Symbiont::IKO
      #    - Symbiont::KOI
      #    - Symbiont::KIO
      # @param closure [Proc]
      #   Proc object that will be evaluated in many contexts: initial, outer and kernel.
      # @return void
      #
      # @see Symbiont::Trigger#__evaluate__
      #
      # @api public
      # @since 0.1.0
      def evaluate(*required_contexts, context_direction: Trigger::IOK, &closure)
        Isolator.new(default_direction: context_direction, &closure)
                .evaluate(*required_contexts)
      end

      # Starts execution of a proc object in the context of the passed object with the selected
      # direction of method dispatching. Delegates execution to a private trigger.
      #
      # @param required_contexts [Array<Object>]
      #   A set of objects that should be used as the main context series for method resolving
      #   algorithm.
      # @param context_direction [Array<Symbol>]
      #   An array of symbols that represents the direction of contexts. Possible values:
      #
      #     - Symbiont::IOK
      #     - Symbiont::OIK
      #     - Symbiont::OKI
      #     - Symbiont::IKO
      #     - Symbiont::KOI
      #     - Symbiont::KIO
      # @param closure [Proc]
      #   Proc object that will be evaluated in many contexts: initial, outer and kernel.
      # @return void
      #
      # @see Symbiont::Trigger#__evaluate__
      #
      # @api public
      # @since 0.1.0
      def evaluate_private(*required_contexts, context_direction: Trigger::IOK, &closure)
        Isolator.new(default_direction: context_direction, &closure)
                .evaluate_private(*required_contexts)
      end

      # Gets the method object taken from the context that can respond to it.
      # Considers only public methods.
      #
      # @param method_name [Symbol,String] A name of required method.
      # @param required_contexts [Array<Object>]
      #   A set of objects that should be used as the main context series for method resolving
      #   algorithm.
      #   An array of symbols that represents the direction of contexts. Possible values:
      #
      #     - Symbiont::IOK
      #     - Symbiont::OIK
      #     - Symbiont::OKI
      #     - Symbiont::IKO
      #     - Symbiont::KOI
      #     - Symbiont::KIO
      # @param closure [Proc] Proc object that will be used as outer-context for method resolution.
      # @return [Method]
      #
      # @see Symbiont::PublicTrigger
      # @see Symbiont::Trigger#method
      #
      # @api public
      # @since 0.1.0
      def public_method(method_name, *required_contexts, context_direction: Trigger::IOK, &closure)
        Isolator.new(default_direction: context_direction, &closure)
                .public_method(method_name, *required_contexts)
      end

      # Gets the method object taken from the context that can respond to it.
      # Considers private methods and public methods.
      #
      # @param method_name [Symbol,String] A name of required method.
      # @param required_contexts [Array<Object>]
      #   A set of objects that should be used as the main context series for method resolving
      #   algorithm.
      #   An array of symbols that represents the direction of contexts. Possible values:
      #
      #     - Symbiont::IOK
      #     - Symbiont::OIK
      #     - Symbiont::OKI
      #     - Symbiont::IKO
      #     - Symbiont::KOI
      #     - Symbiont::KIO
      # @param closure [Proc] Proc object that will be used as outer-context for method resolution.
      # @return [Method]
      #
      # @see Symbiont::PrivateTrigger
      # @see Symbiont::Trigger#method
      #
      # @api public
      # @since 0.1.0
      def private_method(method_name, *required_contexts, context_direction: Trigger::IOK, &closure)
        Isolator.new(default_direction: context_direction, &closure)
                .private_method(method_name, *required_contexts)
      end
    end
  end
end
