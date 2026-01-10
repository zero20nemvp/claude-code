#!/usr/bin/env ruby
# frozen_string_literal: true

# ILX Domain Emitter: Ruby/Rails → ILX v0.1 Domain Format
#
# Converts Ruby/Rails code to ILX domain notation:
# - Entities (models) → Entity{fields}
# - Features (actions) → #feature→Result|constraints⟹triggers
# - Relationships → Entity⊃Target, Entity⊂Target
# - Constraints from validations/conditionals
# - Triggers from callbacks
#
# Dependencies:
#   gem install prism rbs
#
# Usage:
#   ruby ilx_domain_emitter.rb file.rb
#   ruby ilx_domain_emitter.rb app/models/

require 'prism'
require 'rbs'
require 'pathname'

module ILX
  class DomainEmitter
    VERSION = "0.1.0"

    def initialize
      @entities = {}
      @features = []
      @relationships = []
      @current_class = nil
      @current_namespace = nil
      @rbs = {}
    end

    def load_rbs(path)
      return unless File.exist?(path)
      buffer = RBS::Buffer.new(content: File.read(path), name: path)
      RBS::Parser.parse_signature(buffer).each { |decl| extract_sigs(decl) }
    rescue => e
      warn "RBS parse warning: #{e.message}"
    end

    def emit_file(path)
      rbs_path = path.sub(/\.rb$/, '.rbs')
      load_rbs(rbs_path) if File.exist?(rbs_path)
      emit(File.read(path), path)
    end

    def emit_dir(dir)
      Dir.glob("#{dir}/**/*.rb").each { |f| emit_file(f) }
      build
    end

    def emit(code, file = 'unknown.rb')
      @source = file
      result = Prism.parse(code)
      return "" if result.failure?

      walk(result.value)
      build
    end

    private

    def extract_sigs(decl)
      case decl
      when RBS::AST::Declarations::Class, RBS::AST::Declarations::Module
        decl.members.each do |m|
          if m.is_a?(RBS::AST::Members::MethodDefinition)
            sig = m.overloads.first&.method_type
            @rbs[m.name.to_s] = sig if sig
          end
        end
      end
    end

    def walk(node)
      case node
      when Prism::ProgramNode then walk(node.statements)
      when Prism::StatementsNode then node.body.each { |n| walk(n) }
      when Prism::ClassNode then emit_class(node)
      when Prism::ModuleNode then emit_module(node)
      when Prism::DefNode then emit_method(node)
      when Prism::CallNode then emit_call(node)
      else
        node.compact_child_nodes.each { |n| walk(n) } if node.respond_to?(:compact_child_nodes)
      end
    end

    def emit_module(node)
      name = node.constant_path.name.to_s rescue 'Unknown'
      prev_namespace = @current_namespace
      @current_namespace = name
      walk(node.body) if node.body
      @current_namespace = prev_namespace
    end

    def emit_class(node)
      name = node.constant_path.name.to_s rescue 'Unknown'
      @current_class = name

      # Detect if this is a Rails model (inherits from ApplicationRecord or ActiveRecord::Base)
      is_model = detect_model(node)

      if is_model
        @entities[name] ||= {
          name: name,
          fields: [],
          relationships: [],
          validations: [],
          callbacks: []
        }
      end

      walk(node.body) if node.body
      @current_class = nil
    end

    def detect_model(node)
      return false unless node.superclass

      superclass_name = case node.superclass
      when Prism::ConstantReadNode then node.superclass.name.to_s
      when Prism::ConstantPathNode then node.superclass.full_name
      else nil
      end

      superclass_name&.match?(/ApplicationRecord|ActiveRecord::Base/)
    end

    def emit_method(node)
      return unless @current_class

      name = node.name.to_s

      # Detect features (public methods that perform actions)
      if public_method?(name)
        params = extract_params(node)
        result_type = detect_result_type(node)
        constraints = extract_constraints(node)
        triggers = extract_triggers(node)

        @features << {
          name: name,
          class: @current_class,
          params: params,
          result: result_type,
          constraints: constraints,
          triggers: triggers
        }
      end
    end

    def emit_call(node)
      method = node.name.to_s

      return unless @current_class && @entities[@current_class]

      case method
      # Associations
      when 'belongs_to', 'has_one', 'has_many', 'has_and_belongs_to_many'
        emit_association(method, node)

      # Validations
      when 'validates', 'validates_presence_of', 'validates_uniqueness_of',
           'validates_length_of', 'validates_numericality_of', 'validates_format_of'
        emit_validation(method, node)

      # Callbacks
      when 'before_create', 'after_create', 'before_save', 'after_save',
           'before_update', 'after_update', 'before_destroy', 'after_destroy'
        emit_callback(method, node)

      # Enums
      when 'enum'
        emit_enum(node)
      end
    end

    def emit_association(type, node)
      return unless node.arguments&.arguments&.first

      arg = node.arguments.arguments.first
      target = case arg
      when Prism::SymbolNode then arg.unescaped
      when Prism::StringNode then arg.unescaped
      else nil
      end

      return unless target

      # Parse options
      options = {}
      if node.arguments.arguments.size > 1
        node.arguments.arguments[1..].each do |opt|
          if opt.is_a?(Prism::KeywordHashNode)
            opt.elements.each do |elem|
              if elem.is_a?(Prism::AssocNode)
                key = elem.key.unescaped rescue nil
                value = extract_value(elem.value) rescue nil
                options[key] = value if key
              end
            end
          end
        end
      end

      relation_name = target.to_s
      target_class = options['class_name'] || relation_name.capitalize

      @entities[@current_class][:relationships] << {
        type: type,
        target: target_class,
        name: relation_name,
        optional: options['optional'] == true
      }
    end

    def emit_validation(type, node)
      return unless node.arguments&.arguments&.first

      field = extract_symbol(node.arguments.arguments.first)
      return unless field

      validation = { field: field, type: type.to_s }

      # Extract validation options
      if node.arguments.arguments.size > 1
        node.arguments.arguments[1..].each do |opt|
          if opt.is_a?(Prism::KeywordHashNode)
            opt.elements.each do |elem|
              if elem.is_a?(Prism::AssocNode)
                key = elem.key.unescaped rescue nil
                value = extract_value(elem.value) rescue nil
                validation[key] = value if key
              end
            end
          end
        end
      end

      @entities[@current_class][:validations] << validation
    end

    def emit_callback(type, node)
      return unless node.arguments&.arguments&.first

      method = extract_symbol(node.arguments.arguments.first)
      return unless method

      @entities[@current_class][:callbacks] << {
        type: type,
        method: method
      }
    end

    def emit_enum(node)
      return unless node.arguments&.arguments&.first

      arg = node.arguments.arguments.first
      if arg.is_a?(Prism::KeywordHashNode)
        arg.elements.each do |elem|
          if elem.is_a?(Prism::AssocNode)
            field = elem.key.unescaped rescue nil
            values = extract_array_values(elem.value) rescue []

            if field && values.any?
              @entities[@current_class][:fields] << {
                name: field,
                type: :enum,
                values: values
              }
            end
          end
        end
      end
    end

    def public_method?(name)
      !name.start_with?('_') && !%w[initialize].include?(name)
    end

    def extract_params(node)
      return [] unless node.parameters

      params = []
      node.parameters.requireds&.each do |p|
        params << { name: p.name.to_s, required: true }
      end
      node.parameters.optionals&.each do |p|
        params << { name: p.name.to_s, required: false }
      end
      params
    end

    def detect_result_type(node)
      # Simple heuristic: look at return statements
      return nil unless node.body

      # Default to entity name if in model
      @current_class
    end

    def extract_constraints(node)
      constraints = []

      # Walk method body looking for conditionals
      return constraints unless node.body

      visitor = ConstraintVisitor.new
      visitor.visit(node.body)
      visitor.constraints
    end

    def extract_triggers(node)
      triggers = []

      # Look for method calls that might be triggers
      # (mailers, jobs, broadcasts, etc.)
      return triggers unless node.body

      visitor = TriggerVisitor.new
      visitor.visit(node.body)
      visitor.triggers
    end

    def extract_symbol(node)
      case node
      when Prism::SymbolNode then node.unescaped
      when Prism::StringNode then node.unescaped
      else nil
      end
    end

    def extract_value(node)
      case node
      when Prism::IntegerNode then node.value
      when Prism::StringNode then node.unescaped
      when Prism::SymbolNode then node.unescaped
      when Prism::TrueNode then true
      when Prism::FalseNode then false
      else nil
      end
    end

    def extract_array_values(node)
      return [] unless node.is_a?(Prism::ArrayNode)

      node.elements.map { |el| extract_value(el) }.compact
    end

    def build
      output = []

      # Emit application root if we have a namespace
      if @current_namespace || @entities.any?
        output << "@app"
        output << ""
      end

      # Emit namespaces
      if @current_namespace
        output << "::#{@current_namespace.downcase}"
        output << ""
      end

      # Emit entities
      @entities.each do |name, entity|
        output << build_entity(name, entity)
        output << ""
      end

      # Emit relationships
      @entities.each do |name, entity|
        entity[:relationships].each do |rel|
          output << build_relationship(name, rel)
        end
      end

      output << "" if @entities.any?

      # Emit features
      @features.each do |feature|
        output << build_feature(feature)
        output << ""
      end

      output.join("\n").strip
    end

    def build_entity(name, entity)
      fields = []

      # Add validations as field constraints
      entity[:validations].each do |val|
        field_name = val[:field]

        # Determine if required
        required = val[:type]&.include?('presence')
        suffix = required ? '!' : '?'

        # Check for enum
        enum_field = entity[:fields].find { |f| f[:name] == field_name && f[:type] == :enum }
        if enum_field
          values = enum_field[:values].map { |v| v.to_s }.join(',')
          fields << "#{field_name}∈[#{values}]"
        else
          fields << "#{field_name}#{suffix}"
        end
      end

      # Add relationship fields
      entity[:relationships].each do |rel|
        if rel[:type] == 'belongs_to'
          suffix = rel[:optional] ? '' : ''
          fields << "#{rel[:target]}⊂#{rel[:name]}"
        end
      end

      "#{name}{#{fields.join(',')}}"
    end

    def build_relationship(entity_name, rel)
      case rel[:type]
      when 'has_many'
        "#{entity_name}⊃#{rel[:target]}:#{rel[:name]}"
      when 'has_one'
        optional = rel[:optional] ? '?' : ''
        "#{entity_name}⊃#{optional}#{rel[:target]}:#{rel[:name]}"
      when 'belongs_to'
        # Already handled in entity definition
        nil
      end
    end.compact

    def build_feature(feature)
      parts = ["##{feature[:name]}"]

      # Add result type
      if feature[:result]
        parts << "→#{feature[:result]}"
      end

      # Add constraints
      if feature[:constraints].any?
        constraint_str = feature[:constraints].join('∧')
        parts << "|#{constraint_str}"
      end

      # Add triggers
      if feature[:triggers].any?
        trigger_str = feature[:triggers].map { |t| "λ#{t}" }.join('∧')
        parts << "⟹#{trigger_str}"
      end

      parts.join
    end

    # Simple visitor to extract constraints from conditionals
    class ConstraintVisitor
      attr_reader :constraints

      def initialize
        @constraints = []
      end

      def visit(node)
        case node
        when Prism::IfNode
          @constraints << extract_condition(node.predicate)
        when Prism::UnlessNode
          @constraints << "!#{extract_condition(node.predicate)}"
        end

        node.compact_child_nodes.each { |n| visit(n) } if node.respond_to?(:compact_child_nodes)
      end

      def extract_condition(node)
        case node
        when Prism::CallNode
          "#{node.receiver&.name || 'value'}#{operator_symbol(node.name)}#{extract_arg(node)}"
        else
          "condition"
        end
      end

      def operator_symbol(op)
        case op.to_s
        when '>' then '>'
        when '<' then '<'
        when '>=' then '≥'
        when '<=' then '≤'
        when '==' then '='
        when '!=' then '≠'
        else op
        end
      end

      def extract_arg(node)
        return '' unless node.arguments&.arguments&.first

        arg = node.arguments.arguments.first
        case arg
        when Prism::IntegerNode then arg.value
        when Prism::StringNode then "\"#{arg.unescaped}\""
        else 'value'
        end
      end
    end

    # Simple visitor to extract triggers (method calls that look like side effects)
    class TriggerVisitor
      attr_reader :triggers

      def initialize
        @triggers = []
      end

      def visit(node)
        case node
        when Prism::CallNode
          method = node.name.to_s
          if trigger_method?(method)
            @triggers << method.sub(/!$/, '')
          end
        end

        node.compact_child_nodes.each { |n| visit(n) } if node.respond_to?(:compact_child_nodes)
      end

      def trigger_method?(method)
        method.match?(/_mailer|_job|broadcast|notify|send_|deliver|enqueue/)
      end
    end
  end
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: ruby ilx_domain_emitter.rb <file.rb|directory>"
    puts "\nDependencies: gem install prism rbs"
    exit 1
  end

  path = ARGV[0]
  emitter = ILX::DomainEmitter.new

  if File.directory?(path)
    puts emitter.emit_dir(path)
  else
    puts emitter.emit_file(path)
  end
end
