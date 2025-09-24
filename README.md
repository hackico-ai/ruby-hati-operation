# HatiOperation

[![Gem Version](https://badge.fury.io/rb/hati_operation.svg)](https://rubygems.org/gems/hati_operation)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

HatiOperation is a next-generation Ruby toolkit that brings agent-oriented architecture to your applications. While powerful for traditional service orchestration, it's specifically designed to excel in modern AI-augmented development environments like GitHub Copilot, Cursor, and autonomous agent systems.

## Table of Contents

- [Core Design Philosophy](#core-design-philosophy)
- [Architectural Patterns](#architectural-patterns)
- [Quick Start](#quick-start)
  - [Traditional Service Operation](#traditional-service-operation)
  - [AI Agent Operation](#ai-agent-operation)
  - [Copilot-Optimized Operation](#copilot-optimized-operation)
- [Key Features for Modern Development](#key-features-for-modern-development)
  - [Agent-Ready Architecture](#agent-ready-architecture)
  - [AI Development Acceleration](#ai-development-acceleration)
  - [Traditional Strengths](#traditional-strengths)
- [Advanced Usage](#advanced-usage)
  - [Agent Tool Integration](#agent-tool-integration)
  - [AI Assistant Integration](#ai-assistant-integration)
- [Development Workflow Integration](#development-workflow-integration)
  - [With Cursor](#with-cursor)
  - [With GitHub Copilot](#with-github-copilot)
  - [With Autonomous Agents](#with-autonomous-agents)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Core Design Philosophy

HatiOperation implements the Agent-Oriented Programming (AOP) paradigm, making it ideal for:

- **Traditional Service Composition** – Robust orchestration for standard business operations
- **AI Integration** – Perfect for building autonomous agent systems and AI-powered services
- **Agentic Friendly Architecture** – Structured for optimal interaction with AI coding assistants
- **Rapid AI Development** – Seamless integration of ML models and AI services

## Architectural Patterns

HatiOperation serves as a universal orchestrator, equally capable in traditional and AI-augmented contexts:

```
┌─────────────────────────────────────────────────────────────┐
│                    HatiOperation                            │
│            (Universal Service Orchestrator)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Traditional Services        AI/Agent Services              │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  Business   │            │   Agent     │                 │
│  │  Logic      │            │   Actions   │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  Data       │            │   Model     │                 │
│  │  Access     │            │   Inference │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
│  ┌─────────────┐            ┌─────────────┐                 │
│  │  External   │            │   Tool      │                 │
│  │  Services   │            │   Calls     │                 │
│  └─────────────┘            └─────────────┘                 │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                   hati-command                              │
│                 (Foundation Layer)                          │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### Traditional Service Operation

```ruby
# Standard business logic operation
class Order::Operation::Create < HatiOperation::Base
  def call(params:)
    validated = step OrderValidator.call(params)
    order = step create_order(validated)
    notify_success(order)

    Success(order)
  end
end
```

### AI Agent Operation

```ruby
# AI agent action orchestration
class Agent::Operation::ExecuteAction < HatiOperation::Base
  def call(params:)
    # Parse and validate agent intent
    intent = step IntentParser.call(params[:instruction])

    # Load relevant tools
    tools = step ToolRegistry.load(intent.required_tools)

    # Execute action with safety checks
    result = step SafeExecutor.call(tools, intent)

    # Log and analyze execution
    step ActionAnalyzer.call(result)

    Success(result)
  end
end
```

### Copilot-Optimized Operation

```ruby
# Structured for optimal AI assistant interaction
class AIAssisted::Operation::GenerateCode < HatiOperation::Base
  # Clear step definitions help AI understand the flow
  step validator: InputValidator
  step analyzer: CodeAnalyzer
  step generator: CodeGenerator
  step tester: CodeTester

  def call(params:)
    # Structured for easy AI completion
    spec = step validator.call(params[:specification])
    context = step analyzer.call(params[:codebase])

    code = step generator.call(spec, context)
    result = step tester.call(code)

    Success(result)
  end
end
```

## Key Features

<table>
<tr>
  <th width="25%" align="left">Category</th>
  <th width="35%" align="left">Feature</th>
  <th width="40%" align="left">Description</th>
</tr>

<tr>
  <td rowspan="4"><b>Agent-Ready Architecture</b></td>
  <td>Tool Registration</td>
  <td>Easily register and manage agent tools</td>
</tr>
<tr>
  <td>Safety Boundaries</td>
  <td>Built-in guardrails for agent actions</td>
</tr>
<tr>
  <td>Action Composition</td>
  <td>Chain multiple agent actions safely</td>
</tr>
<tr>
  <td>State Management</td>
  <td>Track and manage agent state</td>
</tr>

<tr><td colspan="3">&nbsp;</td></tr>

<tr>
  <td rowspan="4"><b>AI Development Acceleration</b></td>
  <td>Structured Patterns</td>
  <td>Clear patterns for AI tools to understand</td>
</tr>
<tr>
  <td>Predictable Flow</td>
  <td>Consistent operation structure</td>
</tr>
<tr>
  <td>Self-Documenting</td>
  <td>Clear step definitions aid AI comprehension</td>
</tr>
<tr>
  <td>Context Awareness</td>
  <td>Easy access to operation context</td>
</tr>

<tr><td colspan="3">&nbsp;</td></tr>

<tr>
  <td rowspan="4"><b>Traditional Strengths</b></td>
  <td>Service Orchestration</td>
  <td>Compose complex business operations</td>
</tr>
<tr>
  <td>Error Handling</td>
  <td>Sophisticated failure management</td>
</tr>
<tr>
  <td>Dependency Injection</td>
  <td>Flexible service composition</td>
</tr>
<tr>
  <td>Transaction Safety</td>
  <td>Atomic operation guarantees</td>
</tr>
</table>

## Advanced Usage

### Agent Tool Integration

```ruby
class Agent::Tool::DatabaseQuery < HatiOperation::Base
  # Register tool capabilities
  tool_capability :query_database
  tool_safety_level :read_only

  def call(params:)
    query = step QueryValidator.call(params[:query])
    result = step SafeQueryExecutor.call(query)
    Success(result)
  end
end
```

### AI Assistant Integration

```ruby
class Assistant::Operation::CodeReview < HatiOperation::Base
  # Structured for AI assistant comprehension
  step analyzer: CodeAnalyzer
  step reviewer: CodeReviewer
  step formatter: ReviewFormatter

  def call(params:)
    analysis = step analyzer.call(params[:code])
    review = step reviewer.call(analysis)
    formatted = step formatter.call(review)

    Success(formatted)
  end
end
```

## Development Workflow Integration

### With Cursor

- Clear operation structure helps Cursor understand code context
- Consistent patterns improve code completion quality
- Structured error handling aids debugging suggestions

### With GitHub Copilot

- Predictable operation flow improves suggestions
- Clear step definitions enhance code generation
- Consistent patterns aid in test generation

### With Autonomous Agents

- Built-in tool registration system
- Safety-first execution patterns
- Clear state management

## Testing

Comprehensive testing support for all operation types:

```ruby
RSpec.describe Agent::Operation::ExecuteAction do
  it "safely executes agent actions" do
    result = described_class.call(instruction: "query users") do
      # Mock agent tools
      step executor: SafeExecutorStub
      step analyzer: ActionAnalyzerStub
    end

    expect(result).to be_success
  end
end
```

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
