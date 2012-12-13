$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "bundler/gem_tasks"
require "bundler/setup"

$:.unshift("./lib/")
require './lib/accordion_view'

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AccordionView'

  # Temporary, until RubyMotion patches its test loader
  # spec_files = app.spec_files + Dir.glob(File.join(app.specs_dir, '**/*.rb'))
  # spec_files.uniq!
  # app.instance_variable_set(:@spec_files, spec_files)
end