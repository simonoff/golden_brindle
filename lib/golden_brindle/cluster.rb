
module Cluster
  
  module Base
    include GoldenBrindle::Command::Base
    
    def configure 
      options [ 
        ["-c", "--conf_path PATH", "Path to golden_brindle configuration files", :@cwd, "."],
        ["-V", "", "Verbose output", :@verbose, "."]
      ]
    end
    
    def run
      command = self.class.to_s.downcase.split('::')[1]
      Dir.chdir @cwd do
        confs =  Dir.glob("*.yml")
        confs += Dir.glob("*.conf")
        confs.each do |conf|
          cmd = "golden_brindle cluster::#{command} -C #{conf}"
          cmd += " -v" if @verbose
          puts cmd if @verbose 
          output = `#{cmd}`
          puts output if @verbose
          puts "golden_brindle cluster::#{command} returned an error." unless $?.success?     
        end
      end
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