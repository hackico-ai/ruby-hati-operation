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

      def params(command, err: nil)
        operation_config[:params] = command
        operation_config[:params_err] = err
      end

      def on_success(command)
        operation_config[:on_success] = command
      end

      def on_failure(command)
        operation_config[:on_failure] = command
      end

      # TODO: validate type
      def step(**kwargs)
        name, command = kwargs.first

        if kwargs[:error]
          error_name = "#{name}_error".to_sym
          operation_config[error_name] = kwargs[:error]
        end

        # TODO: add specific error
        raise 'Invalid Step type. Expected HatiCommand::Cmd' unless included_modules.include?(HatiCommand::Cmd)

        operation_config[name] = command

        define_method(name) do
          step_configs[name] || self.class.operation_config[name]
        end
      end

      def call(*args, **kwargs, &block)
        reciever = nil
        injected_params = nil

        if block_given?
          reciever = new
          container = StepConfigContainer.new

          container.instance_eval(&block)
          # WIP: work on defaults for DSL
          reciever.step_configs.merge!(container.configurations)
          injected_params = reciever.step_configs[:params]
        end

        params_modifier = injected_params || operation_config[:params]
        # TODO: naming
        if params_modifier
          unless kwargs[:params]
            raise 'If operation config :params is set, caller method must have :params keyword argument'
          end

          params_rez = params_modifier.call(kwargs[:params])
          params_err = reciever.step_configs[:params_err] || operation_config[:params_err]

          if params_rez.failure?
            # WIP: override or nest ???
            params_rez.err = params_err if params_err

            return params_rez
          end

          kwargs[:params] = params_rez.value
        end

        result = super(*args, __command_reciever: reciever, **kwargs)
        # Wrap for implicit
        rez = result.respond_to?(:success?) ? result : HatiCommand::Success.new(result)

        # TODO: extract
        success_wrap = operation_config[:on_success]
        failure_wrap = operation_config[:on_failure]

        return success_wrap&.call(rez) if success_wrap && rez.success?
        return failure_wrap&.call(rez) if failure_wrap && rez.failure?

        rez
      end
    end

    def step_configs
      @step_configs ||= {}
    end

    # unpack result
    # wraps implicitly
    def step(result = nil, err: nil, &block)
      if result.is_a?(HatiCommand::Result)
        return result.failure? ? Failure!(result) : result.value
      end

      return block.call if block_given?

      Success(result)
    rescue StandardError => e
      err ? Failure!(e, err: err) : Failure!(e)
    end
  end
end
