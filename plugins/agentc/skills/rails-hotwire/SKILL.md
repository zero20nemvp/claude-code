---
name: rails-hotwire
description: Use when implementing real-time UI features in Rails 8 using Hotwire (Turbo Frames, Turbo Streams, Stimulus). Ensures proper patterns for modern Rails frontend without heavy JavaScript.
triggers:
  - Turbo Frames
  - Turbo Streams
  - Stimulus controllers
  - Real-time updates
  - SPA-like behavior
  - Hotwire
---

# Rails Hotwire Skill

**Auto-activates when task involves Hotwire/Turbo/Stimulus work.**

This skill ensures proper implementation of Rails 8's Hotwire stack for modern, reactive UIs without heavy JavaScript frameworks.

## Hotwire Components

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| **Turbo Drive** | SPA-like navigation | Default - automatic |
| **Turbo Frames** | Partial page updates | Scoped updates, modals, inline editing |
| **Turbo Streams** | Real-time broadcasts | Live updates, WebSocket-driven changes |
| **Stimulus** | JavaScript sprinkles | DOM manipulation, form enhancement |

## TDD with Hotwire

### Testing Turbo Frames

```ruby
# spec/system/comments_spec.rb
RSpec.describe 'Comments', type: :system do
  it 'loads comments in turbo frame' do
    post = create(:post)
    create(:comment, post: post, body: 'Test comment')

    visit post_path(post)

    within_turbo_frame('comments') do
      expect(page).to have_content('Test comment')
    end
  end

  it 'adds comment without full page reload' do
    post = create(:post)
    visit post_path(post)

    within_turbo_frame('new_comment') do
      fill_in 'Body', with: 'New comment'
      click_button 'Submit'
    end

    expect(page).to have_content('New comment')
    expect(page).not_to have_current_path(comments_path)  # No redirect
  end
end
```

### Testing Turbo Streams

```ruby
# spec/requests/comments_spec.rb
RSpec.describe 'Comments', type: :request do
  it 'returns turbo stream on create' do
    post_record = create(:post)

    post post_comments_path(post_record),
      params: { comment: { body: 'New comment' } },
      headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    expect(response.body).to include('turbo-stream')
    expect(response.body).to include('action="append"')
    expect(response.body).to include('target="comments"')
  end

  it 'broadcasts to subscribers' do
    post_record = create(:post)

    expect {
      post post_comments_path(post_record),
        params: { comment: { body: 'New comment' } }
    }.to have_broadcasted_to(post_record).with(a_hash_including(
      action: 'append'
    ))
  end
end
```

### Testing Stimulus Controllers

```ruby
# spec/system/form_validation_spec.rb
RSpec.describe 'Form validation', type: :system, js: true do
  it 'validates email in real-time' do
    visit new_user_path

    fill_in 'Email', with: 'invalid'
    find('body').click  # Trigger blur

    expect(page).to have_css('[data-validation-target="error"]', text: 'Invalid email')
  end

  it 'enables submit when valid' do
    visit new_user_path

    fill_in 'Email', with: 'valid@example.com'
    find('body').click

    expect(page).to have_button('Submit', disabled: false)
  end
end
```

## Turbo Frame Patterns

### Basic Frame

```erb
<%# app/views/posts/show.html.erb %>
<turbo-frame id="comments">
  <%= render @comments %>
</turbo-frame>

<%= link_to 'Load More', post_comments_path(@post, page: 2),
  data: { turbo_frame: 'comments' } %>
```

### Lazy Loading

```erb
<%# Loads content when frame enters viewport %>
<turbo-frame id="stats" src="<%= stats_path %>" loading="lazy">
  <p>Loading stats...</p>
</turbo-frame>
```

### Modal Pattern

```erb
<%# Frame that breaks out to modal %>
<turbo-frame id="modal"></turbo-frame>

<%= link_to 'Edit', edit_post_path(@post),
  data: { turbo_frame: 'modal' } %>

<%# In edit.html.erb %>
<turbo-frame id="modal">
  <dialog open data-controller="modal">
    <%= form_with model: @post, data: { action: 'turbo:submit-end->modal#close' } do |f| %>
      <%= f.text_field :title %>
      <%= f.submit 'Save' %>
    <% end %>
  </dialog>
</turbo-frame>
```

### Inline Editing

