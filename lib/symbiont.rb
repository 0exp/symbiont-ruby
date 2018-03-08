# frozen_string_literal: true

# @api public
# @since 0.1.0
module Symbiont
  require_relative 'symbiont/version'
  require_relative 'symbiont/trigger'
  require_relative 'symbiont/public_trigger'
  require_relative 'symbiont/private_trigger'
  require_relative 'symbiont/executor'
  require_relative 'symbiont/context'

  # @see Symbiont::Trigger::IOK
  # @api public
  # @since 0.1.0
  IOK = Trigger::IOK

  # @see Symbiont::Trigger::OIK
  # @api public
  # @since 0.1.0
  OIK = Trigger::OIK

  # @see Symbiont::Trigger::OKI
  # @api public
  # @since 0.1.0
  OKI = Trigger::OKI

  # @see Symbiont::Trigger::IKO
  # @api public
  # @since 0.1.0
  IKO = Trigger::IKO

  # @see Symbiont::Trigger::IOK
  # @api public
  # @since 0.1.0
  KOI = Trigger::KOI

  # @see Symbiont::Trigger::KIO
  # @api public
  # @since 0.1.0
  KIO = Trigger::KIO
end
