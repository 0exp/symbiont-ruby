# frozen_string_literal: true

describe 'Symbiont: outer context (proc) => kernel context (kernel) => inner context (object)' do
  include_context 'private similar contexts'

  specify 'private OKI resolution' do
    closure = proc { object_data(1, option: 2) }

    result = private_symbiont_eval(object, direction: Symbiont::OKI, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::OKI, &closure)
    expect(result).to eq('outer_data')
    expect(method.call(1, option: 2)).to eq('outer_data')

    undef object_data
    result = private_symbiont_eval(object, direction: Symbiont::OKI, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::OKI, &closure)
    expect(result).to eq('kernel_data')
    expect(method.call(1, option: 2)).to eq('kernel_data')

    ::Kernel.send(:undef_method, :object_data)
    result = private_symbiont_eval(object, direction: Symbiont::OKI, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::OKI, &closure)
    expect(result).to eq('inner_data')
    expect(method.call(1, option: 2)).to eq('inner_data')

    object_class.send(:undef_method, :object_data)
    expect do
      private_symbiont_eval(object, direction: Symbiont::OKI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    expect do
      private_symbiont_method(:object_data, object, direction: Symbiont::OKI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)
  end
end
