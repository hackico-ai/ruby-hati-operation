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

Here is a simple example of how to use HatiOperation in api development:

```ruby
class MyApiOperation < HatiOperation::Base
  operation do
    unexpected_err ApiErr.cal(500)
    ar_transaction :funds_transfer
  end

  step user_account: AccountService
  step broadcast: BroadcastService
  step withdrawal: WithdrawalService
  step transfer: ProcessTransferService

  def call(params)
    transfer = step funds_transfer(params[:account_id])
    broadcast.call(transfer.to_event)

    account
  end

  def funds_transfer_transaction(acc_id)
    acc = step user_account.call(acc_id), err: ApiErr.cal(404)
    withdrawal = step withdrawal.call(acc), err: ApiErr.cal(409)
    transfer = transfer.call(withdrawal), err: ApiErr.cal(503)

    Success(transfer)
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
