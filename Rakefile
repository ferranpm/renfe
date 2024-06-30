# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
Minitest::TestTask.create

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "bundler/audit/task"
Bundler::Audit::Task.new

task default: %i[test rubocop bundle:audit:update bundle:audit]
