---
name: lofi-wireframes
description: Use when prototyping UIs in Rails 8 projects. Scaffolds wireframe infrastructure and generates low-fidelity mockups from natural language user flow descriptions. Mobile-first, placeholder-based, monochrome design system.
triggers:
  - wireframe
  - prototype
  - mockup
  - user flow
  - UI prototype
  - screen design
  - lo-fi
  - low fidelity
  - wireframing
---

# Low-Fidelity Wireframe Skill

**Auto-activates when task involves wireframing, prototyping, or UI flow design in Rails projects.**

Create rapid, low-fidelity wireframes that focus on structure and flow, not visual polish. Generate Rails infrastructure and view templates from natural language user flow descriptions.

## Philosophy

Low-fidelity wireframes are **thinking tools**, not deliverables:
- **Structure over style**: Focus on layout, hierarchy, and flow
- **Placeholder-based**: `[icon: login]`, `[image: hero]` instead of actual graphics
- **Monochrome**: White, black, and gray only - no color decisions yet
- **Mobile-first**: PWA/mobile layout is the primary view, desktop is the expansion
- **Removable**: Environment-gated routes for development only

## Detection Triggers

This skill activates automatically when the task involves:
- Creating wireframes or mockups
- Designing user flows
- Prototyping screens
- Planning UI structure
- Lo-fi or low-fidelity design work

## Before You Wireframe

### 1. Understand the Flow

Ask yourself:
- **Who is the user?** (new user, returning user, admin, etc.)
- **What's their goal?** (sign up, complete purchase, find information)
- **What's the journey?** (entry point → steps → success state)

### 2. Identify Screens

Break the flow into discrete screens:
- Each screen = one user task or decision point
- Name screens clearly: `login`, `register`, `dashboard`, `product-detail`
- Map transitions: which screen leads to which?

### 3. Choose Viewport Priority

- **Mobile** (375px): PWA and Hotwire Native apps
- **Desktop** (1024px): Browser-based dashboards and admin tools

Default to mobile-first unless the user explicitly requests desktop-first.

## Infrastructure Detection

Before scaffolding, check if wireframe infrastructure exists:

```ruby
# Check routes
File.read("config/routes.rb").include?("namespace :wireframes")

# Check controllers
Dir.exist?("app/controllers/wireframes")

# Check views
Dir.exist?("app/views/wireframes")

# Check CSS
File.exist?("app/assets/stylesheets/wireframes.css")
```

If ANY component is missing, scaffold the full infrastructure.

## Scaffolding Templates

### Routes (config/routes.rb)

Add inside `Rails.application.routes.draw`:

```ruby
# Wireframes - development only
if Rails.env.development?
  namespace :wireframes do
    root to: "index#show"
    get ":flow", to: "flows#index", as: :flow
    get ":flow/:screen", to: "flows#show", as: :screen
  end
end
```

### Base Controller (app/controllers/wireframes/base_controller.rb)

```ruby
# frozen_string_literal: true

module Wireframes
  class BaseController < ApplicationController
    layout "wireframes"
    before_action :development_only!

    private

    def development_only!
      raise ActionController::RoutingError, "Not Found" unless Rails.env.development?
    end
  end
end
```

### Index Controller (app/controllers/wireframes/index_controller.rb)

```ruby
# frozen_string_literal: true

module Wireframes
  class IndexController < BaseController
    def show
      @flows = WireframeRegistry.flows
    end
  end
end
```

### Flows Controller (app/controllers/wireframes/flows_controller.rb)

```ruby
# frozen_string_literal: true

module Wireframes
  class FlowsController < BaseController
    def index
      @flow = WireframeRegistry.find_flow(params[:flow])
      redirect_to wireframes_root_path unless @flow
    end

    def show
      @flow = WireframeRegistry.find_flow(params[:flow])
      @screen = @flow&.find_screen(params[:screen])
      redirect_to wireframes_flow_path(params[:flow]) unless @screen
    end
  end
end
```

### Layout (app/views/layouts/wireframes.html.erb)

