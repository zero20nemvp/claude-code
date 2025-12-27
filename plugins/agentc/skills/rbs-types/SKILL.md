---
name: rbs-types
description: Use when adding or updating Ruby code to ensure proper RBS type signatures. Covers type syntax, validation, and integration with Steep for static type checking. Auto-activates for Ruby projects.
triggers:
  - Ruby code
  - RBS types
  - Type signatures
  - Type checking
  - Steep
---

# RBS Types Skill

**Auto-activates when working on Ruby code requiring type signatures.**

RBS (Ruby Signature) provides type definitions for Ruby code. This skill ensures proper type coverage for all production Ruby code.

## RBS Basics

### File Structure

```
app/
  models/
    user.rb
  services/
    order_processor.rb
sig/
  app/
    models/
      user.rbs
    services/
      order_processor.rbs
```

**Convention:** RBS files mirror the source tree under `sig/`.

### Basic Syntax

```rbs
# sig/app/models/user.rbs
class User < ApplicationRecord
  attr_reader name: String
  attr_reader email: String
  attr_reader created_at: Time

  def full_name: () -> String
  def send_notification: (String message) -> bool
  def posts: () -> ActiveRecord::Relation[Post]
end
```

### Method Signatures

```rbs
# No arguments, returns String
def name: () -> String

# Required argument
def greet: (String name) -> String

# Optional argument
def greet: (?String name) -> String

# Keyword arguments
def create: (name: String, email: String, ?admin: bool) -> User

# Block
def each: () { (Item) -> void } -> void

# Union types
def find: (Integer | String id) -> User?

# Nilable return
def find_by_email: (String email) -> User?
```

### Common Types

```rbs
# Collections
Array[String]
Hash[Symbol, String]
Set[Integer]

# ActiveRecord
ActiveRecord::Relation[User]
ActiveRecord::Associations::CollectionProxy[Post]

# Rails types
ActionController::Parameters
ActiveSupport::TimeWithZone

# Generics
def wrap: [T] (T value) -> Array[T]
```

## TDD with RBS

### Write Types BEFORE Implementation

Following TDD principles, define types as part of design:

```rbs
# 1. RED: Define the interface in RBS
# sig/app/services/order_calculator.rbs
class OrderCalculator
  def initialize: (Order order) -> void
  def total: () -> BigDecimal
  def tax: () -> BigDecimal
  def discount: () -> BigDecimal
end
```

```ruby
# 2. Write failing test
RSpec.describe OrderCalculator do
  it 'calculates total' do
    order = create(:order, items: [create(:item, price: 100)])
    calculator = OrderCalculator.new(order)

    expect(calculator.total).to eq(BigDecimal('100'))
  end
end
```

```ruby
# 3. GREEN: Implement to pass
class OrderCalculator
  def initialize(order)
    @order = order
  end

  def total
    @order.items.sum(&:price)
  end
end
```

### Validate Types

```bash
# Validate RBS syntax
bundle exec rbs validate

# Type check with Steep
bundle exec steep check
```

## Rails-Specific Patterns

### Models

```rbs
# sig/app/models/user.rbs
class User < ApplicationRecord
  # Attributes (from schema)
  attr_reader id: Integer
  attr_reader name: String
  attr_reader email: String
  attr_reader created_at: ActiveSupport::TimeWithZone
  attr_reader updated_at: ActiveSupport::TimeWithZone

  # Associations
  def posts: () -> ActiveRecord::Associations::CollectionProxy[Post]
  def profile: () -> Profile?

  # Scopes
  def self.active: () -> ActiveRecord::Relation[User]
  def self.by_email: (String email) -> ActiveRecord::Relation[User]

  # Class methods
  def self.find_by_email!: (String email) -> User

  # Instance methods
  def full_name: () -> String
  def admin?: () -> bool
end
```

### Controllers

```rbs
# sig/app/controllers/users_controller.rbs
class UsersController < ApplicationController
  def index: () -> void
  def show: () -> void
  def create: () -> void
  def update: () -> void
  def destroy: () -> void

  private
  def user_params: () -> ActionController::Parameters
  def set_user: () -> void
end
```

### Services

```rbs
# sig/app/services/payment_processor.rbs
class PaymentProcessor
  class PaymentError < StandardError
  end

  def initialize: (Order order, PaymentMethod payment_method) -> void
  def process!: () -> PaymentResult
  def refund!: (BigDecimal amount) -> RefundResult

  private
  def validate_order: () -> void
  def charge_payment_method: () -> bool
end

class PaymentResult
  attr_reader success: bool
  attr_reader transaction_id: String?
  attr_reader error: String?
end
```

### Jobs

```rbs
# sig/app/jobs/send_email_job.rbs
class SendEmailJob < ApplicationJob
  def perform: (Integer user_id, String template) -> void
end
```

### Channels (Action Cable)

```rbs
# sig/app/channels/chat_channel.rbs
class ChatChannel < ApplicationCable::Channel
  def subscribed: () -> void
  def speak: (Hash[String, untyped] data) -> void
end
```

## Steep Configuration

```yaml
# Steepfile
target :app do
  signature "sig"

  check "app/models"
  check "app/controllers"
  check "app/services"
  check "app/jobs"

  # Ignore generated files
  ignore "app/models/application_record.rb"

  library "activesupport"
  library "activerecord"
  library "actionpack"
end
```

## Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| `untyped` everywhere | Define proper types |
| Missing nil handling | Use `Type?` for nilable |
| No RBS for new code | Add RBS as part of TDD |
| Types after implementation | Define interface in RBS first |
| Inconsistent naming | Mirror source structure exactly |
| Overly complex union types | Simplify the interface |

## Verification Checklist

Before `/done` on Ruby code:

- [ ] All new classes have RBS signatures in `sig/`
- [ ] All public methods have type signatures
- [ ] `bundle exec rbs validate` passes
- [ ] `bundle exec steep check` passes (if configured)
- [ ] Nilable returns properly marked with `?`
- [ ] No `untyped` without documented reason
- [ ] RBS files mirror source tree structure

## RBS Gate Enforcement

The `/done` command enforces RBS requirements for Ruby projects:

```
=== RBS Type Gate ===
✓ All .rb files have .rbs signatures
✓ RBS validation passed
✓ Steep type check passed

RBS Requirements: PASSED
```

**Blocked example:**
```
BLOCKED: RBS type requirements not satisfied.

Missing signatures:
- app/services/order_processor.rb → needs sig/app/services/order_processor.rbs
- app/models/payment.rb → needs sig/app/models/payment.rbs

Run /do to add missing RBS types before /done.
```

**This is STRICT enforcement.** All production Ruby code requires RBS types.

## Quick Reference

### Creating a New Class

1. Create RBS signature first:
```rbs
# sig/app/services/foo.rbs
class Foo
  def initialize: (String name) -> void
  def call: () -> Result
end
```

2. Write test:
```ruby
RSpec.describe Foo do
  it 'returns result' do
    expect(Foo.new('test').call).to be_a(Result)
  end
end
```

3. Implement:
```ruby
class Foo
  def initialize(name)
    @name = name
  end

  def call
    Result.new(success: true)
  end
end
```

4. Validate:
```bash
bundle exec rbs validate && bundle exec steep check
```
