#!/usr/bin/env ruby
# frozen_string_literal: true

# ILX Emitter: Ruby + RBS → ILX
#
# Dependencies:
#   gem install prism rbs
#
# Usage:
#   ruby ruby_emitter.rb file.rb              # emit ILX
#   ruby ruby_emitter.rb file.rb file.rbs     # with RBS types
#   ruby ruby_emitter.rb app/models/          # whole directory

require 'prism'
require 'rbs'

module ILX
  class Emitter
    VERSION = "0.1.0"
    
    TYPE_MAP = {
      'String' => 'S', 'Integer' => 'I', 'Int' => 'I',
      'Bool' => 'B', 'Boolean' => 'B', 'TrueClass' => 'B', 'FalseClass' => 'B',
      'NilClass' => 'U', 'void' => 'U', 'nil' => 'U', 'Float' => 'I'
    }
    
    PRIM = {
      '+' => '+', '-' => '-', '*' => '*', '/' => '/', '==' => '=',
      'puts' => 'p', 'print' => 'p', 'to_s' => 's', 'to_i' => 'i',
      'concat' => 'c', '<<' => 'c', 'length' => 'l', 'size' => 'l',
      '>' => '>', '<' => '<', '>=' => 'g', '<=' => 'l', '!=' => 'n',
      '&&' => '&', '||' => '|', '!' => '!'
    }
    
    def initialize
      @nodes = []
      @rbs = {}
      @params = []
      @locals = {}
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
      Dir.glob("#{dir}/**/*.rb").map { |f| emit_file(f) }.join(';')
    end
    
    def emit(code, file = 'unknown.rb')
      @source = file
      @nodes = []
      result = Prism.parse(code)
      raise "Parse error: #{result.errors.map(&:message).join(', ')}" if result.failure?
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
      when Prism::ModuleNode then walk(node.body) if node.body
      when Prism::DefNode then emit_method(node)
      when Prism::StringNode then emit_lit('S', "\"#{node.unescaped}\"")
      when Prism::InterpolatedStringNode then emit_interpolated_string(node)
      when Prism::IntegerNode then emit_lit('I', node.value)
      when Prism::FloatNode then emit_lit('I', node.value.to_i)
      when Prism::TrueNode then emit_lit('B', 1)
      when Prism::FalseNode then emit_lit('B', 0)
      when Prism::NilNode then emit_lit('U', 0)
      when Prism::SymbolNode then emit_lit('S', "\"#{node.unescaped}\"")
      when Prism::CallNode then emit_call(node)
      when Prism::LocalVariableReadNode then emit_local_read(node)
      when Prism::LocalVariableWriteNode then emit_local_write(node)
      when Prism::InstanceVariableReadNode then emit_ivar_read(node)
      when Prism::InstanceVariableWriteNode then emit_ivar_write(node)
      when Prism::IfNode then emit_if(node)
      when Prism::UnlessNode then emit_unless(node)
      when Prism::WhileNode then emit_while(node)
      when Prism::CaseNode then emit_case(node)
      when Prism::AndNode then emit_binary(node, '&')
      when Prism::OrNode then emit_binary(node, '|')
      when Prism::ArrayNode then emit_array(node)
      when Prism::HashNode then emit_hash(node)
      when Prism::RangeNode then emit_range(node)
      when Prism::BlockNode then emit_block(node)
      when Prism::LambdaNode then emit_lambda(node)
      when Prism::ReturnNode then walk(node.arguments&.arguments&.first)
      when Prism::ParenthesesNode then walk(node.body)
      when Prism::BeginNode then walk(node.statements)
      else
        node.compact_child_nodes.each { |n| walk(n) } if node.respond_to?(:compact_child_nodes)
      end
    end
    
    def emit_class(node)
      name = node.constant_path.name.to_s rescue 'Unknown'
      @current_class = name
      walk(node.body) if node.body
      @current_class = nil
    end
    
    def emit_method(node)
      name = node.name.to_s
      line = node.location.start_line
      @current_method = name
      @params = node.parameters&.requireds&.map { |p| p.name.to_s } || []
      @locals = {}
      
      sig = @rbs[name]
      in_t = sig ? map_rbs(sig.type.required_positionals.first&.type) : 'S'
      out_t = sig ? map_rbs(sig.type.return_type) : 'S'
      
      src = [@source, line, name].compact.join(':')
      body_start = @nodes.size
      walk(node.body) if node.body
      body_idx = [@nodes.size - 1, body_start].max
      
      @nodes << { k: 'F', t: "#{in_t}#{out_t}", body: body_idx, src: src }
      @current_method = nil
      @params = []
      @nodes.size - 1
    end
    
    def emit_lit(t, v)
      @nodes << { k: 'L', t: t, v: v }
      @nodes.size - 1
    end
    
    def emit_interpolated_string(node)
      parts = node.parts.map do |part|
        case part
        when Prism::StringNode then emit_lit('S', "\"#{part.unescaped}\"")
        when Prism::EmbeddedStatementsNode
          walk(part.statements)
          prev = @nodes.size - 1
          @nodes << { k: 'A', t: 'S', f: 's', args: prev.to_s(36) }
          @nodes.size - 1
        else
          walk(part)
          @nodes.size - 1
        end
      end
      
      return parts.first if parts.size == 1
      
      result = parts.first
      parts[1..].each do |p|
        @nodes << { k: 'A', t: 'S', f: 'c', args: "#{result.to_s(36)}#{p.to_s(36)}" }
        result = @nodes.size - 1
      end
      result
    end
    
    def emit_call(node)
      method = node.name.to_s
      
      args = []
      if node.receiver
        walk(node.receiver)
        args << (@nodes.size - 1)
      end
      
      node.arguments&.arguments&.each do |arg|
        result = walk(arg)
        args << (result || @nodes.size - 1)
      end
      
      prim = PRIM[method]
      func = prim || method[0..1]
      arg_str = args.map { |a| a.is_a?(String) ? a : a.to_s(36) }.join
      
      @nodes << { k: 'A', t: 'S', f: func, args: arg_str }
      @nodes.size - 1
    end
    
    def emit_local_read(node)
      name = node.name.to_s
      if @params.include?(name)
        "p#{@params.index(name)}"
      elsif @locals[name]
        @locals[name].to_s(36)
      else
        emit_lit('U', 0)
      end
    end
    
    def emit_local_write(node)
      name = node.name.to_s
      walk(node.value)
      @locals[name] = @nodes.size - 1
      @nodes.size - 1
    end
    
    def emit_ivar_read(node)
      name = node.name.to_s.sub('@', '')
      emit_lit('S', "\"@#{name}\"")  # placeholder
    end
    
    def emit_ivar_write(node)
      walk(node.value)
      @nodes.size - 1
    end
    
    def emit_if(node)
      walk(node.predicate)
      cond = @nodes.size - 1
      
      walk(node.statements) if node.statements
      then_idx = @nodes.size - 1
      
      else_idx = then_idx
      if node.consequent
        walk(node.consequent)
        else_idx = @nodes.size - 1
      end
      
      @nodes << { k: 'B', t: 'S', cond: cond.to_s(36), th: then_idx.to_s(36), el: else_idx.to_s(36) }
      @nodes.size - 1
    end
    
    def emit_unless(node)
      walk(node.predicate)
      cond = @nodes.size - 1
      
      else_idx = cond
      walk(node.statements) if node.statements
      then_idx = @nodes.size - 1
      
      if node.consequent
        walk(node.consequent)
        else_idx = @nodes.size - 1
      end
      
      # Unless flips then/else
      @nodes << { k: 'B', t: 'S', cond: cond.to_s(36), th: else_idx.to_s(36), el: then_idx.to_s(36) }
      @nodes.size - 1
    end
    
    def emit_while(node)
      # Simplified: emit as branch that references itself
      walk(node.predicate)
      cond = @nodes.size - 1
      walk(node.statements) if node.statements
      body = @nodes.size - 1
      @nodes << { k: 'W', t: 'U', cond: cond.to_s(36), body: body.to_s(36) }
      @nodes.size - 1
    end
    
    def emit_case(node)
      walk(node.predicate) if node.predicate
      pred = @nodes.size - 1
      
      # Emit as nested branches
      result = nil
      node.conditions.reverse_each do |cond|
        walk(cond.conditions.first)
        test = @nodes.size - 1
        walk(cond.statements) if cond.statements
        then_b = @nodes.size - 1
        else_b = result || then_b
        @nodes << { k: 'B', t: 'S', cond: test.to_s(36), th: then_b.to_s(36), el: else_b.to_s(36) }
        result = @nodes.size - 1
      end
      result
    end
    
    def emit_binary(node, op)
      walk(node.left)
      left = @nodes.size - 1
      walk(node.right)
      right = @nodes.size - 1
      @nodes << { k: 'A', t: 'B', f: op, args: "#{left.to_s(36)}#{right.to_s(36)}" }
      @nodes.size - 1
    end
    
    def emit_array(node)
      indices = node.elements.map do |el|
        walk(el)
        @nodes.size - 1
      end
      @nodes << { k: 'R', t: 'A', els: indices.map { |i| i.to_s(36) }.join }
      @nodes.size - 1
    end
    
    def emit_hash(node)
      pairs = node.elements.map do |el|
        walk(el.key)
        k = @nodes.size - 1
        walk(el.value)
        v = @nodes.size - 1
        "#{k.to_s(36)}:#{v.to_s(36)}"
      end
      @nodes << { k: 'M', t: 'H', pairs: pairs.join(',') }
      @nodes.size - 1
    end
    
    def emit_range(node)
      walk(node.left)
      l = @nodes.size - 1
      walk(node.right)
      r = @nodes.size - 1
      @nodes << { k: 'G', t: 'R', from: l.to_s(36), to: r.to_s(36) }
      @nodes.size - 1
    end
    
    def emit_block(node)
      @params = node.parameters&.parameters&.requireds&.map { |p| p.name.to_s } || []
      walk(node.body) if node.body
      body = @nodes.size - 1
      @nodes << { k: 'F', t: 'SS', body: body }
      @params = []
      @nodes.size - 1
    end
    
    def emit_lambda(node)
      emit_block(node.body)
    end
    
    def map_rbs(type)
      return 'S' unless type
      case type
      when RBS::Types::Bases::String then 'S'
      when RBS::Types::Bases::Int then 'I'
      when RBS::Types::Bases::Bool then 'B'
      when RBS::Types::Bases::Void, RBS::Types::Bases::Nil then 'U'
      when RBS::Types::ClassInstance
        TYPE_MAP[type.name.name.to_s] || 'S'
      else 'S'
      end
    end
    
    def build
      chunks = []
      src = nil
      
      @nodes.each_with_index do |n, i|
        parts = []
        if n[:src] && n[:src] != src
          parts << "@#{n[:src]}"
          src = n[:src]
        end
        
        case n[:k]
        when 'L' then parts << "L#{n[:t]}#{n[:v]}"
        when 'F' then parts << "F#{n[:t]}#{n[:body].to_s(36)}"
        when 'A' then parts << "A#{n[:t]}#{n[:f]}#{n[:args]}"
        when 'B' then parts << "B#{n[:t]}#{n[:cond]}#{n[:th]}#{n[:el]}"
        when 'H' then parts << "H#{n[:t]}"
        when 'W' then parts << "W#{n[:t]}#{n[:cond]}#{n[:body]}"
        when 'R' then parts << "R#{n[:t]}#{n[:els]}"
        when 'M' then parts << "M#{n[:t]}#{n[:pairs]}"
        when 'G' then parts << "G#{n[:t]}#{n[:from]}#{n[:to]}"
        end
        
        chunks << parts.join(';')
      end
      
      out = chunks.join(';')
      out += '*' unless out.empty?
      out
    end
  end
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: ruby ruby_emitter.rb <file.rb|directory> [file.rbs]"
    puts "\nDependencies: gem install prism rbs"
    exit 1
  end
  
  path = ARGV[0]
  emitter = ILX::Emitter.new
  
  if File.directory?(path)
    puts emitter.emit_dir(path)
  else
    emitter.load_rbs(ARGV[1]) if ARGV[1]
    puts emitter.emit_file(path)
  end
end
