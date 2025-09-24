# HatiOperation

[![Gem Version](https://badge.fury.io/rb/hati_operation.svg)](https://rubygems.org/gems/hati_operation)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

HatiOperation is a next-generation Ruby toolkit that combines powerful service orchestration with modern AI-ready architecture. Built on top of [hati-command](https://github.com/hackico-ai/ruby-hati-command), it serves as both a traditional **service aggregator** and an **AI-enhanced orchestrator**, making it perfect for building modern applications that blend business logic with AI capabilities.

## Key Features

### Core Orchestration

- **Step-based execution** – write each unit of work as a small service object and compose them with `step`
- **Implicit result propagation** – methods return `Success(...)` or `Failure(...)` and are automatically unpacked
- **Fail-fast transactions** – stop the chain as soon as a step fails
- **Dependency injection (DI)** – override steps at call-time for ultimate flexibility
- **Macro DSL** – declaratively configure validation, error mapping, transactions and more
- **Service aggregation** – orchestrate multiple services into cohesive business operations

### AI-Ready Architecture

- **Tool Integration** – seamlessly integrate AI services and LLM tools
- **Safety Boundaries** – built-in guardrails for AI operations
- **Action Composition** – chain multiple AI actions safely
- **State Management** – track and manage AI agent state

### Development Acceleration

- **Structured Patterns** – clear patterns for both human and AI comprehension
- **Predictable Flow** – consistent operation structure for better maintainability
- **Self-Documenting** – clear step definitions aid both human and AI understanding
- **Context Awareness** – easy access to operation context for all services

## Table of Contents

1. [Key Features](#key-features)
   - [Core Orchestration](#core-orchestration)
   - [AI-Ready Architecture](#ai-ready-architecture)
   - [Development Acceleration](#development-acceleration)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
   - [Traditional Business Operation](#traditional-business-operation)
   - [AI-Enhanced Operation](#ai-enhanced-operation)
   - [Base Operation Configuration](#base-operation-configuration)
5. [Step DSL](#step-dsl)
6. [Dependency Injection](#dependency-injection)
7. [Alternative DSL Styles](#alternative-dsl-styles)
8. [Testing](#testing)
9. [Authors](#authors)
10. [Development](#development)
11. [Contributing](#contributing)
12. [License](#license)
13. [Code of Conduct](#code-of-conduct)

## Architecture

HatiOperation builds on top of [hati-command](https://github.com/hackico-ai/ruby-hati-command) and implements a versatile architecture that supports both traditional service aggregation and AI-enhanced operations:

```
┌─────────────────────────────────────────────────────────────┐
│                    HatiOperation                            │
│            (Universal Service Orchestrator)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Traditional Services        AI/ML Services                 │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  Business   │            │   LLM       │                 │
│  │  Logic      │            │   Tools     │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  Data       │            │   Agent     │                 │
│  │  Services   │            │   Actions   │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  External   │            │   Safety    │                 │
│  │  APIs       │            │   Guards    │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                   hati-command                              │
│                 (Foundation Layer)                          │
└─────────────────────────────────────────────────────────────┘
```

This dual-purpose architecture allows you to:

- Compose traditional business services with robust error handling and transactions
- Integrate AI capabilities with built-in safety mechanisms
- Mix and match both paradigms in the same operation
- Maintain clean separation of concerns while sharing common infrastructure

## Installation

Add HatiOperation to your Gemfile and bundle:

```ruby
# Gemfile
gem 'hati_operation'
```

```bash
bundle install
```

Alternatively:

```bash
gem install hati_operation
```

## Quick Start

HatiOperation can be used for both traditional business operations and AI-enhanced services. Here are examples of both:

### Traditional Business Operation

```ruby
# app/controllers/api/v1/withdrawal_controller.rb
class Api::V1::WithdrawalController < ApplicationController
  def create
    result = Withdrawal::Operation::Create.call(params: params.to_unsafe_h)
    run_and_render(result)
  end

  private

  def run_and_render(result)
    if result.success?
      render json: TransferSerializer.new.serialize(result.value), status: :created
    else
      error = ApiError.new(result.value)
      render json: error.to_json, status: error.status
    end
  end
end

# app/operations/withdrawal/operation/create.rb
class Withdrawal::Operation::Create < HatiOperation::Base
  # Wrap everything in DB transaction
  ar_transaction :funds_transfer_transaction!

  def call(params:)
    params = step MyApiContract.call(params), err: ApiErr.call(422)
    transfer = step funds_transfer_transaction(params[:account_id])
    EventBroadcast.new.stream(transfer.to_event)

    transfer.meta
  end

  def funds_transfer_transaction(acc_id)
    acc = Account.find_by(find_by: acc_id).presence : Failure!(err: ApiErr.call(404))

    withdrawal = step WithdrawalService.call(acc), err: ApiErr.call(409)
    transfer = step ProcessTransferService.call(withdrawal), err: ApiErr.call(503)

    Success(transfer)
  end
end
```

### AI-Enhanced Operation

```ruby
# app/operations/ai/content_generation.rb
class AI::Operation::ContentGeneration < HatiOperation::Base
  # Register safety boundaries
  safety_guard :content_filter
  rate_limit max_tokens: 1000

  step validator: ContentValidator
  step generator: LLMService
  step filter: ContentFilter
  step formatter: OutputFormatter

  def call(params:)
    # Validate input and prepare prompt
    input = step validator.call(params[:prompt])

    # Generate content with safety checks
    content = step generator.call(input), err: AIErr.call(503)
    filtered = step filter.call(content), err: AIErr.call(422)

    # Format and return
    step formatter.call(filtered)
  end
end

# Usage in controller
class Api::V1::ContentController < ApplicationController
  def create
    result = AI::Operation::ContentGeneration.call(params: params.to_unsafe_h) do
      # Override services for different models/providers
      step generator: OpenAIService
      step filter: CustomContentFilter
    end

    render_result(result)
  end
end
```

### Base Operation Configuration

```ruby
# Common configuration for API operations
class ApiOperation < HatiOperation::Base
  operation do
    unexpected_err ApiErr.call(500)
  end
end

# Common configuration for AI operations
class AIOperation < HatiOperation::Base
  operation do
    unexpected_err AIErr.call(500)
    safety_guard :content_filter
    rate_limit true
  end
end
```

## Step DSL

The DSL gives you fine-grained control over every stage of the operation:

### Core DSL Methods

- `step` – register a dependency service
- `params` – validate/transform incoming parameters
- `on_success` – handle successful operation results
- `on_failure` – map and handle failure results

### Extended Configuration

> **See:** [hati-command](https://github.com/hackico-ai/ruby-hati-command) for all configuration options

- `ar_transaction` – execute inside database transaction
- `fail_fast` – configure fail-fast behavior
- `failure` – set default failure handling
- `unexpected_err` – configure generic error behavior

## Dependency Injection

At runtime you can swap out any step for testing, feature-flags, or different environments:

```ruby
result = Withdrawal::Operation::Create.call(params) do
  step broadcast: DummyBroadcastService
  step transfer:  StubbedPaymentProcessor
end
```

## Alternative DSL Styles

### Declarative Style

Prefer more declarative code? Use the class-level DSL:

```ruby
class Withdrawal::Operation::Create < ApiOperation
  params CreateContract, err: ApiErr.call(422)

  ar_transaction :funds_transfer_transaction!

  step withdrawal: WithdrawalService, err: ApiErr.call(409)
  step transfer: ProcessTransferService, err: ApiErr.call(503)
  step broadcast: Broadcast

  on_success SerializerService.call(Transfer, status: 201)
  on_failure ApiErrorSerializer

  # requires :params keyword to access overwritten params
  # same as params = step CreateContract.call(params), err: ApiErr.call(422)
  def call(params:)
    transfer = step funds_transfer_transaction!(params[:account_id])
    broadcast.new.stream(transfer.to_event)
    transfer.meta
  end

  def funds_transfer_transaction!(acc_id)
    acc = step(err: ApiErr.call(404)) { User.find(id) }

    withdrawal = step withdrawal.call(acc)
    transfer = step transfer.call(withdrawal)
    Success(transfer)
  end
end

class Api::V2::WithdrawalController < ApiController
  def create
    run_and_render Withdrawal::Operation::Create
  end

  private

  def run_and_render(operation, &block)
   render JsonResult.prepare operation.call(params.to_unsafe_h).value
  end
end
```

### Full-Stack DI Example

```ruby
class Api::V2::WithdrawalController < ApplicationController
  def create
    run_and_render Withdrawal::Operation::Create.call(params.to_unsafe_h) do
      step broadcast: API::V2::BroadcastService
      step transfer:  API::V2::PaymentProcessorService
      step serializer: ExtendedTransferSerializer
    end
  end
end
```

## Testing

Run the test-suite with:

```bash
bundle exec rspec
```

HatiOperation is fully covered by RSpec. See `spec/` for reference examples including stubbed services and DI.

## Authors

- [Marie Giy](https://github.com/mariegiy)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hackico-ai/hati-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hackico-ai/hati-command/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HatCommand project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hackico-ai/hati-command/blob/main/CODE_OF_CONDUCT.md).