```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Wireframes</title>
  <%= stylesheet_link_tag "wireframes", media: "all" %>
  <%= javascript_importmap_tags %>
</head>
<body class="wf-body" data-controller="viewport-toggle">
  <header class="wf-header">
    <div class="wf-header-left">
      <h1 class="wf-logo"><%= link_to "Wireframes", wireframes_root_path %></h1>
    </div>
    <nav class="wf-nav" data-viewport-toggle-target="nav">
      <%= yield :wireframe_nav %>
    </nav>
    <div class="wf-header-right">
      <div class="wf-viewport-toggle">
        <button type="button"
                data-action="viewport-toggle#setMobile"
                data-viewport-toggle-target="mobileBtn"
                class="wf-viewport-btn wf-viewport-btn--active">
          Mobile
        </button>
        <button type="button"
                data-action="viewport-toggle#setDesktop"
                data-viewport-toggle-target="desktopBtn"
                class="wf-viewport-btn">
          Desktop
        </button>
      </div>
    </div>
  </header>

  <main class="wf-canvas" data-viewport-toggle-target="canvas">
    <div class="wf-canvas-inner">
      <%= yield %>
    </div>
  </main>
</body>
</html>
```

### CSS (app/assets/stylesheets/wireframes.css)

```css
/* Wireframe Design System - Monochrome Only */
:root {
  /* Colors - Monochrome palette */
  --wf-white: #ffffff;
  --wf-gray-50: #fafafa;
  --wf-gray-100: #f5f5f5;
  --wf-gray-200: #e5e5e5;
  --wf-gray-300: #d4d4d4;
  --wf-gray-400: #a3a3a3;
  --wf-gray-500: #737373;
  --wf-gray-600: #525252;
  --wf-gray-700: #404040;
  --wf-gray-800: #262626;
  --wf-gray-900: #171717;
  --wf-black: #000000;

  /* Spacing */
  --wf-space-xs: 0.25rem;
  --wf-space-sm: 0.5rem;
  --wf-space-md: 1rem;
  --wf-space-lg: 1.5rem;
  --wf-space-xl: 2rem;

  /* Typography */
  --wf-font-sans: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --wf-font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, monospace;

  /* Mobile canvas */
  --wf-canvas-mobile: 375px;
  --wf-canvas-desktop: 1024px;
}

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Body */
.wf-body {
  font-family: var(--wf-font-sans);
  background: var(--wf-gray-200);
  min-height: 100vh;
  color: var(--wf-gray-900);
}

/* Header */
.wf-header {
  background: var(--wf-gray-800);
  color: var(--wf-white);
  padding: var(--wf-space-sm) var(--wf-space-md);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--wf-space-md);
  position: sticky;
  top: 0;
  z-index: 100;
}

.wf-logo {
  font-size: 0.875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.wf-logo a {
  color: var(--wf-white);
  text-decoration: none;
}

.wf-nav {
  display: flex;
  gap: var(--wf-space-xs);
  flex-wrap: wrap;
  justify-content: center;
  flex: 1;
}

.wf-nav a {
  color: var(--wf-gray-400);
  text-decoration: none;
  font-size: 0.75rem;
  padding: var(--wf-space-xs) var(--wf-space-sm);
  border-radius: 4px;
  transition: all 0.15s ease;
}

.wf-nav a:hover,
.wf-nav a.active {
  color: var(--wf-white);
  background: var(--wf-gray-700);
}

/* Viewport Toggle */
.wf-viewport-toggle {
  display: flex;
  background: var(--wf-gray-700);
  border-radius: 4px;
  overflow: hidden;
}

.wf-viewport-btn {
  background: transparent;
  border: none;
  color: var(--wf-gray-400);
  padding: var(--wf-space-xs) var(--wf-space-sm);
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.15s ease;
}

.wf-viewport-btn:hover {
  color: var(--wf-white);
}

.wf-viewport-btn--active {
  background: var(--wf-black);
  color: var(--wf-white);
}

/* Canvas */
.wf-canvas {
  padding: var(--wf-space-lg);
  display: flex;
  justify-content: center;
}

.wf-canvas-inner {
  width: 100%;
  max-width: var(--wf-canvas-mobile);
  background: var(--wf-white);
  border: 2px solid var(--wf-black);
  min-height: calc(100vh - 100px);
  transition: max-width 0.3s ease;
}

.wf-canvas--desktop .wf-canvas-inner {
  max-width: var(--wf-canvas-desktop);
}

/* ===== WIREFRAME COMPONENTS ===== */

/* Section */
.wf-section {
  padding: var(--wf-space-lg);
  border-bottom: 1px solid var(--wf-gray-200);
}

.wf-section:last-child {
  border-bottom: none;
}

.wf-section-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--wf-gray-500);
  margin-bottom: var(--wf-space-md);
}

/* Card */
.wf-card {
  background: var(--wf-white);
  border: 1px solid var(--wf-gray-300);
  padding: var(--wf-space-md);
  margin-bottom: var(--wf-space-md);
  display: block;
  text-decoration: none;
  color: inherit;
  transition: all 0.15s ease;
}

.wf-card:hover {
  border-color: var(--wf-gray-500);
  background: var(--wf-gray-50);
}

.wf-card-title {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: var(--wf-space-xs);
}

.wf-card-desc {
  font-size: 0.875rem;
  color: var(--wf-gray-600);
}

/* Placeholder - Icon */
.wf-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--wf-space-xs) var(--wf-space-sm);
  background: var(--wf-gray-100);
  border: 1px dashed var(--wf-gray-400);
  font-family: var(--wf-font-mono);
  font-size: 0.75rem;
  color: var(--wf-gray-600);
}

/* Placeholder - Image */
.wf-image {
  background: var(--wf-gray-100);
  border: 1px dashed var(--wf-gray-400);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--wf-font-mono);
  font-size: 0.75rem;
  color: var(--wf-gray-500);
  min-height: 120px;
  padding: var(--wf-space-md);
}

/* Placeholder - Step */
.wf-step {
  display: flex;
  align-items: center;
  gap: var(--wf-space-sm);
  padding: var(--wf-space-sm) var(--wf-space-md);
  background: var(--wf-gray-100);
  border-left: 3px solid var(--wf-gray-400);
  margin-bottom: var(--wf-space-sm);
}

.wf-step-num {
  background: var(--wf-gray-300);
  color: var(--wf-gray-700);
  width: 1.5rem;
  height: 1.5rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 600;
  flex-shrink: 0;
}

.wf-step-text {
  font-size: 0.875rem;
}

/* Typography */
.wf-h1 {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--wf-black);
  margin-bottom: var(--wf-space-md);
}

.wf-h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--wf-black);
  margin-bottom: var(--wf-space-sm);
}

.wf-h3 {
  font-size: 1rem;
  font-weight: 600;
  color: var(--wf-gray-800);
  margin-bottom: var(--wf-space-xs);
}

.wf-text {
  font-size: 0.875rem;
  color: var(--wf-gray-700);
  line-height: 1.5;
}

.wf-caption {
  font-size: 0.75rem;
  color: var(--wf-gray-500);
}

/* Button */
.wf-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--wf-space-xs);
  padding: var(--wf-space-sm) var(--wf-space-md);
  font-size: 0.875rem;
  font-weight: 500;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.15s ease;
}

.wf-btn--primary {
  background: var(--wf-black);
  color: var(--wf-white);
  border-color: var(--wf-black);
}

.wf-btn--primary:hover {
  background: var(--wf-gray-800);
}

.wf-btn--secondary {
  background: var(--wf-white);
  color: var(--wf-black);
  border-color: var(--wf-black);
}

.wf-btn--secondary:hover {
  background: var(--wf-gray-100);
}

.wf-btn--ghost {
  background: transparent;
  color: var(--wf-gray-600);
  border-color: transparent;
}

.wf-btn--ghost:hover {
  color: var(--wf-black);
  background: var(--wf-gray-100);
}

/* Input */
.wf-input {
  width: 100%;
  padding: var(--wf-space-sm) var(--wf-space-md);
  font-size: 0.875rem;
  border: 2px solid var(--wf-gray-300);
  background: var(--wf-white);
  transition: border-color 0.15s ease;
}

.wf-input:focus {
  outline: none;
  border-color: var(--wf-black);
}

.wf-input::placeholder {
  color: var(--wf-gray-400);
}

/* Label */
.wf-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--wf-gray-700);
  margin-bottom: var(--wf-space-xs);
}

/* Form Group */
.wf-form-group {
  margin-bottom: var(--wf-space-md);
}

/* Grid */
.wf-grid {
  display: grid;
  gap: var(--wf-space-md);
}

.wf-grid--2 { grid-template-columns: repeat(2, 1fr); }
.wf-grid--3 { grid-template-columns: repeat(3, 1fr); }

/* Flex utilities */
.wf-flex { display: flex; }
.wf-flex-col { flex-direction: column; }
.wf-items-center { align-items: center; }
.wf-justify-between { justify-content: space-between; }
.wf-justify-center { justify-content: center; }
.wf-gap-sm { gap: var(--wf-space-sm); }
.wf-gap-md { gap: var(--wf-space-md); }

/* Spacing utilities */
.wf-mt-md { margin-top: var(--wf-space-md); }
.wf-mb-md { margin-bottom: var(--wf-space-md); }
.wf-p-md { padding: var(--wf-space-md); }

/* Flow Summary */
.wf-flow-summary {
  background: var(--wf-gray-100);
  padding: var(--wf-space-md);
  font-size: 0.875rem;
}

.wf-flow-summary strong {
  color: var(--wf-gray-700);
}

.wf-flow-summary .wf-arrow {
  color: var(--wf-gray-400);
  margin: 0 var(--wf-space-xs);
}
```

