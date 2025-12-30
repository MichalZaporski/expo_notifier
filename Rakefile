# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run Sorbet type checking'
task :typecheck do
  sh 'bundle exec srb tc'
end

task default: %i[test rubocop typecheck]
