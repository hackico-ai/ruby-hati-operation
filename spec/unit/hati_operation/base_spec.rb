# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }
  # let(:operation_name) { 'MyDummyOperation' }

  # before do
  #   stub_const(operation_name, base_klass)
  # end

  let(:dummy_operation) { Class.new(base_klass) }

  context 'when use configurations' do
    describe '.step' do
      it 'has configuration map' do
        expect(dummy_operation.operation_config).to eq({})
      end
    end

    describe '.operation_config' do
      it 'has configuration map' do
        expect(dummy_operation.operation_config).to eq({})
      end
    end
  end

  # NOTE:  only for development and test
  context 'when private instance api' do
    let(:operation) { dummy_operation.send(:new) }
    let(:valid_result) { HatiCommand::Success.new('Valid Result') }

    describe '#step' do
      let(:invalid_result) { 'InvalidResult' }

      it 'unpacks value when given a valid result type' do
        expect(operation.step(valid_result)).to eq('Valid Result')
      end

      context 'when block given' do
        it 'evaluetes block ' do
          expect(operation.step { 1 }).to eq(1)
        end

        it 'wraps an error' do
          expect { operation.step { raise 'Booom' } }.to raise_error(HatiCommand::Errors::FailFastError)
        end
      end
    end

    describe '#step_configs' do
      it 'returns an empty hash when no configurations are set' do
        expect(operation.step_configs).to eq({})
      end

      it 'stores configurations correctly' do
        operation.step_configs[:a] = 1

        expect(operation.step_configs[:a]).to eq(1)
      end
    end
  end
end
