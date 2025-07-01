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
class Withdrawal::Operation::Create < HatiOperation::Base
  operation do
    unexpected_err ApiErr.call(500)
    ar_transaction :funds_transfer
  end

  step validation: MyApiContract
  step broadcast: BroadcastService
  step withdrawal: WithdrawalService
  step transfer: ProcessTransferService
  step serializer: MyApiSerializer

  def call(raw_params)
    params = step validation.call(validation), err: ApiErr.call(422)
    transfer = step funds_transfer_transaction(params[:account_id])
    broadcast.call(transfer.to_event)

    serializer.call(transfer.meta)
  end

  def funds_transfer_transaction(acc_id)
    acc = find_acc!(acc_id)
    withdrawal = step err: ApiErr.cal(409)
    withdrawal.call(acc),
    transfer = step transfer.call(withdrawal), err: ApiErr.call(503)

    Success(transfer)
  end

  # NOTE: also supports block evaluetion
  # same as: step { Account.find(acc_id) }, err: ApiErr.cal(404)
  def find_acc!
    Account.find_by(find_by: acc_id).presence : Failure!(err: ApiErr.call(404))
  end
end

class Api::V1::WithdrawalController
  def index
    run_and_render Withdrawal::Operation::Create.call(unsafe_params)
  end
end

# e.g. Using Dependency Injection (DI)
class Api::V2::WithdrawalController
  def index
    run_and_render Withdrawal::Operation::Create.call(unsafe_params) do
      step broadcast: API::V2::BroadcastService
      step transfer: API::V2::PaymentProcessorService
      step serializer: API::V2::MyApiSerializer
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
