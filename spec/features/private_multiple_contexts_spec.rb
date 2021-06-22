# frozen_string_literal: true

describe 'Symbiont: private multiple contexts' do
  include_context 'private similar contexts'

  specify 'corresponding method resolution' do
    closure = proc { "#{object_data(1, option: 2)} #{object_info}" }

    ::Kernel.send(:undef_method, :object_data) rescue nil
    ::Kernel.send(:undef_method, :object_info) rescue nil
    result = private_symbiont_eval(object, another_object, direction: Symbiont::IOK, &closure)
    expect(result).to eq('inner_data inner_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::IOK, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::IOK, &closure)
    expect(data_method.call(1, option: 2)).to eq('inner_data')
    expect(info_method.call).to eq('inner_info')

    result = private_symbiont_eval(object, another_object, direction: Symbiont::OIK, &closure)
    expect(result).to eq('outer_data outer_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::OIK, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::OIK, &closure)
    expect(data_method.call(1, option: 2)).to eq('outer_data')
    expect(info_method.call).to eq('outer_info')

    module Kernel
      private

      def object_data(arg, option:)
        'kernel_data'
      end

      def object_info
        'kernel_info'
      end
    end
    result = private_symbiont_eval(object, another_object, direction: Symbiont::KIO, &closure)
    expect(result).to eq('kernel_data kernel_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::KIO, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KIO, &closure)
    expect(data_method.call(1, option: 2)).to eq('kernel_data')
    expect(info_method.call).to eq('kernel_info')

    ::Kernel.send(:undef_method, :object_data)
    result = private_symbiont_eval(object, another_object, direction: Symbiont::KIO, &closure)
    expect(result).to eq('inner_data kernel_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::KIO, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KIO, &closure)
    expect(data_method.call(1, option: 2)).to eq('inner_data')
    expect(info_method.call).to eq('kernel_info')

    ::Kernel.send(:undef_method, :object_info)
    undef object_info
    result = private_symbiont_eval(object, another_object, direction: Symbiont::KOI, &closure)
    expect(result).to eq('outer_data inner_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::KOI, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KOI, &closure)
    expect(data_method.call(1, option: 2)).to eq('outer_data')
    expect(info_method.call).to eq('inner_info')

    undef object_data
    result = private_symbiont_eval(object, another_object, direction: Symbiont::KOI, &closure)
    expect(result).to eq('inner_data inner_info')

    data_method = private_symbiont_method(:object_data, object, another_object, direction: Symbiont::KIO, &closure)
    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KIO, &closure)
    expect(data_method.call(1, option: 2)).to eq('inner_data')
    expect(info_method.call).to eq('inner_info')

    object_class.send(:undef_method, :object_data)

    expect do
      private_symbiont_method(:object_data, object, another_object, direction: Symbiont::KOI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    info_method = private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KOI, &closure)
    expect(info_method.call).to eq('inner_info')

    another_object_class.send(:undef_method, :object_info)

    expect do
      private_symbiont_method(:object_info, object, another_object, direction: Symbiont::KOI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    expect do
      private_symbiont_eval(object, another_object, direction: Symbiont::KOI, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)
  end
end
