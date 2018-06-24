# frozen_string_literal: true

# TODO: refactor with shared examples / shared contexts

describe 'Symbiont: symbiont-like behaviour (by Symbiont::Context mixin)' do
  let(:symbiont_directions) do
    [
      Symbiont::IKO,
      Symbiont::IOK,
      Symbiont::KIO,
      Symbiont::KOI,
      Symbiont::OIK,
      Symbiont::OKI
    ]
  end

  shared_examples 'symbiont direction option' do
    specify 'instance#evaluate fails on incompatible direction option' do
      expect do
        instance_object.evaluate(gen_symb) {}
      end.to raise_error(Symbiont::Trigger::IncompatibleContextDirectionError)
    end

    specify 'instance#evaluate_private fails on incompatible direction option' do
      expect do
        instance_object.evaluate(gen_symb) {}
      end.to raise_error(Symbiont::Trigger::IncompatibleContextDirectionError)
    end

    specify 'module#evaluate fails on incompatible direction option' do
      expect do
        instance_object.evaluate(gen_symb) {}
      end.to raise_error(Symbiont::Trigger::IncompatibleContextDirectionError)
    end

    specify 'module#evaluate_private fails on incompatible direction option' do
      expect do
        instance_object.evaluate(gen_symb) {}
      end.to raise_error(Symbiont::Trigger::IncompatibleContextDirectionError)
    end

    specify 'instance#evaluate provides an ability to use any direction' do
      symbiont_directions.each do |symbiont_direction|
        expect(Symbiont::Executor).to(
          receive(:evaluate).with(
            instance_object,
            context_direction: symbiont_direction
          )
        )

        instance_object.evaluate(symbiont_direction)
      end
    end

    specify 'instance#evaluate_private provides an ability to use any direction' do
      symbiont_directions.each do |symbiont_direction|
        expect(Symbiont::Executor).to(
          receive(:evaluate_private).with(
            instance_object,
            context_direction: symbiont_direction
          )
        )

        instance_object.evaluate_private(symbiont_direction)
      end
    end

    specify 'module#evaluate provides an ability to use any direction' do
      symbiont_directions.each do |symbiont_direction|
        expect(Symbiont::Executor).to(
          receive(:evaluate).with(
            module_object,
            context_direction: symbiont_direction
          )
        )

        module_object.evaluate(symbiont_direction)
      end
    end

    specify 'module#evaluate_private provides an ability to use any direction' do
      symbiont_directions.each do |symbiont_direction|
        expect(Symbiont::Executor).to(
          receive(:evaluate_private).with(
            module_object,
            context_direction: symbiont_direction
          )
        )

        module_object.evaluate_private(symbiont_direction)
      end
    end
  end

  shared_examples 'symbiont context mixin' do |symbiont_direction|
    let(:instance_object) { Class.new { include Symbiont::Context(symbiont_direction) }.new }
    let(:module_object)   { Class.new { extend Symbiont::Context(symbiont_direction) } }

    include_examples 'symbiont direction option'

    specify "instance#evaluate => invokes public evaluator " \
            "with #{symbiont_direction} direction inside the self" do

      expect(Symbiont::Executor).to(
        receive(:evaluate).with(
          instance_object,
          context_direction: symbiont_direction
        )
      )

      instance_object.evaluate {}
    end

    specify 'instance#evaluate => fails when proc isnt passed' do
      expect do
        instance_object.evaluate
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify "instance#evaluate_private => invokes private evaluator " \
            "with #{symbiont_direction} direction inside the self" do

      expect(Symbiont::Executor).to(
        receive(:evaluate_private).with(
          instance_object,
          context_direction: symbiont_direction
        )
      )

      instance_object.evaluate_private {}
    end

    specify 'instnace#evaluate_private => fails when proc isnt passed' do
      expect do
        instance_object.evaluate_private
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify "module#evaluate => invokes public evaluator " \
            "with #{symbiont_direction} direction inside the self" do

      expect(Symbiont::Executor).to(
        receive(:evaluate).with(
          module_object,
          context_direction: symbiont_direction
        )
      )

      module_object.evaluate {}
    end

    specify 'module#evaluate => fails when proc isnt passed' do
      expect do
        module_object.evaluate
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify "module#evaluate_private => invokes private evaluator " \
            "with #{symbiont_direction} direction inside the self" do

      expect(Symbiont::Executor).to(
        receive(:evaluate).with(
          module_object,
          context_direction: symbiont_direction
        )
      )

      module_object.evaluate {}
    end

    specify 'module#evaluate_private => fails when proc isnt passed' do
      expect do
        module_object.evaluate_private
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify "module#public_method => resolves corresponding method " \
            "with #{symbiont_direction} direction" do
      corresponding_method = gen_symb

      expect(Symbiont::Executor).to(
        receive(:public_method).with(
          module_object,
          corresponding_method,
          context_direction: symbiont_direction
        )
      )

      module_object.public_method(corresponding_method, symbiont_direction) {}
    end

    specify "module#private_method => resolves corresponding method " \
            "with #{symbiont_direction} direction" do
      corresponding_method = gen_symb

      expect(Symbiont::Executor).to(
        receive(:private_method).with(
          module_object,
          corresponding_method,
          context_direction: symbiont_direction
        )
      )

      module_object.private_method(corresponding_method, symbiont_direction) {}
    end

    specify "instance#public_method => resolves corresponding method " \
            "with #{symbiont_direction} direction" do
      corresponding_method = gen_symb

      expect(Symbiont::Executor).to(
        receive(:public_method).with(
          instance_object,
          corresponding_method,
          context_direction: symbiont_direction
        )
      )

      instance_object.public_method(corresponding_method, symbiont_direction) {}
    end

    specify "instance#private_method => resolves corresponding method " \
            "with #{symbiont_direction} direction" do
      corresponding_method = gen_symb

      expect(Symbiont::Executor).to(
        receive(:private_method).with(
          instance_object,
          corresponding_method,
          context_direction: symbiont_direction
        )
      )

      instance_object.private_method(corresponding_method, symbiont_direction) {}
    end
  end

  describe 'default context direction (include Context mixin without attributes)' do
    let(:instance_object) { Class.new { include Symbiont::Context }.new }
    let(:module_object)   { Class.new { extend Symbiont::Context } }

    include_examples 'symbiont direction option'

    specify 'isntance#evaluate without direction uses Symbiont::IOK by default' do
      expect(Symbiont::Executor).to receive(:evaluate).with(instance_object, context_direction: Symbiont::IOK)
      instance_object.evaluate {}
    end

    specify 'instance#evaluate_private without direction uses Symbiont::IOK by default' do
      expect(Symbiont::Executor).to receive(:evaluate_private).with(instance_object, context_direction: Symbiont::IOK)
      instance_object.evaluate_private {}
    end

    specify 'module#evaluate without direction uses Symbiont::IOK by default' do
      expect(Symbiont::Executor).to receive(:evaluate).with(module_object, context_direction: Symbiont::IOK)
      module_object.evaluate {}
    end

    specify 'module#evaluate_private without direction uses Symbiont::IOK by default' do
      expect(Symbiont::Executor).to receive(:evaluate_private).with(module_object, context_direction: Symbiont::IOK)
      module_object.evaluate_private {}
    end

    specify 'module#evaluate fails when proc isnt possed' do
      expect do
        instance_object.evaluate
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify 'module#evaluate_private fails when proc isnt possed' do
      expect do
        instance_object.evaluate_private
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify 'instance#evaluate fails when proc isnt possed' do
      expect do
        module_object.evaluate
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end

    specify 'instance#evaluate_private fails when proc isnt possed' do
      expect do
        module_object.evaluate_private
      end.to raise_error(Symbiont::Isolator::UnprovidedClosureAttributeError)
    end
  end

  it_behaves_like 'symbiont context mixin', Symbiont::IKO
  it_behaves_like 'symbiont context mixin', Symbiont::IOK
  it_behaves_like 'symbiont context mixin', Symbiont::KIO
  it_behaves_like 'symbiont context mixin', Symbiont::KOI
  it_behaves_like 'symbiont context mixin', Symbiont::OIK
  it_behaves_like 'symbiont context mixin', Symbiont::OKI
end
