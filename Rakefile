# Add your own tasks in files placed in lib/tasks ending in .rake, for
# example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc 'Fully verify the app'
task verify: %w[spec:coverage lint audit docs]
task v: :verify

task default: :verify
