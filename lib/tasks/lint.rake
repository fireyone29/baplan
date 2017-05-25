namespace :lint do
  begin
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new(:rubocop)
  rescue LoadError
    task :rubocop do
      puts 'Could not load rubocop!'
    end
  end
end

desc 'Run All Linting'
task lint: %w[lint:rubocop]
