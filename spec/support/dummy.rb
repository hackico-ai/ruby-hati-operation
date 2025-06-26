# frozen_string_literal: true

# NOTE: helper names follow convention 'support_<module_name>_<helper_name>'

module Dummy
  def support_dummy_service_map
    stub_const('DummyServiceBase', Class.new do
      include HatiCommand::Cmd

      def call(params, halt: false)
        params.to_s
        halt ? Failure() : Success()
      end
    end)

    {
      base: DummyServiceBase,
      account: stub_const('AccountService', Class.new(DummyServiceBase)),
      broadcast: stub_const('BroadcastService', Class.new(DummyServiceBase)),
      withdrawal: stub_const('WithdrawalService', Class.new(DummyServiceBase))
    }
  end
end
