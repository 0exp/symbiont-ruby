# frozen_string_literal: true

module SpecSupport::SymbiontHelpers
  def public_symbiont_eval(*contexts, direction:, &clojure)
    Symbiont::Executor.evaluate(
      *contexts, context_direction: direction, &clojure
    )
  end

  def private_symbiont_eval(*contexts, direction:, &clojure)
    Symbiont::Executor.evaluate_private(
      *contexts, context_direction: direction, &clojure
    )
  end

  def public_symbiont_method(method_name, *contexts, direction:, &clojure)
    Symbiont::Executor.public_method(
      method_name, *contexts, context_direction: direction, &clojure
    )
  end

  def private_symbiont_method(method_name, *contexts, direction:, &clojure)
    Symbiont::Executor.private_method(
      method_name, *contexts, context_direction: direction, &clojure
    )
  end
end
