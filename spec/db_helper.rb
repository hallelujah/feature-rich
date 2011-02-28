# Extracted from rails-2.3.5/railties/lib/tasks/databases.rake
def create_database(config)
  begin
    if config['adapter'] =~ /sqlite/
      if File.exist?(config['database'])
        $stderr.puts "#{config['database']} already exists"
      else
        begin
          # Create the SQLite database
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Base.connection
        rescue
          $stderr.puts $!, *($!.backtrace)
          $stderr.puts "Couldn't create database for #{config.inspect}"
        end
      end
    return # Skip the else clause of begin/rescue    
    else
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end
  rescue
    case config['adapter']
    when 'mysql'
      @charset   = ENV['CHARSET']   || 'utf8'
      @collation = ENV['COLLATION'] || 'utf8_unicode_ci'
      begin
        ActiveRecord::Base.establish_connection(config.merge('database' => nil))
        ActiveRecord::Base.connection.create_database(config['database'], :charset => (config['charset'] || @charset), :collation => (config['collation'] || @collation))
        ActiveRecord::Base.establish_connection(config)
      rescue
        $stderr.puts "Couldn't create database for #{config.inspect}, charset: #{config['charset'] || @charset}, collation: #{config['collation'] || @collation} (if you set the charset manually, make sure you have a matching collation)"
      end
    when 'postgresql'
      @encoding = config[:encoding] || ENV['CHARSET'] || 'utf8'
      begin
        ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
        ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
        ActiveRecord::Base.establish_connection(config)
      rescue
        $stderr.puts $!, *($!.backtrace)
        $stderr.puts "Couldn't create database for #{config.inspect}"
      end
    end
  else
    $stderr.puts "#{config['database']} already exists"
  end
end

def drop_database(config)
  case config['adapter']
  when 'mysql'
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.drop_database config['database']
  when /^sqlite/
    FileUtils.rm(File.join(MyROOT, config['database']))
  when 'postgresql'
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.drop_database config['database']
  end
end

config = YAML.load(ERB.new(IO.read(File.expand_path( '../db.yml',__FILE__ ))).result(binding))
ActiveRecord::Base.configurations = config.with_indifferent_access
ActiveRecord::Base.establish_connection :development

logfile = File.open(File.expand_path('../log/database.log',__FILE__), 'a')    
logfile.sync = true
ActiveRecord::Base.logger = Logger.new(logfile)

def migrate!(config)
  migrator = ActiveRecord::Migrator.new(:up,File.expand_path('../db/migrate',__FILE__),nil)
  #if ! migrator.pending_migrations.blank? || ENV['REMIGRATE']
    # Drop database
    drop_database(config) 
    # Create database
    create_database(config)
    # Migrate up
    puts "Migrate up"
    ActiveRecord::Migrator.migrate(File.expand_path('../db/migrate',__FILE__),nil)
#  end
end

migrate!(config['development'])
