# frozen_string_literal: true

# NOTE: helper names follow convention 'support_<module_name>_<helper_name>'

module Dummy
  def support_dummy_service_base
    stub_const('DummyServiceBase', Class.new do
      include HatiCommand::Cmd

      def call(params, halt: false)
        params.to_s
        halt ? Failure() : Success()
      end
    end)
  end
end
