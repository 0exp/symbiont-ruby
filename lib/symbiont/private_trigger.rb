# frozen_string_literal: true

module Symbiont
  # A trigger that considers both public and private methods of executable contexts
  # during method dispatching.
  #
  # @api private
  # @since 0.1.0
  class PrivateTrigger < Trigger
    # @param method_name [String,Symbol]
    # @option include_private [Boolean]
    # @raise NoMethodError
    # @return [Objcet]
    #
    # @see Symbiont::Trigger#__actual_context__
    #
    # @since 0.1.0
    def __actual_context__(method_name)
      __directed_contexts__.find do |context|
        context.respond_to?(method_name, true)
      end || super
    end
  end
end
