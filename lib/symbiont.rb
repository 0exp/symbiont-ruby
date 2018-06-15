# frozen_string_literal: true

# Main Symbiont namespace.
#
# @api public
# @since 0.1.0
module Symbiont
  require_relative 'symbiont/version'
  require_relative 'symbiont/trigger'
  require_relative 'symbiont/public_trigger'
  require_relative 'symbiont/private_trigger'
  require_relative 'symbiont/isolator'
  require_relative 'symbiont/executor'
  require_relative 'symbiont/context'

  # Method delegation order alias (inner_contexts => outer_context => kernel_context).
  #
  # @see Symbiont::Trigger::IOK
  #
  # @api public
  # @since 0.1.0
  IOK = Trigger::IOK

  # Method delegation order alias (outer_context => inner_contexts => kernel_context).
  #
  # @see Symbiont::Trigger::OIK
  #
  # @api public
  # @since 0.1.0
  OIK = Trigger::OIK

  # Method delegation order alias (outer_context => kernel_context => inner_contexts).
  #
  # @see Symbiont::Trigger::OKI
  #
  # @api public
  # @since 0.1.0
  OKI = Trigger::OKI

  # Method delegation order alias (inner_contexts => kernel_context => outer_context).
  #
  # @see Symbiont::Trigger::IKO
  #
  # @api public
  # @since 0.1.0
  IKO = Trigger::IKO

  # Method delegation order alias (kernel_context => outer_context => inner_contexts).
  #
  # @see Symbiont::Trigger::IOK
  #
  # @api public
  # @since 0.1.0
  KOI = Trigger::KOI

  # Method delegation order alias (kernel_context => inner_contexts => outer_context).
  #
  # @see Symbiont::Trigger::KIO
  #
  # @api public
  # @since 0.1.0
  KIO = Trigger::KIO
end
