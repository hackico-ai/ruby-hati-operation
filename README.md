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

Here is a simple example of how to use HatiOperation in rapid isolated Rails API development:

- mainly used as Result unpacker

```ruby
# Rails API controller
class Api::V1::WithdrawalController
  def create
    result = Withdrawal::Operation::Create.call(params.to_unsafe_h)

    if result.success?
      render json: TransferSerializer.new.serioalize(result.success), status: 201
    else
      api_error = APiError.new .map(result.value)
      render json: api_error.to_json, status: api_error.status
    end
  end
end

# Base API operation class
class ApiOperation
  operation do
    unexpected_err ApiErr.call(500)
  end
end

# API controller
class Withdrawal::Operation::Create < ApiOperation
  ar_transaction :funds_transfer_transaction!

  def call(raw_params)
    params = step MyApiContract.call(raw_params), err: ApiErr.call(422)
    transfer = step funds_transfer_transaction(params[:account_id])
    EventBroadcast.new.stream(transfer.to_event)

    transfer.meta
  end

  def funds_transfer_transaction(acc_id)
    acc = Account.find_by(find_by: acc_id).presence : Failure!(err: ApiErr.call(404))

    withdrawal = step WithdrawalService.call(acc), err: ApiErr.cal(409)
    transfer = step ProcessTransferService.call(withdrawal), err: ApiErr.call(503)

    Success(transfer)
  end
end

```

## Using Dependency Injection (DI)

```ruby
class Api::V2::WithdrawalController
  def create
    run_and_render Withdrawal::Operation::Create.call(params.to_unsafe_h), status: 201  do
      step broadcast: API::V2::BroadcastService, err: SpecialNewApiError
      step transfer: API::V2::PaymentProcessorService
      step serializer: ExtendedTransferSerializer

      # if result re-mapping is needed
      on_failure V2::API::Error
    end
  end

  private

  def run_and_render(result)
   rpepare_result = JsonResult.new(value)

   render json: result.data, status: result.status
  end
end

class Withdrawal::Operation::Create < ApiOperation
  ar_transaction :funds_transfer_transaction!

  step validation: MyApiContract
  step withdrawal: WithdrawalService
  step transfer: ProcessTransferService
  step broadcast: BroadcastService
  step serializer: TransferSerializer

  def call(raw_params)
    params = step validation.call(raw_params), err: ApiErr.call(422)
    transfer = step funds_transfer_transaction(params[:account_id])
    broadcast.new.stream(transfer.to_event)

    serializer.call(transfer.meta)
  end

  def funds_transfer_transaction!(acc_id)
    acc = find_acc!(acc_id)

    withdrawal = step withdrawal.call(acc), err: ApiErr.cal(409)
    transfer = step transfer.call(withdrawal), err: ApiErr.call(503)

    Success(transfer)
  end

  def find_acc!
    Account.find_by(find_by: acc_id).presence : Failure!(err: ApiErr.call(404))
  end
end
```

## Here is more DSL-ish example of usage

```ruby
  def create
    run_and_render Withdrawal::Operation::Create
  end

  private

  def unsafe_params = params.to_unsafe_h

  def run_and_render(operation, &block)
   result = operation.call(unsafe_params).value

   render json: result.data, status: result.status[:status]
  end

class Withdrawal::Operation::Create < ApiOperation
  on_call CreateContract, err: ApiErr.call(422)
  on_success TransferSerializer, status: 201

  ar_transaction :funds_transfer_transaction!

  step withdrawal: WithdrawalService, err: ApiErr.cal(409)
  step transfer: ProcessTransferService, err: ApiErr.call(503)
  step broadcast: BroadcastService

  def call(params:)
    transfer = step funds_transfer_transaction(params[:account_id])
    broadcast.new.stream(transfer.to_event)
    transfer.meta
  end

  def funds_transfer_transaction!(acc_id)
    acc = step { Account.find(acc_id) }, err: ApiErr.call(404)
    withdrawal = step withdrawal.call(acc)
    transfer = step transfer.call(withdrawal)
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
