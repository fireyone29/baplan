# Ensure factories are valid before running tests
task spec: 'factory_girl:lint'

namespace :spec do
  desc 'Run tests and produce coverage report'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec'].invoke
  end
end
