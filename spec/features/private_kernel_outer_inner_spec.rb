# frozen_string_literal: true

describe 'Symbiont: kernel context (kernel) => outer context (proc) => inner context (object)' do
  include_context 'private similar contexts'

  specify 'private KOI resolution' do
    closure = proc { object_data }

    result = Symbiont::Executor.evaluate_private(object, Symbiont::KOI, &closure)
    method = Symbiont::Executor.private_method(:object_data, object, Symbiont::KOI, &closure)
    expect(result).to      eq('kernel_data')
    expect(method.call).to eq('kernel_data')

    ::Kernel.send(:undef_method, :object_data)
    result = Symbiont::Executor.evaluate_private(object, Symbiont::KOI, &closure)
    method = Symbiont::Executor.private_method(:object_data, object, Symbiont::KOI, &closure)
    expect(result).to      eq('outer_data')
    expect(method.call).to eq('outer_data')

    undef object_data
    result = Symbiont::Executor.evaluate_private(object, Symbiont::KOI, &closure)
    method = Symbiont::Executor.private_method(:object_data, object, Symbiont::KOI, &closure)
    expect(result).to      eq('inner_data')
    expect(method.call).to eq('inner_data')

    object_class.send(:undef_method, :object_data)
    expect do
      Symbiont::Executor.evaluate_private(object, Symbiont::KOI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    expect do
      Symbiont::Executor.private_method(:object_data, object, Symbiont::KIO, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)
  end
end