### Stimulus Controller (app/javascript/controllers/viewport_toggle_controller.js)

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "mobileBtn", "desktopBtn", "nav"]

  connect() {
    this.setMobile()
  }

  setMobile() {
    this.canvasTarget.classList.remove("wf-canvas--desktop")
    this.mobileBtnTarget.classList.add("wf-viewport-btn--active")
    this.desktopBtnTarget.classList.remove("wf-viewport-btn--active")
  }

  setDesktop() {
    this.canvasTarget.classList.add("wf-canvas--desktop")
    this.desktopBtnTarget.classList.add("wf-viewport-btn--active")
    this.mobileBtnTarget.classList.remove("wf-viewport-btn--active")
  }
}
```

### Wireframe Registry (lib/wireframe_registry.rb)

```ruby
# frozen_string_literal: true

class WireframeRegistry
  class << self
    def flows
      @flows ||= []
    end

    def register_flow(flow)
      flows << flow unless flows.any? { |f| f.slug == flow.slug }
      flow
    end

    def find_flow(slug)
      flows.find { |f| f.slug == slug.to_s }
    end

    def reset!
      @flows = []
    end
  end
end

class WireframeFlow
  attr_reader :slug, :name, :description, :screens

  def initialize(slug:, name:, description: nil)
    @slug = slug.to_s
    @name = name
    @description = description
    @screens = []
  end

  def add_screen(slug:, name:, template: nil)
    screen = WireframeScreen.new(slug: slug, name: name, flow: self, template: template)
    @screens << screen unless @screens.any? { |s| s.slug == slug.to_s }
    screen
  end

  def find_screen(slug)
    @screens.find { |s| s.slug == slug.to_s }
  end
