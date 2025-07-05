# frozen_string_literal: true

module HatiOperation
  class StepConfigContainer
    def configurations
      @configurations ||= {}
    end

    def step(**kwargs)
      step_name, step_klass = kwargs.first

      configurations[step_name] = step_klass
    end

    # WIP: so far as API adapter
    def params(command = nil, err: nil)
      configurations[:params] = command
      configurations[:params_err] = err
    end
  end
end
