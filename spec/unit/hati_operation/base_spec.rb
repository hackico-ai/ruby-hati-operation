# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }
  let(:operation) { base_klass.new }

  context 'when use configurations' do
    describe '.step' do
      it 'has configuration map' do
        expect(base_klass.operation_config).to eq({})
      end
    end

    describe '.operation_config' do
      it 'has configuration map' do
        expect(base_klass.operation_config).to eq({})
      end
    end
  end

  # NOTE:  only for development and test
  context 'when private instance api' do
    let(:operation) { base_klass.send(:new) }
    let(:valid_result) { HatiCommand::Success.new('Valid Result') }
    describe '#step' do
      let(:invalid_result) { 'InvalidResult' }

      it 'unpacks value when given a valid result type' do
        expect(operation.step(valid_result)).to eq('Valid Result')
      end

      it 'raises an error when given an invalid result type' do
        expect { operation.step(invalid_result) }.to raise_error('Invalid Result type')
      end
    end

    # FIX ERROR
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
