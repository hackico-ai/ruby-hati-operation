# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::StepConfigContainer do
  subject(:configuration) { described_class }

  let(:container) { configuration.new }
  let(:configs) { container.configurations }

  describe '#operation_config' do
    it 'has configuration map' do
      expect(configs).to eq({})
    end
  end

  describe '#step' do
    it 'use step for configs setup' do
      container.step a: 1

      expect(configs[:a]).to eq(1)
    end
  end

  describe '#params' do
    it 'use params for configs setup' do
      container.params 'a', err: 'b'

      aggregate_failures 'of params config' do
        expect(configs[:params]).to eq('a')
        expect(configs[:params_err]).to eq('b')
      end
    end
  end
end
