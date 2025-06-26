# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiOperation::Base do
  subject(:base_klass) { described_class }
  let(:di_msg) { 'Great Success from DiService' }
  let(:service_map) { support_dummy_service_map }
  let(:base_service) { service_map[:base] }
  let(:account_service) { service_map[:account] }
  let(:broadcast_service) { service_map[:broadcast] }
  let(:withdrawal_service) { service_map[:withdrawal] }

  before do
    stub_const('DiService', Class.new(base_service) do
      def call(account)
        account.to_s
        Success('Great Success from DiService')
      end
    end)

    stub_const('BaseOperation', Class.new(base_klass) do
      operation { unexpected_err true }
    end)

    stub_const(
      'MyDummyOperation',
      Class.new(BaseOperation) do
        step user_account: AccountService
        step broadcast: BroadcastService

        def call(params, halt: false)
          account = step user_account.call(params[:account_id])
          transfer = step withdaral(account, halt)
          broadcast.call(transfer)

          account
        end

        def withdaral(account, halt)
          WithdrawalService.call(account, halt: halt)
        end
      end
    )
  end

  context 'when aggregates services' do
    let(:params) { {} }

    it 'runs successfully' do
      result = MyDummyOperation.call(params)

      expect(result.success?).to be true
    end

    it 'runs faulty' do
      result = MyDummyOperation.call

      expect(result.failure?).to be true
    end

    it 'runs halty' do
      result = MyDummyOperation.call(halt: true)

      expect(result.failure?).to be true
    end

    it 'uses DI' do
      result = MyDummyOperation.call(params) do
        step user_account: DiService
      end

      aggregate_failures do
        expect(result.success?).to be true
        expect(result.value).to eq(di_msg)
      end
    end
  end
end
