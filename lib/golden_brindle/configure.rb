module Brindle
  
  class Configure < GemPlugin::Plugin "/commands"
    include GoldenBrindle::Command::Base
    
    def configure
        options [
          ["-e", "--environment ENV", "Rails environment to run as", :@environment, ENV['RAILS_ENV'] || "development"],
          ["-d", "--daemonize", "Run daemonized in the background", :@daemon, false],
          ['', "--preload", "Preload application", :@preload, false],
          ['-p', '--port PORT', "Which port to bind to (if set numbers of servers - start port number)", :@port, Unicorn::Const::DEFAULT_PORT],
          ['-a', '--address ADDR', "Address to bind to", :@address, Unicorn::Const::DEFAULT_HOST],
          ['-o', '--listen {HOST:PORT|PATH}',"listen on HOST:PORT or PATH, separeted by comma ", :@listen, nil] ,
          ['-l', '--log FILE', "Where to write log messages", :@log_file, "log/unicorn.log"],
          ['-P', '--pid FILE', "Where to write the PID", :@pid_file, "tmp/pids/unicorn.pid"],
          ['-n', '--num-workers INT', "Number of Unicorn workers", :@workers, 4],
          ['-N', '--num-servers INT', "Number of Unicorn listen records", :@servers, 1],
          ['-t', '--timeout TIME', "Time to wait (in seconds) before killing a stalled thread", :@timeout, 60],
          ['-c', '--chdir PATH', "Change to dir before starting (will be expanded)", :@cwd, Dir.pwd],
          ['-D', '--debug', "Enable debugging mode", :@debug, false],
          ['-C', '--config PATH', "Path to brindle configuration file", :@config_file, "config/brindle.yml"],
          ['-S', '--script PATH', "Load the Unicorn-specific config file", :@config_script, nil],
          ['', '--user USER', "User to run as", :@user, nil],
          ['', '--group GROUP', "Group to run as", :@group, nil],
          ['', '--prefix PATH', "URL prefix for Rails app", :@prefix, nil]
        ]
    end
    
    def validate
      
      valid_dir? File.dirname(@config_file), "Path to config file not valid: #{@config_file}"
      
      if @config_script
        valid_exists?(@config_script, "Unicorn-specific config file not there: #@config_script")
        return false unless @valid
      end

      valid?(@prefix[0] == ?/ && @prefix[-1] != ?/, "Prefix must begin with / and not end in /") if @prefix
      valid_dir? File.dirname(@log_file), "Path to log file not valid: #@log_file"
      valid_dir? File.dirname(@pid_file), "Path to pid file not valid: #@pid_file"
      valid_user? @user if @user
      valid_group? @group if @group
      return @valid
    end
    
    def run
      
      file_options = {}
      
      self.config_keys.each do |key|
        key_val = self.instance_variable_get "@#{key}"
        file_options[key] = key_val unless key_val.nil?
      end
        
      $stdout.puts "Writing configuration file to #{@config_file}."
      File.open(@config_file,"w") {|f| f.write(file_options.to_yaml)}
      
    end
    
  end
  
end