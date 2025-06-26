# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }

  before do
    base_klass.operation do
      fail_fast 'Fail Fast Message'
      failure 'Failure Message'
      unexpected_err 'Unexpected Error'
    end
  end

  let(:configs) { base_klass.command_config }

  describe '.command_config' do
    it 'returns the configurations' do
      aggregate_failures 'of command options' do
        expect(configs[:fail_fast]).to eq('Fail Fast Message')
        expect(configs[:failure]).to eq('Failure Message')
        expect(configs[:unexpected_err]).to eq('Unexpected Error')
      end
    end
  end
end
