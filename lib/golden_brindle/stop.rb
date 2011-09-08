module Brindle
  
  class Stop < GemPlugin::Plugin "/commands"
    include GoldenBrindle::Base
    
    def configure 
      options [ 
        ['-c', '--chdir PATH', "Change to dir before starting (will be expanded).", :@cwd, "."],
        ['-C', '--config PATH', "Use a mongrel based config file", :@config_file, nil],
        ['-f', '--force', "Force the shutdown (kill -9).", :@force, false],
        ['-w', '--wait SECONDS', "Wait SECONDS before forcing shutdown", :@wait, "0"], 
        ['-P', '--pid FILE', "Where the PID file is located.", :@pid_file, "tmp/pids/unicorn.pid"]
      ]
    end

    def validate
      if @config_file
        valid_exists?(@config_file, "Config file not there: #@config_file")
        @config_file = File.expand_path(@config_file)
        load_config
        return @valid
      end
      
      @cwd = File.expand_path(@cwd)
      valid_dir? @cwd, "Invalid path to change to during daemon mode: #@cwd"
      valid_exists? File.join(@cwd,@pid_file), "PID file #@pid_file does not exist.  Not running?"
      return @valid
    end

    def run
      @pid_file = File.join(@cwd,@pid_file)
      if @force
        @wait.to_i.times do |waiting|
          exit(0) if not File.exist? @pid_file
          sleep 1
        end
        GoldenBrindle::send_signal("KILL", @pid_file) if File.exist? @pid_file
      else
        GoldenBrindle::send_signal("TERM", @pid_file)
      end
    end
    
  end
  
end
