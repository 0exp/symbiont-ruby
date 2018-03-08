# frozen_string_literal: true

describe 'Symbiont: outer context (proc) => inner context (object) => kernel context (kernel)' do
  include_context 'public similar contexts'

  specify 'public OIK resolution' do
    closure = proc { object_data }

    result = Symbiont::Executor.evaluate(object, Symbiont::OIK, &closure)
    method = Symbiont::Executor.public_method(:object_data, object, Symbiont::OIK, &closure)
    expect(result).to      eq('outer_data')
    expect(method.call).to eq('outer_data')

    undef object_data
    result = Symbiont::Executor.evaluate(object, Symbiont::OIK, &closure)
    method = Symbiont::Executor.public_method(:object_data, object, Symbiont::OIK, &closure)
    expect(result).to      eq('inner_data')
    expect(method.call).to eq('inner_data')

    object_class.send(:undef_method, :object_data)
    result = Symbiont::Executor.evaluate(object, Symbiont::OIK, &closure)
    method = Symbiont::Executor.public_method(:object_data, object, Symbiont::OIK, &closure)
    expect(result).to      eq('kernel_data')
    expect(method.call).to eq('kernel_data')

    ::Kernel.send(:undef_method, :object_data)
    expect do
      Symbiont::Executor.evaluate(object, Symbiont::OIK, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    expect do
      Symbiont::Executor.public_method(:object_data, object, Symbiont::OIK, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)
  end
end
