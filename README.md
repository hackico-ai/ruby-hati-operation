# HatiOperation

[![Gem Version](https://badge.fury.io/rb/hati_operation.svg)](https://rubygems.org/gems/hati_operation)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

HatiOperation is a next-generation Ruby toolkit that brings agent-oriented architecture to your applications. While powerful for traditional service orchestration, it's specifically designed to excel in modern AI-augmented development environments like GitHub Copilot, Cursor, and autonomous agent systems.

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

## Key Features for Modern Development

### Agent-Ready Architecture

- **Tool Registration** – Easily register and manage agent tools
- **Safety Boundaries** – Built-in guardrails for agent actions
- **Action Composition** – Chain multiple agent actions safely
- **State Management** – Track and manage agent state

### AI Development Acceleration

- **Structured Patterns** – Clear patterns for AI tools to understand
- **Predictable Flow** – Consistent operation structure
- **Self-Documenting** – Clear step definitions aid AI comprehension
- **Context Awareness** – Easy access to operation context

### Traditional Strengths

- **Service Orchestration** – Compose complex business operations
- **Error Handling** – Sophisticated failure management
- **Dependency Injection** – Flexible service composition
- **Transaction Safety** – Atomic operation guarantees

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

## Contributing

We welcome contributions! Please:

1. Fork the project
2. Create your feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit a PR with clear description

## License

HatiOperation is available under the MIT License.
