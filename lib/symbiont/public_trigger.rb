# frozen_string_literal: true

module Symbiont
  # A trigger that considers only public methods of executable contexts
  # during method dispatching.
  #
  # @api private
  # @since 0.1.0
  class PublicTrigger < Trigger
    # Returns the first context that is able to respond to the required method.
    # The context is chosen in the context direction order (see #__context_direction__).
    # Raises NoMethodError excepition when no one of the contexts are able to respond to
    # the required method.
    # Basicaly (in #super), abstract implementation raises NoMethodError.
    #
    # @param method_name [String,Symbol] Method that a context should respond to.
    # @raise NoMethodError
    #   Is raised when no one of the contexts are able to respond to the required method.
    # @return [Objcet]
    #
    # @see Symbiont::Trigger#__actual_context__
    #
    # @api private
    # @since 0.1.0
    def __actual_context__(method_name)
      __directed_contexts__.find do |context|
        context.respond_to?(method_name, false)
      end || super
    end
  end
end
