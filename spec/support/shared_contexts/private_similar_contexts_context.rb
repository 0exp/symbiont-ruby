# frozen_string_literal: true

shared_context 'private similar contexts' do
  let!(:object_class) do
    Class.new do
      def object_data
        'inner_data'
      end

      private :object_data
    end
  end

  let!(:object) { object_class.new }

  before do
    module Kernel
      private

      def object_data
        'kernel_data'
      end
    end

    class << self
      private

      def object_data
        'outer_data'
      end
    end
  end

  after do
    begin
      module Kernel
        undef object_data
      end
    rescue NameError # NOTE: it means that object_data is already removed/undefined
      nil
    end
  end
end
