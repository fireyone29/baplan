namespace :docs do
  begin
    require 'yard'
    YARD::Rake::YardocTask.new(:yard) do |t|
      t.files = %w[app/**/*.rb lib/**/*.rb - LICENSE.md]
      t.stats_options = ['--list-undoc']
    end
  rescue LoadError
    task :yard do
      puts 'Could not load yard!'
    end
  end
end

desc 'Generate All Documentation'
task docs: %w[docs:yard]
