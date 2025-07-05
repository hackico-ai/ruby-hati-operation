# frozen_string_literal: true

require 'spec_helper'

# TODO: redesign const & anonymous
RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }
  let(:di_msg) { 'Great Success from DiService' }

  let(:base_service) { support_dummy_service_base }

  let(:base_operation) do
    Class.new(base_klass) do
      operation { unexpected_err true }
    end
  end

  let(:my_dummy_operation) do
    user_account = stub_const('AccountService', Class.new(base_service))
    broadcast = stub_const('BroadcastService', Class.new(base_service))
    withdrawal = stub_const('WithdrawalService', Class.new(base_service))

    Class.new(base_operation) do
      step user_account: user_account
      step broadcast: broadcast
      step withdrawal: withdrawal

      def call(params, halt: false)
        account = step user_account.call(params[:account_id])
        transfer = step withdaral(account, halt)
        broadcast.call(transfer)

        account
      end

      def withdaral(account, halt)
        withdrawal.call(account, halt: halt)
      end
    end
  end

  let(:di_service) do
    Class.new(base_service) do
      def call(account)
        account.to_s
        Success('Great Success from DiService')
      end
    end
  end

  context 'when aggregates services' do
    let(:params) { {} }

    it 'runs successfully' do
      result = my_dummy_operation.call(params)

      expect(result.success?).to be true
    end

    it 'runs faulty' do
      result = my_dummy_operation.call

      expect(result.failure?).to be true
    end

    it 'runs halty' do
      result = my_dummy_operation.call(halt: true)

      expect(result.failure?).to be true
    end

    it 'uses DI' do
      service = di_service

      result = my_dummy_operation.call(params) do
        step user_account: service
      end

      aggregate_failures do
        expect(result.success?).to be true
        expect(result.value).to eq(di_msg)
      end
    end
  end
end
