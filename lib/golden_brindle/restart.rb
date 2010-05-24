module Brindle
  
  class Restart < GemPlugin::Plugin "/commands"
    include GoldenBrindle::Command::Base
    
    def configure 
      options [ 
        ['-c', '--chdir PATH', "Change to dir before starting (will be expanded).", :@cwd, "."],
        ['-C', '--config PATH', "Use a mongrel based config file", :@config_file, nil],
        ['-s', '--soft', "Do a soft restart rather than a process exit restart", :@soft, false],
        ['-P', '--pid FILE', "Where the PID file is located.", :@pid_file, "tmp/pids/unicorn.pid"]
      ]
    end

    def validate
      if @config_file
        valid_exists?(@config_file, "Config file not there: #@config_file")
        return false unless @valid
        @config_file = File.expand_path(@config_file)
        load_config
        return false unless @valid
      end
      
      @cwd = File.expand_path(@cwd)
      valid_dir? @cwd, "Invalid path to change to during daemon mode: #@cwd"
      return false unless @valid
      Dir.chdir @cwd

      valid_exists? @pid_file, "PID file #@pid_file does not exist.  Not running?"
      return @valid
    end

    def run
      if @soft
        GoldenBrindle::send_signal("HUP", @pid_file)
      else
        GoldenBrindle::send_signal("USR2", @pid_file)
      end
    end
    
  end
  
end