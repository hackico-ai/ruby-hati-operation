# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }
  let(:operation_name) { 'MyDummyOperation' }

  before do
    dummy_operation = stub_const(operation_name, base_klass)

    dummy_operation.operation do
      fail_fast 'Fail Fast Message'
      failure 'Failure Message'
      unexpected_err 'Unexpected Error'
    end

    dummy_operation.params 'a', err: 'b'
    dummy_operation.step a: 'a'
    dummy_operation.on_success 'Success Message'
    dummy_operation.on_failure 'Failure Message'
  end

  describe '.command_config' do
    let(:configs) { MyDummyOperation.command_config }

    it 'returns the configurations' do
      aggregate_failures 'of command options' do
        expect(configs[:fail_fast]).to eq('Fail Fast Message')
        expect(configs[:failure]).to eq('Failure Message')
        expect(configs[:unexpected_err]).to eq('Unexpected Error')
      end
    end
  end

  describe '.operation_config' do
    let(:configs) { MyDummyOperation.operation_config }

    it 'returns the configurations' do
      expect(configs[:params]).to eq('a')
      expect(configs[:params_err]).to eq('b')
      expect(configs[:a]).to eq('a') # step config
      expect(configs[:on_success]).to eq('Success Message')
      expect(configs[:on_failure]).to eq('Failure Message')
    end
  end
end