end

class WireframeScreen
  attr_reader :slug, :name, :flow, :template

  def initialize(slug:, name:, flow:, template: nil)
    @slug = slug.to_s
    @name = name
    @flow = flow
    @template = template || slug.to_s
  end

  def path
    "/wireframes/#{flow.slug}/#{slug}"
  end
end
```

### Helper (app/helpers/wireframes_helper.rb)

```ruby
# frozen_string_literal: true

module WireframesHelper
  # Render placeholder icon
  # Usage: <%= wf_icon "login" %>
  def wf_icon(name)
    content_tag :span, "[icon: #{name}]", class: "wf-icon"
  end

  # Render placeholder image
  # Usage: <%= wf_image %> or <%= wf_image "hero banner" %>
  def wf_image(label = "image", height: nil)
    style = height ? "min-height: #{height}px" : nil
    content_tag :div, "[#{label}]", class: "wf-image", style: style
  end

  # Render process step
  # Usage: <%= wf_step 1, "Enter email" %>
  def wf_step(number, text)
    content_tag :div, class: "wf-step" do
      content_tag(:span, number, class: "wf-step-num") +
        content_tag(:span, text, class: "wf-step-text")
    end
  end

  # Render card container
  # Usage: <%= wf_card { ... } %> or <%= wf_card(href: path) { ... } %>
  def wf_card(href: nil, &block)
    if href
      link_to href, class: "wf-card", &block
    else
      content_tag :div, class: "wf-card", &block
    end
  end

  # Check if current screen
  def wf_current_screen?(screen)
    params[:screen] == screen.slug
  end

  # Check if current flow
  def wf_current_flow?(flow)
    params[:flow] == flow.slug
  end
