# HatiOperation

[![Gem Version](https://badge.fury.io/rb/hati_operation.svg)](https://rubygems.org/gems/hati_operation)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

HatiOperation is a lightweight Ruby toolkit that helps you compose domain logic into clear, reusable **operations**. Built on top of [hati-command](https://github.com/hackico-ai/ruby-hati-command), it serves as an **aggregator** that orchestrates multiple services and commands into cohesive business operations.

## ✨ Key Features

- **Step-based execution** – write each unit of work as a small service object and compose them with `step`
- **Implicit result propagation** – methods return `Success(...)` or `Failure(...)` and are automatically unpacked
- **Fail-fast transactions** – stop the chain as soon as a step fails
- **Dependency injection (DI)** – override steps at call-time for ultimate flexibility
- **Macro DSL** – declaratively configure validation, error mapping, transactions and more
- **Service aggregation** – orchestrate multiple services into cohesive business operations

## 🏗️ Architecture

HatiOperation builds on top of [hati-command](https://github.com/hackico-ai/ruby-hati-command) and serves as an **aggregator pattern** implementation:

```
┌─────────────────────────────────────────────────────────────┐
│                    HatiOperation                            │
│                   (Aggregator Layer)                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Service A  │  │  Service B  │  │  Service C  │          │
│  │ (Command)   │  │ (Command)   │  │ (Command)   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                   hati-command                              │
│                 (Foundation Layer)                          │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Step DSL](#step-dsl)
4. [Dependency Injection](#dependency-injection)
5. [Alternative DSL Styles](#alternative-dsl-styles)
6. [Testing](#testing)
7. [Contributing](#contributing)
8. [License](#license)

## 🚀 Installation

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

## 🎯 Quick Start

The example below shows how HatiOperation can be leveraged inside a **Rails API** controller to aggregate multiple services:

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
```

### 🔧 Defining the Operation

```ruby
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

### 🎛️ Base Operation Configuration

```ruby
class ApiOperation < HatiOperation::Base
  operation do
    unexpected_err ApiErr.call(500)
  end
end
```

## 🛠️ Step DSL

The DSL gives you fine-grained control over every stage of the operation:

### Core DSL Methods

- `step` – register a dependency service
- `params` – validate/transform incoming parameters
- `on_success` – handle successful operation results
- `on_failure` – map and handle failure results

### Extended Configuration

> 📖 **See:** [hati-command](https://github.com/hackico-ai/ruby-hati-command) for all configuration options

- `ar_transaction` – execute inside database transaction
- `fail_fast` – configure fail-fast behavior
- `failure` – set default failure handling
- `unexpected_err` – configure generic error behavior

## 🔄 Dependency Injection

At runtime you can swap out any step for testing, feature-flags, or different environments:

```ruby
result = Withdrawal::Operation::Create.call(params) do
  step broadcast: DummyBroadcastService
  step transfer:  StubbedPaymentProcessor
end
```

## 🎨 Alternative DSL Styles

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

### 🏗️ Full-Stack DI Example

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

## 🧪 Testing

Run the test-suite with:

```bash
bundle exec rspec
```

HatiOperation is fully covered by RSpec. See `spec/` for reference examples including stubbed services and DI.

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub. Please:

1. Fork the project and create your branch from `main`
2. Run `bundle exec rspec` to ensure tests pass
3. Submit a pull request with a clear description of your changes

## 📄 License

HatiOperation is released under the MIT License.
