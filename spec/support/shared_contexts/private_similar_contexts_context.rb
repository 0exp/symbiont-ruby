# frozen_string_literal: true

shared_context 'private similar contexts' do
  let!(:object_class) do
    Class.new do
      private

      def object_data
        'inner_data'
      end
    end
  end

  let!(:another_object_class) do
    Class.new(BasicObject) do
      private

      def object_info
        'inner_info'
      end
    end
  end

  let!(:object) { object_class.new }
  let!(:another_object) { another_object_class.new }

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

      def object_info
        'outer_info'
      end
    end
  end

  after do
    module Kernel
      begin
        undef object_data
      rescue NameError # NOTE: it means that object_data is already removed/undefined
      end

      begin
        undef object_info
      rescue NameError # NOTE: it means that object_data is already removed/undefined
      end
    end
  end
end