end
```

### Index View (app/views/wireframes/index/show.html.erb)

```erb
<% content_for :wireframe_nav do %>
  <% @flows.each do |flow| %>
    <%= link_to flow.name, wireframes_flow_path(flow.slug),
        class: wf_current_flow?(flow) ? "active" : "" %>
  <% end %>
<% end %>

<div class="wf-section">
  <h1 class="wf-h1">Wireframes</h1>
  <p class="wf-text">Low-fidelity mockups for user flows</p>
</div>

<% @flows.each do |flow| %>
  <div class="wf-section">
    <h2 class="wf-section-title"><%= flow.name %></h2>

    <% if flow.description.present? %>
      <p class="wf-text wf-mb-md"><%= flow.description %></p>
    <% end %>

    <div class="wf-grid wf-grid--2">
      <% flow.screens.each do |screen| %>
        <%= wf_card(href: wireframes_screen_path(flow.slug, screen.slug)) do %>
          <div class="wf-flex wf-items-center wf-gap-sm">
            <%= wf_icon screen.slug %>
            <div>
              <h3 class="wf-card-title"><%= screen.name %></h3>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
  </div>
<% end %>
```

### Flow Index View (app/views/wireframes/flows/index.html.erb)

```erb
<% content_for :wireframe_nav do %>
  <% WireframeRegistry.flows.each do |flow| %>
    <%= link_to flow.name, wireframes_flow_path(flow.slug),
        class: wf_current_flow?(flow) ? "active" : "" %>
  <% end %>
  <span style="color: var(--wf-gray-600)">|</span>
  <% @flow.screens.each do |screen| %>
    <%= link_to screen.name, wireframes_screen_path(@flow.slug, screen.slug),
        class: wf_current_screen?(screen) ? "active" : "" %>
  <% end %>
<% end %>

<div class="wf-section">
  <h1 class="wf-h1"><%= @flow.name %></h1>
  <% if @flow.description.present? %>
    <p class="wf-text"><%= @flow.description %></p>
  <% end %>
</div>

<div class="wf-section">
  <h2 class="wf-section-title">Screens</h2>

  <% @flow.screens.each_with_index do |screen, i| %>
    <%= wf_card(href: wireframes_screen_path(@flow.slug, screen.slug)) do %>
      <div class="wf-flex wf-items-center wf-gap-sm">
        <%= wf_step i + 1, screen.name %>
      </div>
    <% end %>
  <% end %>
</div>
```

### Screen View (app/views/wireframes/flows/show.html.erb)

```erb
<% content_for :wireframe_nav do %>
  <% WireframeRegistry.flows.each do |flow| %>
    <%= link_to flow.name, wireframes_flow_path(flow.slug),
        class: wf_current_flow?(flow) ? "active" : "" %>
  <% end %>
  <span style="color: var(--wf-gray-600)">|</span>
  <% @flow.screens.each do |screen| %>
    <%= link_to screen.name, wireframes_screen_path(@flow.slug, screen.slug),
        class: wf_current_screen?(screen) ? "active" : "" %>
  <% end %>
<% end %>

<%= render "wireframes/screens/#{@flow.slug}/#{@screen.template}" %>
```

### Example Initializer (config/initializers/wireframes.rb)

```ruby
# frozen_string_literal: true

# Register wireframe flows
# This file is auto-generated by the lofi-wireframes skill

return unless Rails.env.development?

require_relative "../../lib/wireframe_registry"

# Example: Authentication Flow
auth_flow = WireframeFlow.new(
  slug: "auth",
  name: "Authentication",
  description: "User login and registration flow"
)
auth_flow.add_screen(slug: "login", name: "Login")
auth_flow.add_screen(slug: "register", name: "Register")
auth_flow.add_screen(slug: "forgot-password", name: "Forgot Password")

WireframeRegistry.register_flow(auth_flow)
```

### Example Screen Template (app/views/wireframes/screens/auth/login.html.erb)

```erb
<div class="wf-section">
  <%= wf_image "App Logo", height: 60 %>
</div>

