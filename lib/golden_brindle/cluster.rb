
module Cluster
  
  module Base
    include GoldenBrindle::Command::Base
    
    def configure 
      options [ 
        ["-c", "--conf_path PATH", "Path to golden_brindle configuration files", :@cwd, "."],
        ["-V", "", "Verbose output", :@verbose, false]
      ]
    end
    
    def validate
      @cwd = File.expand_path(@cwd)
      valid_dir? @cwd, "Invalid path to golden_brindle configuration files: #{@cwd}"
      return false unless @valid
    end

    def run
      command = self.class.to_s.downcase.split('::')[1]
      counter = 0
      errors = 0
      Dir.chdir @cwd do
        confs =  Dir.glob("*.yml")
        confs += Dir.glob("*.conf")
        confs.each do |conf|
          cmd = "golden_brindle #{command} -C #{conf}"
          cmd += " -d" if command == "start" #daemonize only when start
          puts cmd if @verbose 
          output = `#{cmd}`
          puts output if @verbose
          status = $?.success?
          puts "golden_brindle #{command} returned an error." unless status
          counter += 1 if status
          errors += 1 unless status
        end
      end
      puts "Success:#{counter}; Errors: #{errors}"
    end
    
  end
  
  class Start < GemPlugin::Plugin "/commands"
    include Cluster::Base
    
  end
  
  class Stop < GemPlugin::Plugin "/commands"
    include Cluster::Base
  end
  
  class Restart < GemPlugin::Plugin "/commands"
    include Cluster::Base
  end
  
end
