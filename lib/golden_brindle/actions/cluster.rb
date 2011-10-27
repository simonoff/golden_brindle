module GoldenBrindle

  module Cluster
    class Base < ::GoldenBrindle::Base
      def configure
        options [
          ["-c", "--conf_path PATH", "Path to golden_brindle configuration files", :@cwd, "."],
          ["-V", "", "Verbose output", :@verbose, false],
          ["-b", "", "Start server with bundler", :@bundler, false]
        ]
      end

      def validate
        @cwd = File.expand_path(@cwd)
        valid_dir? @cwd, "Invalid path to golden_brindle configuration files: #{@cwd}"
        @valid
      end

      def run
        command = self.class.to_s.downcase.split('::').last
        counter = 0
        errors = 0
        Dir.chdir @cwd do
          Dir.glob("**/*.{yml,conf}").each do |conf|
            cmd = "golden_brindle #{command} -C #{File.join(@cwd,conf)}"
            cmd << " -d true" if command == "start" #daemonize only when start
            cmd << " -b true" if @bundler
            puts cmd if @verbose
            output = `#{cmd}`
            puts output if @verbose
            status = $?.success?
            puts "golden_brindle #{command} returned an error." unless status
            status ? counter += 1 : errors += 1
          end
        end
        puts "Success:#{counter}; Errors: #{errors}"
      end
    end
  end

  module Actions
    module Cluster

      class Start < ::GoldenBrindle::Cluster::Base; end

      class Stop < ::GoldenBrindle::Cluster::Base; end

      class Restart < ::GoldenBrindle::Cluster::Base; end

    end
  end
end
