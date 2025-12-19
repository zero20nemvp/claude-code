---
name: rails-solid-stack
description: Use when implementing background jobs (Solid Queue), caching (Solid Cache), or WebSockets (Solid Cable) in Rails 8. Ensures proper patterns for the new default infrastructure.
triggers:
  - Background jobs
  - Solid Queue
  - Caching
  - Solid Cache
  - WebSockets
  - Solid Cable
  - Action Cable
  - ActiveJob
---

# Rails Solid Stack Skill

**Auto-activates when task involves Solid Queue, Solid Cache, or Solid Cable.**

Rails 8 introduces the "Solid" stack - database-backed alternatives to Redis for queues, cache, and WebSockets. This skill ensures proper patterns for production-ready implementations.

## The Solid Stack

| Component | Replaces | Purpose |
|-----------|----------|---------|
| **Solid Queue** | Sidekiq/Resque | Background job processing |
| **Solid Cache** | Redis cache | Application caching |
| **Solid Cable** | Redis pub/sub | WebSocket messaging |

**Key benefit:** No external dependencies - just your database.

## Solid Queue

### Configuration

```yaml
# config/queue.yml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 5
      polling_interval: 0.1

development:
  <<: *default

production:
  <<: *default
  workers:
    - queues: [critical, default]
      threads: 10
    - queues: [low]
      threads: 3
```

### TDD for Jobs

```ruby
# spec/jobs/send_welcome_email_job_spec.rb
RSpec.describe SendWelcomeEmailJob, type: :job do
  # Happy case FIRST
  it 'sends welcome email to user' do
    user = create(:user)

    expect {
      described_class.perform_now(user.id)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
  end

  # Essential sad cases
  it 'raises when user not found' do
    expect {
      described_class.perform_now(999999)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'skips already-welcomed users' do
    user = create(:user, welcomed_at: 1.day.ago)

    expect {
      described_class.perform_now(user.id)
    }.not_to change { ActionMailer::Base.deliveries.count }
  end

  # Queue configuration
  it 'uses default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'is enqueued' do
    user = create(:user)

    expect {
      described_class.perform_later(user.id)
    }.to have_enqueued_job(described_class).with(user.id)
  end
end
```

### Job Implementation

```ruby
# app/jobs/send_welcome_email_job.rb
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordNotFound, wait: 5.seconds, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(user_id)
    user = User.find(user_id)
    return if user.welcomed_at.present?

    UserMailer.welcome(user).deliver_now
    user.update!(welcomed_at: Time.current)

    Rails.logger.info("Welcome email sent", user_id: user_id)
  end
end
```

### Queue Priority

```ruby
# Critical jobs - payment, auth
class ProcessPaymentJob < ApplicationJob
  queue_as :critical
end

# Default jobs - emails, notifications
class SendNotificationJob < ApplicationJob
  queue_as :default
end

# Low priority - reports, cleanup
class GenerateReportJob < ApplicationJob
  queue_as :low
end
```

### RBS for Jobs

```rbs
# sig/app/jobs/send_welcome_email_job.rbs
class SendWelcomeEmailJob < ApplicationJob
  def perform: (Integer user_id) -> void
end
```

## Solid Cache

### Configuration

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

```yaml
# config/solid_cache.yml
default: &default
  database: cache
  store_options:
    max_age: <%= 1.week.to_i %>
    max_size: <%= 256.megabytes %>

production:
  <<: *default
  store_options:
    max_age: <%= 1.month.to_i %>
    max_size: <%= 1.gigabyte %>
```

### TDD for Caching

```ruby
# spec/models/user_spec.rb
RSpec.describe User do
  describe '#expensive_calculation' do
    it 'caches the result' do
      user = create(:user)

      # First call - computes
      expect(ExpensiveService).to receive(:compute).once.and_return(42)

      result1 = user.expensive_calculation
      result2 = user.expensive_calculation  # Should use cache

      expect(result1).to eq(42)
      expect(result2).to eq(42)
    end

    it 'expires cache after 1 hour' do
      user = create(:user)
      allow(ExpensiveService).to receive(:compute).and_return(42, 100)

      user.expensive_calculation

      travel 2.hours do
        expect(user.expensive_calculation).to eq(100)
      end
    end

    it 'invalidates on update' do
      user = create(:user)
      allow(ExpensiveService).to receive(:compute).and_return(42, 100)

      user.expensive_calculation
      user.update!(name: 'New Name')

      expect(user.expensive_calculation).to eq(100)
    end
  end
end
```

### Cache Implementation

```ruby
# app/models/user.rb
class User < ApplicationRecord
  after_update :invalidate_cache

  def expensive_calculation
    Rails.cache.fetch(cache_key_for(:expensive), expires_in: 1.hour) do
      ExpensiveService.compute(self)
    end
  end

  private

  def cache_key_for(method)
    "#{cache_key_with_version}/#{method}"
  end

  def invalidate_cache
    Rails.cache.delete(cache_key_for(:expensive))
  end
end
```

