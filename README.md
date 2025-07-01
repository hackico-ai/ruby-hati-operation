# HatiOperation

HatiOperation is a Ruby library designed to facilitate the creation of operations with a focus on step-based execution and dependency injection. It provides a simple and intuitive way to define operations, manage configurations, and handle results.

## Features

- Implicit result return
- Object-level step for unpacking values
- Forced logical transactional behavior with fail-fast on failure
- Class-level macros for dependency injection

## Installation

To install HatiOperation, add the following line to your Gemfile:

```ruby
gem 'hati_operation'
```

Then run:

```bash
bundle install
```

## Usage

Here is a simple example of how to use HatiOperation in rapid isolated api development:

```ruby
class Api::V1::WithdrawalController
  def index
    run_and_render Withdrawal::Operation::Create.call(unsafe_params)
  end
end

class ApiOperation
  operation do
    unexpected_err ApiErr.call(500)
  end
end

class Withdrawal::Operation::Create < HatiOperation::Base
  on_call CreateContract, err: ApiErr.call(422)
  on_success TransferSerializer

  ar_transaction :funds_transfer_transaction!

  step broadcast: BroadcastService
  step withdrawal: WithdrawalService
  step transfer: ProcessTransferService

  def call(params:)
    transfer = step funds_transfer_transaction(params[:account_id])
    broadcast.call(transfer.to_event)
    transfer.meta
  end

  def funds_transfer_transaction!(acc_id)
    acc = step { Account.find(acc_id) }, err: ApiErr.cal(404)
    withdrawal = step withdrawal.call(acc), err: ApiErr.cal(409)
    transfer = step transfer.call(withdrawal), err: ApiErr.call(503)
    Success(transfer)
  end
end
```

#### NOTE: Using Dependency Injection (DI)

```ruby
class Api::V2::WithdrawalController
  def index
    run_and_render Withdrawal::Operation::Create.call(unsafe_params) do
      step broadcast: API::V2::BroadcastService, err: SpecialNewApiError
      step transfer: API::V2::PaymentProcessorService

      on_success ApiErrMap
      on_failure V2::ApiErrMap # in case of re-mapping
    end
  end
end
```

## Testing

To run the tests for HatiOperation, use the following command:

```bash
rspec
```

Make sure you have RSpec installed and configured in your project.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
