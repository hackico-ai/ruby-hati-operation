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

Here is a simple example of how to use HatiOperation:

```ruby
class MyApiOperation < HatiOperation::Base
  operation do
    unexpected_err JsonApiErrors::UnexpectredError
    ar_transaction :funds_transfer
  end

  step user_account: AccountService
  step broadcast: BroadcastService

  def call(params)
    transfer = step withdaral(account)
    broadcast.call(transfer)

    account
  end

  def funds_transfer(account)
    account = step user_account.call(params[:account_id])
    withdrawal = step WithdrawalService.call(account)
    transfer = ProcessTransferService.call(withdrawal)
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