```erb
<turbo-frame id="<%= dom_id(post) %>">
  <article>
    <h2><%= post.title %></h2>
    <%= link_to 'Edit', edit_post_path(post) %>
  </article>
</turbo-frame>

<%# edit.html.erb wraps form in same frame ID %>
<turbo-frame id="<%= dom_id(@post) %>">
  <%= form_with model: @post do |f| %>
    <%= f.text_field :title %>
    <%= f.submit %>
  <% end %>
</turbo-frame>
```

## Turbo Streams Patterns

### Broadcast from Model

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post

  after_create_commit -> { broadcast_append_to post }
  after_update_commit -> { broadcast_replace_to post }
  after_destroy_commit -> { broadcast_remove_to post }
end
```

### Controller Response

```ruby
# app/controllers/comments_controller.rb
def create
  @comment = @post.comments.build(comment_params)

  respond_to do |format|
    if @comment.save
      format.turbo_stream
      format.html { redirect_to @post }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

```erb
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append 'comments', @comment %>
<%= turbo_stream.update 'comment_form', partial: 'form', locals: { comment: Comment.new } %>
<%= turbo_stream.update 'comment_count', html: "#{@post.comments.count} comments" %>
```

### Stream Actions

| Action | Purpose |
|--------|---------|
| `append` | Add to end of target |
| `prepend` | Add to start of target |
| `replace` | Replace entire target |
| `update` | Replace target's innerHTML |
| `remove` | Remove target element |
| `before` | Insert before target |
| `after` | Insert after target |

## Stimulus Patterns

### Basic Controller

```javascript
// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  greet() {
    this.outputTarget.textContent = "Hello, Stimulus!"
  }
}
```

```erb
<div data-controller="hello">
  <button data-action="click->hello#greet">Greet</button>
  <span data-hello-target="output"></span>
</div>
```

### Form Validation Controller

```javascript
// app/javascript/controllers/validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error", "submit"]

  validate() {
    const email = this.inputTarget.value
    const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)

    this.errorTarget.textContent = valid ? "" : "Invalid email"
    this.errorTarget.hidden = valid
    this.submitTarget.disabled = !valid
  }
}
```

```erb
<div data-controller="validation">
  <%= f.email_field :email,
    data: {
      validation_target: 'input',
      action: 'blur->validation#validate'
    } %>
  <span data-validation-target="error" hidden></span>
  <%= f.submit data: { validation_target: 'submit' } %>
</div>
```

### Auto-submit Controller

```javascript
// app/javascript/controllers/auto_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }
}
```

```erb
<%= form_with url: search_path, method: :get, data: { controller: 'auto-submit' } do |f| %>
  <%= f.search_field :q, data: { action: 'input->auto-submit#submit' } %>
<% end %>
```

## Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| Using React/Vue for simple interactions | Use Stimulus |
| Full page reloads for partial updates | Use Turbo Frames |
| Polling for real-time updates | Use Turbo Streams + Action Cable |
| `data-turbo="false"` everywhere | Fix the actual problem |
| Huge Stimulus controllers | Split into focused controllers |
| Nested turbo frames with same ID | Use unique IDs |
| Missing frame fallback | Always have non-JS fallback |

## RBS Types for Hotwire

```rbs
# sig/app/controllers/comments_controller.rbs
class CommentsController < ApplicationController
  def index: () -> void
  def create: () -> void
  def update: () -> void
  def destroy: () -> void

  private
  def comment_params: () -> ActionController::Parameters
  def set_post: () -> void
end
```

## Verification Checklist

Before `/done` on a Hotwire task:

- [ ] Turbo Frames have unique IDs
- [ ] Turbo Streams use correct actions (append, prepend, replace, remove, update)
- [ ] Stimulus controllers follow naming conventions (`name_controller.js`)
- [ ] System specs test JavaScript behavior with `js: true`
- [ ] Request specs verify turbo-stream responses
- [ ] Progressive enhancement works (no-JS fallback)
- [ ] RBS types for controllers
- [ ] No console errors in browser

## Common Test Helpers

```ruby
# spec/support/turbo_helpers.rb
module TurboHelpers
  def within_turbo_frame(id, &block)
    within("turbo-frame##{id}", &block)
  end

  def turbo_stream_response?
    response.media_type == 'text/vnd.turbo-stream.html'
  end

  def assert_turbo_stream(action:, target:)
    expect(response.body).to include("action=\"#{action}\"")
    expect(response.body).to include("target=\"#{target}\"")
  end
end

RSpec.configure do |config|
  config.include TurboHelpers, type: :system
  config.include TurboHelpers, type: :request
end
```
