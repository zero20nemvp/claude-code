#!/usr/bin/env ruby
# frozen_string_literal: true

# ILX View Emitter: ERB/HTML → ILX v0.1 View Format
#
# Converts ERB templates with Tailwind to ILX view notation:
# - HTML structure → layout/div/text/img/input/action
# - Tailwind classes → dot-chained onto elements
# - Data bindings <%= %> → element:binding
# - Rails helpers → actions (link_to, form_with, etc.)
# - Iterations → each:Model.scope
# - Conditionals → cond:@role
#
# Dependencies:
#   gem install nokogiri erubi
#
# Usage:
#   ruby ilx_view_emitter.rb view.html.erb
#   ruby ilx_view_emitter.rb app/views/

require 'erb'
require 'nokogiri'
require 'pathname'

module ILX
  class ViewEmitter
    VERSION = "0.1.0"

    # Rails helpers that map to ILX actions
    ACTION_HELPERS = {
      'link_to' => 'click',
      'button_to' => 'click',
      'submit_tag' => 'submit',
      'button_tag' => 'click',
      'form_with' => 'submit',
      'form_for' => 'submit'
    }.freeze

    FORMATTERS = {
      'number_to_currency' => 'currency',
      'number_with_delimiter' => 'number',
      'number_to_percentage' => 'percent',
      'time_ago_in_words' => 'relative',
      'distance_of_time_in_words' => 'relative',
      'truncate' => 'truncate',
      'l' => 'date',
      'localize' => 'date'
    }.freeze

    def initialize
      @view_name = nil
      @indent_level = 0
      @output = []
    end

    def emit_file(path)
      content = File.read(path)

      # Determine view name from path
      # e.g., app/views/listings/show.html.erb → listings/show
      @view_name = extract_view_name(path)

      emit(content)
    end

    def emit_dir(dir)
      results = []
      Dir.glob("#{dir}/**/*.html.erb").each do |file|
        results << emit_file(file)
      end
      results.join("\n\n")
    end

    def emit(erb_content)
      # Parse ERB to extract Ruby code and HTML
      processed = preprocess_erb(erb_content)

      # Parse HTML with Nokogiri
      begin
        doc = Nokogiri::HTML.fragment(processed)
        @output = []
        @indent_level = 0

        # Emit view header
        @output << "##{@view_name || 'view'}"

        # Process document
        doc.children.each { |node| process_node(node) }

        @output.join("\n")
      rescue => e
        "# Error parsing view: #{e.message}"
      end
    end

    private

    def extract_view_name(path)
      # Extract namespace/view_name from file path
      # app/views/listings/show.html.erb → listings/show
      # app/views/admin/users/index.html.erb → admin/users/index

      pathname = Pathname.new(path)
      parts = pathname.to_s.split('/')

      # Find 'views' in path
      views_idx = parts.index('views')
      return 'view' unless views_idx

      # Get parts after 'views'
      view_parts = parts[(views_idx + 1)..-1]

      # Remove file extension
      view_parts[-1] = view_parts[-1].sub(/\.html\.erb$/, '')

      view_parts.join('/')
    end

    def preprocess_erb(content)
      # Replace ERB tags with placeholders we can parse
      # <%= ... %> → <erb-output>...</erb-output>
      # <%- ... %> → <erb-silent>...</erb-silent>
      # <% ... %> → <erb-code>...</erb-code>

      result = content.dup

      # Output tags <%= %>
      result.gsub!(/<%=\s*(.*?)\s*%>/) do |match|
        code = $1
        "<erb-output data-code=\"#{escape_html(code)}\">#{analyze_output(code)}</erb-output>"
      end

      # Silent tags <%- %>
      result.gsub!(/<%[-]?\s*(.*?)\s*%>/) do |match|
        code = $1
        tag = analyze_code(code)
        tag || "<!--erb: #{escape_html(code)}-->"
      end

      result
    end

    def analyze_output(code)
      # Analyze <%= %> code to determine binding
      code = code.strip

      # Check for formatters
      FORMATTERS.each do |helper, formatter|
        if code.match?(/#{helper}\(/)
          # Extract the argument (data being formatted)
          if code =~ /#{helper}\((.*?)\)/
            data = $1.strip
            return "<erb-binding data-binding=\"#{escape_html(data)}\" data-format=\"#{formatter}\">BINDING</erb-binding>"
          end
        end
      end

      # Check for text content (string literals)
      if code =~ /^["'](.*?)["']$/
        return escape_html($1)
      end

      # Default: treat as binding
      "<erb-binding data-binding=\"#{escape_html(code)}\">BINDING</erb-binding>"
    end

    def analyze_code(code)
      code = code.strip

      # Check for iteration
      if code =~ /\.each\s+do\s+\|(\w+)\|/ || code =~ /for\s+(\w+)\s+in\s+(.+)/
        collection = code.match(/(.+?)\.each/)?.[1] || $2
        var = $1
        return "<erb-each data-collection=\"#{escape_html(collection)}\" data-var=\"#{var}\">"
      end

      # Check for conditionals
      if code =~ /^if\s+(.+)/
        condition = $1
        return "<erb-if data-condition=\"#{escape_html(condition)}\">"
      end

      if code =~ /^unless\s+(.+)/
        condition = $1
        return "<erb-unless data-condition=\"#{escape_html(condition)}\">"
      end

      # Check for else/elsif
      if code =~ /^else$/
        return "<erb-else>"
      end

      if code =~ /^elsif\s+(.+)/
        condition = $1
        return "<erb-elsif data-condition=\"#{escape_html(condition)}\">"
      end

      # Check for end
      if code =~ /^end$/
        return "</erb-block>"
      end

      nil
    end

    def process_node(node, parent_binding = nil)
      case node.type
      when Nokogiri::XML::Node::ELEMENT_NODE
        process_element(node, parent_binding)
      when Nokogiri::XML::Node::TEXT_NODE
        process_text(node, parent_binding)
      end
    end

    def process_element(node, parent_binding)
      name = node.name

      # Handle special ERB nodes
      case name
      when 'erb-output'
        # Already processed
        return
      when 'erb-binding'
        # Skip, handled in parent
        return
      when 'erb-each'
        process_iteration(node)
        return
      when 'erb-if', 'erb-unless'
        process_conditional(node)
        return
      when 'erb-block'
        # End block, decrease indent
        @indent_level -= 1
        return
      end

      # Extract Tailwind classes
      classes = extract_classes(node)

      # Determine element type and binding
      binding = extract_binding(node)
      element_type = determine_element_type(node, binding)

      # Build ILX line
      line = build_element_line(element_type, node, binding, classes)

      @output << indent + line

      # Process children
      @indent_level += 1
      node.children.each { |child| process_node(child, binding) }
      @indent_level -= 1
    end

    def process_text(node, parent_binding)
      text = node.text.strip
      return if text.empty?
      return if text == "BINDING" # Placeholder from erb-binding

      # Check if parent has binding
      binding_node = node.parent.at_css('erb-binding')
      if binding_node
        binding = binding_node['data-binding']
        format = binding_node['data-format']

        if format
          @output << indent + "text:#{binding}|fmt:#{format}"
        else
          @output << indent + "text:#{binding}"
        end
      else
        # Literal text
        @output << indent + "text:\"#{escape_text(text)}\""
      end
    end

    def process_iteration(node)
      collection = node['data-collection']
      var = node['data-var']

      @output << indent + "each:#{collection}"
      @indent_level += 1

      # Process children
      node.children.each { |child| process_node(child, var) }

      @indent_level -= 1
    end

    def process_conditional(node)
      condition = node['data-condition']
      type = node.name == 'erb-if' ? 'cond' : 'cond'

      @output << indent + "#{type}:#{condition}"
      @indent_level += 1

      # Process children
      node.children.each { |child| process_node(child) }

      @indent_level -= 1
    end

    def determine_element_type(node, binding)
      name = node.name.downcase

      # Check for layout (first container)
      return 'layout' if @output.size == 1 && %w[div section main article].include?(name)

      # Map HTML elements to ILX elements
      case name
      when 'img' then 'img'
      when 'input', 'textarea', 'select' then 'input'
      when 'form' then 'component'
      when 'a'
        # Links are actions
        'action'
      when 'button'
        # Buttons are actions
        'action'
      when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'span', 'label'
        'text'
      else
        'div'
      end
    end

    def build_element_line(element_type, node, binding, classes)
      parts = [element_type]

      # Add binding if present
      if binding
        parts[0] += ":#{binding}"
      end

      # Add classes
      if classes.any?
        parts[0] += ".#{classes.join('.')}"
      end

      # Handle actions
      if element_type == 'action'
        action = extract_action(node)
        parts[0] += "→#{action}" if action
      end

      # Handle attributes
      attrs = extract_attributes(node)
      if attrs.any?
        attr_str = attrs.map { |k, v| "#{k}:#{v}" }.join('|')
        parts[0] += "|#{attr_str}" unless attr_str.empty?
      end

      parts.join
    end

    def extract_classes(node)
      class_attr = node['class']
      return [] unless class_attr

      # Split Tailwind classes
      class_attr.split(/\s+/).reject(&:empty?)
    end

    def extract_binding(node)
      # Look for erb-binding in children
      binding_node = node.at_css('erb-binding')
      return binding_node['data-binding'] if binding_node

      # Check for common Rails helpers
      binding_node = node.at_css('erb-output')
      return binding_node['data-code'] if binding_node

      nil
    end

    def extract_action(node)
      # Check href for links
      href = node['href']
      if href && href.start_with?('#')
        # Client-side route
        return href
      end

      # Check for Rails route helpers
      href_match = href&.match(/(\w+)_path/)
      if href_match
        return "##{href_match[1]}"
      end

      # Default
      "#show"
    end

    def extract_attributes(node)
      attrs = {}

      # Common attributes that map to ILX constraints
      if node['required']
        attrs['required'] = true
      end

      if node['disabled']
        attrs['disabled'] = true
      end

      if placeholder = node['placeholder']
        attrs['placeholder'] = "\"#{placeholder}\""
      end

      if min = node['min']
        attrs['min'] = min
      end

      if max = node['max']
        attrs['max'] = max
      end

      attrs
    end

    def escape_html(str)
      str.gsub('"', '&quot;').gsub("'", '&#39;')
    end

    def escape_text(str)
      str.gsub('"', '\\"')
    end

    def indent
      "  " * @indent_level
    end
  end
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: ruby ilx_view_emitter.rb <file.html.erb|directory>"
    puts "\nDependencies: gem install nokogiri"
    exit 1
  end

  path = ARGV[0]
  emitter = ILX::ViewEmitter.new

  if File.directory?(path)
    puts emitter.emit_dir(path)
  else
    puts emitter.emit_file(path)
  end
end
