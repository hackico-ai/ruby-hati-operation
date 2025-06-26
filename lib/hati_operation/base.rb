# frozen_string_literal: true

require 'hati_command'

# Dev version Feautures
# - implicit result return
# - object lvl step for <#value> unpacking
# - forced logical transactional behavior - always fail_fast! on
#   failure step unpacking
# - class lvl macro for DI:
#     * step validate: Validator
#     * operation for customization (alias to command)
# - always fail fast on step unpacking

module HatiOperation
  class Base
    include HatiCommand::Cmd

    class << self
      alias operation command

      def operation_config
        @operation_config ||= {}
      end

      # TODO: validate type
      def step(**kwargs)
        name, command = kwargs.first
        # TODO: add specific error
        raise 'Invalid Step type. Expected HatiCommand::Cmd' unless included_modules.include?(HatiCommand::Cmd)

        operation_config[name] = command

        define_method(name) do
          step_configs[name] || self.class.operation_config[name]
        end
      end

      def call(*args, **kwargs, &block)
        reciever = nil

        if block_given?
          reciever = new
          container = StepConfigContainer.new

          container.instance_eval(&block)
          # WIP: work on defaults for DSL
          reciever.step_configs.merge!(container.configurations)
        end

        # TODO: naming
        result = super(*args, __command_reciever: reciever, **kwargs)
        # Wrap for implicit
        result.respond_to?(:success?) ? result : HatiCommand::Success.new(result)
      end
    end

    def step_configs
      @step_configs ||= {}
    end

    # unpack result
    def step(result = nil, err: nil, &block)
      if result.is_a?(HatiCommand::Result)
        return result.failure? ? Failure!(result) : result.value
      end

      block.call
    rescue StandardError => e
      err ? Failure!(e, err: e) : Failure!(e)
    end
  end
end
