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
        # TODO: add specific error
        raise 'Invalid Step type. Expected HatiCommand::Cmd' unless included_modules.include?(HatiCommand::Cmd)

        name, command = kwargs.first

        if kwargs[:err]
          error_name = "#{name}_error".to_sym
          operation_config[error_name] = kwargs[:err]
        end

        # WIP: restructure
        operation_config[name] = command

        define_method(name) do
          configs = self.class.operation_config

          step_exec_stack.append({ step: name, err: configs[error_name], done: false })

          step_configs[name] || configs[name]
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
          reciever_configs = reciever&.step_configs || {}
          params_err = reciever_configs[:params_err] || operation_config[:params_err]

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

    # keep track of step macro calls
    def step_exec_stack
      @step_exec_stack ||= []
    end

    # unpack result
    # wraps implicitly
    def step(result = nil, err: nil, &block)
      return __step_block_call!(err: err, &block) if block_given?

      last_step = step_exec_stack.last
      err ||= last_step[:err] if last_step

      if result.is_a?(HatiCommand::Result)
        Failure!(result, err: err || result.error) if result.failure?

        step_exec_stack.last[:done] = true if last_step

        return result.value
      end

      Failure!(result, err: err) if err && result.nil?

      step_exec_stack.last[:done] = true if last_step

      result
    end

    def __step_block_call!(err: nil)
      yield
    rescue StandardError => e
      err ? Failure!(e, err: err) : Failure!(e)
    end
  end
end