### Fragment Caching

```erb
<%# app/views/posts/show.html.erb %>
<% cache @post do %>
  <article>
    <h1><%= @post.title %></h1>
    <%= @post.body %>

    <% cache [@post, :comments] do %>
      <%= render @post.comments %>
    <% end %>
  </article>
<% end %>
```

### Russian Doll Caching

```erb
<% cache @post do %>
  <article>
    <h1><%= @post.title %></h1>

    <% @post.comments.each do |comment| %>
      <% cache comment do %>
        <%= render comment %>
      <% end %>
    <% end %>
  </article>
<% end %>
```

## Solid Cable

### Configuration

```yaml
# config/cable.yml
development:
  adapter: solid_cable
  polling_interval: 0.1.seconds

production:
  adapter: solid_cable
  polling_interval: 1.second
  message_retention: 1.day
```

### TDD for Channels

```ruby
# spec/channels/chat_channel_spec.rb
RSpec.describe ChatChannel, type: :channel do
  let(:user) { create(:user) }
  let(:room) { create(:room) }

  before do
    stub_connection current_user: user
  end

  # Happy case FIRST
  it 'subscribes to room stream' do
    subscribe(room_id: room.id)

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(room)
  end

  # Essential sad cases
  it 'rejects unauthenticated users' do
    stub_connection current_user: nil

    subscribe(room_id: room.id)

    expect(subscription).to be_rejected
  end

  it 'rejects unauthorized room access' do
    private_room = create(:room, :private)

    subscribe(room_id: private_room.id)

    expect(subscription).to be_rejected
  end

  it 'broadcasts messages to room' do
    subscribe(room_id: room.id)

    expect {
      perform :speak, message: 'Hello!'
    }.to have_broadcasted_to(room)
      .with(hash_including(body: 'Hello!', user: user.name))
  end
end
```

### Channel Implementation

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find(params[:room_id])

    if current_user&.can_access?(@room)
      stream_for @room
    else
      reject
    end
  end

  def speak(data)
    message = @room.messages.create!(
      user: current_user,
      body: data['message']
    )

    ChatChannel.broadcast_to(@room, {
      body: message.body,
      user: current_user.name,
      created_at: message.created_at.iso8601
    })
  end

  def unsubscribed
    # Cleanup if needed
  end
end
```

### Connection Setup

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if (user = User.find_by(id: cookies.encrypted[:user_id]))
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

### RBS for Channels

```rbs
# sig/app/channels/chat_channel.rbs
class ChatChannel < ApplicationCable::Channel
  @room: Room

  def subscribed: () -> void
  def speak: (Hash[String, untyped] data) -> void
  def unsubscribed: () -> void
end
```

## Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| Using Redis when Solid works | Start with Solid, upgrade only if needed |
| Long-running jobs blocking queue | Split into smaller jobs, use dedicated queues |
| Caching ActiveRecord objects | Cache primitives or serializable data |
| No cache invalidation strategy | Use versioned cache keys, after_commit hooks |
| Synchronous broadcasts in request | Use async jobs for heavy broadcasts |
| Missing job idempotency | Design jobs to be safely re-runnable |

## Verification Checklist

Before `/done` on a Solid Stack task:

- [ ] Job tests cover happy path first
- [ ] Job tests cover retry/failure scenarios
- [ ] Cache tests verify expiration behavior
- [ ] Cache tests verify invalidation
- [ ] Channel tests verify subscription/broadcast
- [ ] Queue configuration appropriate for workload
- [ ] Cache size limits configured
- [ ] RBS types for all jobs/channels
- [ ] Logging/monitoring hooks in place (full phat tier)
- [ ] Jobs are idempotent (safe to retry)

## Quick Reference

### Job Lifecycle

```ruby
class MyJob < ApplicationJob
  queue_as :default

  # Retry configuration
  retry_on SomeError, wait: :exponentially_longer, attempts: 5
  discard_on UnrecoverableError

  # Callbacks
  before_perform :setup
  after_perform :cleanup
  around_perform :with_logging

  def perform(args)
    # Job logic
  end

  private

  def with_logging
    Rails.logger.info("Starting #{self.class.name}")
    yield
    Rails.logger.info("Completed #{self.class.name}")
  end
end
```

### Cache Patterns

```ruby
# Basic fetch
Rails.cache.fetch("key", expires_in: 1.hour) { expensive_operation }

# Conditional caching
Rails.cache.fetch("key", expires_in: 1.hour, skip_nil: true) { maybe_nil_result }

# Manual invalidation
Rails.cache.delete("key")
Rails.cache.delete_matched("user:*")  # Pattern matching

# Versioned keys (auto-invalidate on model changes)
Rails.cache.fetch(@user) { @user.expensive_data }
```
