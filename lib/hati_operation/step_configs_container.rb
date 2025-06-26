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
  end
end
