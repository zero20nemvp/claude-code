#!/usr/bin/env ruby
# frozen_string_literal: true

# ILX Emitter Hook for AgentC
# Automatically generates ILX semantic graphs when Ruby/ERB files are written/edited
#
# ON BY DEFAULT - Use DISABLE_ILX_EMITTER=1 to turn off

require 'json'
require 'fileutils'
require 'pathname'

# Configuration
DOMAIN_EMITTER = File.join(ENV['CLAUDE_PLUGIN_ROOT'], 'scripts/ilx_domain_emitter.rb')
VIEW_EMITTER = File.join(ENV['CLAUDE_PLUGIN_ROOT'], 'scripts/ilx_view_emitter.rb')
DEBUG_LOG = "/tmp/ilx-emitter-hook.log"

def debug_log(message)
  File.open(DEBUG_LOG, 'a') do |f|
    f.puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}"
  end
rescue
  # Silent fail on logging errors
end

def find_project_root(file_path)
  # Walk up from file_path to find Gemfile or git root
  path = Pathname.new(file_path).expand_path

  loop do
    break path if File.exist?(path / 'Gemfile')
    break path if File.exist?(path / '.git')

    parent = path.parent
    break nil if parent == path # Reached filesystem root
    path = parent
  end
end

def generate_ilx_output_path(file_path, project_root)
  # Convert /project/app/models/user.rb
  # to      /project/.agentc/ilx/app/models/user.ilx
  # Convert /project/app/views/users/show.html.erb
  # to      /project/.agentc/ilx/app/views/users/show.ilx

  relative_path = Pathname.new(file_path).relative_path_from(project_root)
  ilx_dir = project_root / '.agentc' / 'ilx'

  # Remove .html.erb or .rb extension, add .ilx
  output_file = relative_path.to_s.sub(/\.html\.erb$/, '').sub(/\.rb$/, '') + '.ilx'
  output_path = ilx_dir / output_file

  output_path
end

def check_dependencies
  # Check if prism and rbs gems are available (for domain emitter)
  begin
    require 'prism'
    require 'rbs'
    true
  rescue LoadError => e
    warn "ILX Domain Emitter Warning: Missing dependency - #{e.message}"
    warn "Run: gem install prism rbs"
    false
  end
end

def check_view_dependencies
  # Check if nokogiri is available (for view emitter)
  begin
    require 'nokogiri'
    true
  rescue LoadError => e
    warn "ILX View Emitter Warning: Missing dependency - #{e.message}"
    warn "Run: gem install nokogiri"
    false
  end
end

def find_rbs_file(rb_path, project_root)
  # Look for .rbs file in standard locations:
  # 1. Same directory as .rb (co-located)
  # 2. sig/ directory mirroring structure

  co_located = Pathname.new(rb_path).sub_ext('.rbs')
  return co_located.to_s if File.exist?(co_located)

  # Check sig/ directory
  relative = Pathname.new(rb_path).relative_path_from(project_root)
  sig_path = project_root / 'sig' / relative.sub_ext('.rbs')
  return sig_path.to_s if File.exist?(sig_path)

  nil
end

def emit_domain_ilx(file_path)
  debug_log("Processing Ruby file: #{file_path}")

  # Find project root
  project_root = find_project_root(file_path)
  unless project_root
    debug_log("No project root found for #{file_path}, skipping ILX generation")
    return
  end

  debug_log("Project root: #{project_root}")

  # Determine output path
  output_path = generate_ilx_output_path(file_path, project_root)
  FileUtils.mkdir_p(output_path.dirname)

  debug_log("Output path: #{output_path}")

  # Check for corresponding .rbs file
  rbs_path = find_rbs_file(file_path, project_root)

  debug_log("RBS path: #{rbs_path || 'none'}")

  # Run the domain emitter
  cmd = ['ruby', DOMAIN_EMITTER, file_path]
  cmd << rbs_path if rbs_path

  debug_log("Executing: #{cmd.join(' ')}")

  result = `#{cmd.join(' ')} 2>&1`

  if $?.success?
    File.write(output_path, result)
    debug_log("Successfully generated: #{output_path}")
  else
    debug_log("ILX domain emission failed: #{result}")
    warn "ILX Domain Emitter Warning: Failed to generate ILX for #{file_path}"
  end
rescue => e
  debug_log("Error: #{e.class}: #{e.message}")
  debug_log(e.backtrace.join("\n"))
  warn "ILX Domain Emitter Error: #{e.message}"
end

def emit_view_ilx(file_path)
  debug_log("Processing ERB view: #{file_path}")

  # Find project root
  project_root = find_project_root(file_path)
  unless project_root
    debug_log("No project root found for #{file_path}, skipping ILX generation")
    return
  end

  debug_log("Project root: #{project_root}")

  # Determine output path
  output_path = generate_ilx_output_path(file_path, project_root)
  FileUtils.mkdir_p(output_path.dirname)

  debug_log("Output path: #{output_path}")

  # Run the view emitter
  cmd = ['ruby', VIEW_EMITTER, file_path]

  debug_log("Executing: #{cmd.join(' ')}")

  result = `#{cmd.join(' ')} 2>&1`

  if $?.success?
    File.write(output_path, result)
    debug_log("Successfully generated: #{output_path}")
  else
    debug_log("ILX view emission failed: #{result}")
    warn "ILX View Emitter Warning: Failed to generate ILX for #{file_path}"
  end
rescue => e
  debug_log("Error: #{e.class}: #{e.message}")
  debug_log(e.backtrace.join("\n"))
  warn "ILX View Emitter Error: #{e.message}"
end

def main
  # Check if ILX generation is DISABLED (default is ENABLED)
  if ENV['DISABLE_ILX_EMITTER'] == '1'
    debug_log("ILX generation disabled via DISABLE_ILX_EMITTER=1")
    exit 0
  end

  # Parse hook input
  begin
    input = JSON.parse($stdin.read)
  rescue JSON::ParserError => e
    debug_log("JSON parse error: #{e}")
    exit 0 # Allow tool to proceed
  end

  tool_name = input['tool_name']
  tool_input = input['tool_input'] || {}

  # Only process Write/Edit/MultiEdit
  exit 0 unless %w[Write Edit MultiEdit].include?(tool_name)

  file_path = tool_input['file_path']
  exit 0 unless file_path

  # Skip files in vendor/ or test fixtures
  exit 0 if file_path.include?('/vendor/') || file_path.include?('/spec/fixtures/')

  debug_log("Hook triggered for #{tool_name} on #{file_path}")

  # Determine file type and emit appropriate ILX
  if file_path.end_with?('.rb')
    # Ruby file → domain ILX
    exit 0 unless check_dependencies
    emit_domain_ilx(file_path)
  elsif file_path.end_with?('.html.erb', '.erb')
    # ERB view → view ILX
    exit 0 unless check_view_dependencies
    emit_view_ilx(file_path)
  end

  # Always allow tool to proceed
  exit 0
end

main if __FILE__ == $PROGRAM_NAME
