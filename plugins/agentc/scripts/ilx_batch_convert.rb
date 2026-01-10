#!/usr/bin/env ruby
# frozen_string_literal: true

# ILX Batch Converter
# Converts all Ruby and ERB files in a project to ILX format
#
# Usage:
#   ruby ilx_batch_convert.rb /path/to/project

require 'pathname'
require 'fileutils'

DOMAIN_EMITTER = File.join(File.dirname(__FILE__), 'ilx_domain_emitter.rb')
VIEW_EMITTER = File.join(File.dirname(__FILE__), 'ilx_view_emitter.rb')

def find_ruby_files(root)
  # Find all .rb files, excluding vendor/ and test fixtures
  Dir.glob("#{root}/**/*.rb").reject do |path|
    path.include?('/vendor/') ||
    path.include?('/spec/fixtures/') ||
    path.include?('/test/fixtures/')
  end
end

def find_erb_files(root)
  # Find all .erb files, excluding vendor/ and test fixtures
  Dir.glob("#{root}/**/*.html.erb").reject do |path|
    path.include?('/vendor/') ||
    path.include?('/spec/fixtures/') ||
    path.include?('/test/fixtures/')
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

def emit_domain_ilx(rb_path, project_root)
  # Determine output path
  relative = Pathname.new(rb_path).relative_path_from(project_root)
  output_path = project_root / '.agentc' / 'ilx' / relative.sub_ext('.ilx')

  FileUtils.mkdir_p(output_path.dirname)

  # Find RBS file
  rbs_path = find_rbs_file(rb_path, project_root)

  # Build command
  cmd = ['ruby', DOMAIN_EMITTER, rb_path]
  cmd << rbs_path if rbs_path

  # Execute
  result = `#{cmd.join(' ')} 2>&1`

  if $?.success?
    File.write(output_path, result)
    puts "✓ #{relative} → #{output_path.relative_path_from(project_root)}"
    { success: true, file: rb_path, ilx: output_path.to_s, type: :domain }
  else
    warn "✗ #{relative}: #{result.lines.first&.strip}"
    { success: false, file: rb_path, error: result, type: :domain }
  end
end

def emit_view_ilx(erb_path, project_root)
  # Determine output path
  relative = Pathname.new(erb_path).relative_path_from(project_root)
  # Remove .html.erb, add .ilx
  output_file = relative.to_s.sub(/\.html\.erb$/, '') + '.ilx'
  output_path = project_root / '.agentc' / 'ilx' / output_file

  FileUtils.mkdir_p(output_path.dirname)

  # Build command
  cmd = ['ruby', VIEW_EMITTER, erb_path]

  # Execute
  result = `#{cmd.join(' ')} 2>&1`

  if $?.success?
    File.write(output_path, result)
    puts "✓ #{relative} → #{output_path.relative_path_from(project_root)}"
    { success: true, file: erb_path, ilx: output_path.to_s, type: :view }
  else
    warn "✗ #{relative}: #{result.lines.first&.strip}"
    { success: false, file: erb_path, error: result, type: :view }
  end
end

def main
  if ARGV.empty?
    puts "Usage: ruby ilx_batch_convert.rb <project-root>"
    puts "\nConverts all Ruby and ERB files in project to ILX format"
    puts "Output: <project-root>/.agentc/ilx/**/*.ilx"
    puts "\nDependencies:"
    puts "  gem install prism rbs nokogiri"
    exit 1
  end

  project_root = Pathname.new(ARGV[0]).expand_path

  unless project_root.directory?
    abort "Error: #{project_root} is not a directory"
  end

  puts "ILX Batch Conversion"
  puts "Project: #{project_root}"
  puts ""

  # Find all Ruby files
  ruby_files = find_ruby_files(project_root)
  erb_files = find_erb_files(project_root)

  if ruby_files.empty? && erb_files.empty?
    puts "No Ruby or ERB files found in #{project_root}"
    exit 0
  end

  puts "Found #{ruby_files.size} Ruby files"
  puts "Found #{erb_files.size} ERB files"
  puts ""

  results = []

  # Process Ruby files (domain)
  puts "=== Converting Ruby files to domain ILX ===" if ruby_files.any?
  ruby_files.each { |rb| results << emit_domain_ilx(rb, project_root) }

  puts "" if ruby_files.any? && erb_files.any?

  # Process ERB files (views)
  puts "=== Converting ERB files to view ILX ===" if erb_files.any?
  erb_files.each { |erb| results << emit_view_ilx(erb, project_root) }

  # Summary
  domain_successes = results.count { |r| r[:success] && r[:type] == :domain }
  domain_failures = results.count { |r| !r[:success] && r[:type] == :domain }
  view_successes = results.count { |r| r[:success] && r[:type] == :view }
  view_failures = results.count { |r| !r[:success] && r[:type] == :view }

  puts "\n" + "="*60
  puts "Conversion Complete"
  puts "  Domain (Ruby):"
  puts "    Success: #{domain_successes}"
  puts "    Failures: #{domain_failures}"
  puts "  Views (ERB):"
  puts "    Success: #{view_successes}"
  puts "    Failures: #{view_failures}"
  puts "  Output: #{project_root}/.agentc/ilx/"
  puts "="*60
end

main if __FILE__ == $PROGRAM_NAME