<div class="wf-section">
  <h1 class="wf-h1">Welcome back</h1>
  <p class="wf-text">Sign in to your account</p>
</div>

<div class="wf-section">
  <div class="wf-form-group">
    <%= label_tag :email, "Email", class: "wf-label" %>
    <%= text_field_tag :email, nil, class: "wf-input", placeholder: "you@example.com" %>
  </div>

  <div class="wf-form-group">
    <%= label_tag :password, "Password", class: "wf-label" %>
    <%= password_field_tag :password, nil, class: "wf-input", placeholder: "********" %>
  </div>

  <div class="wf-flex wf-justify-between wf-items-center wf-mb-md">
    <label class="wf-caption">
      <%= check_box_tag :remember %> Remember me
    </label>
    <%= link_to "Forgot password?", wireframes_screen_path("auth", "forgot-password"),
        class: "wf-caption" %>
  </div>

  <button class="wf-btn wf-btn--primary" style="width: 100%">
    <%= wf_icon "login" %> Sign In
  </button>
</div>

<div class="wf-section">
  <p class="wf-text" style="text-align: center">
    Don't have an account?
    <%= link_to "Sign up", wireframes_screen_path("auth", "register") %>
  </p>
</div>
```

## Generating Wireframes from Natural Language

When the user describes a flow in natural language, follow this process:

### 1. Parse the Flow Description

Extract:
- **Flow name**: The overall journey (e.g., "authentication", "checkout", "onboarding")
- **Screens**: Individual pages/views mentioned
- **Components**: Forms, buttons, images, icons referenced
- **Transitions**: How screens connect

Example input:
> "I need wireframes for a login flow: landing page with app logo and login button, login form with email and password, forgot password screen, and a success message"

Parsed:
- Flow: `auth` (Authentication)
- Screens: `landing`, `login`, `forgot-password`, `success`
- Components: logo image, buttons, form fields

### 2. Generate Flow Registration

Add to `config/initializers/wireframes.rb`:

```ruby
auth_flow = WireframeFlow.new(
  slug: "auth",
  name: "Authentication",
  description: "User login flow"
)
auth_flow.add_screen(slug: "landing", name: "Landing")
auth_flow.add_screen(slug: "login", name: "Login")
auth_flow.add_screen(slug: "forgot-password", name: "Forgot Password")
auth_flow.add_screen(slug: "success", name: "Success")

WireframeRegistry.register_flow(auth_flow)
```

### 3. Generate Screen Templates

Create `app/views/wireframes/screens/{flow}/{screen}.html.erb` for each screen.

Use wireframe components:
- `wf_icon "name"` for icon placeholders
- `wf_image "description"` for image placeholders
- `wf_step n, "text"` for process steps
- `wf_card { }` for card containers
- Standard form helpers with `wf-` classes

### 4. Connect Screens with Navigation

Use `wireframes_screen_path(flow, screen)` for links between screens.

## Component Patterns

### Authentication Screens
- Logo + tagline at top
- Form with email/password fields
- Primary action button
- Secondary links (forgot password, sign up)

### Dashboard Screens
- Header with user info
- Navigation/tabs
- Card grid for content
- Action buttons

### List/Catalog Screens
- Search/filter bar
- Card grid or list view
- Pagination or infinite scroll indicator

### Detail Screens
- Hero image
- Title + description
- Action buttons
- Related content cards

### Onboarding Screens
- Progress indicator (steps)
- Single focus per screen
- Large visuals
- Clear CTAs

## Verification Checklist

Before marking wireframe task complete:

- [ ] Infrastructure scaffolded (routes, controllers, CSS, JS)
- [ ] Flow registered in initializer
- [ ] All screen templates created
- [ ] Navigation between screens works
- [ ] Mobile viewport is default
- [ ] Desktop toggle works
- [ ] All placeholders use `wf_` helpers
- [ ] Monochrome only (no colors)
- [ ] Can preview at `/wireframes`

## Remember

Wireframes are for **structure and flow**, not visual design:
- Don't add colors, gradients, or fancy effects
- Don't worry about exact spacing or alignment
- Do focus on what elements appear on each screen
- Do show how screens connect to each other
- Do use placeholder text that explains the content type

**Speed over polish.** The goal is rapid iteration on user flows, not pixel-perfect mockups.
