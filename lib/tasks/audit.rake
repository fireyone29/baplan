namespace :audit do
  begin
    require 'bundler/audit/cli'
    desc 'Updates the ruby-advisory-db then runs bundle-audit'
    task :bundle do
      %w(update check).each do |command|
        Bundler::Audit::CLI.start [command]
      end
    end
  rescue LoadError
    task :bundle_audit do
      puts 'Could not load bundler audit!'
    end
  end
end

desc 'Run all security audits'
task audit: %w(audit:bundle)
