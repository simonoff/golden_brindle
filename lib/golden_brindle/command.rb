module GoldenBrindle

  class << self
    def send_signal(signal, pid_file)
      pid = open(pid_file).read.to_i
      print "Sending #{signal} to Unicorn at PID #{pid}..."
      begin
        Process.kill(signal, pid)
      rescue Errno::ESRCH
        puts "Process does not exist. Not running."
      end
      puts "Done."
    end
  end

  # A Singleton class that manages all of the available commands
  # and handles running them.
  class Registry
    include Singleton

    # Builds a list of possible commands from the Command derivates list
    def commands
      pmgr = GemPlugin::Manager.instance
      list = pmgr.plugins["/commands"].keys
      list.sort
    end

    # Prints a list of available commands.
    def print_command_list
      puts "#{GoldenBrindle::Const::BANNER}\nAvailable commands are:\n\n"

      self.commands.each do |name|
        if /brindle::/ =~ name
          name = name[9 .. -1]
        end

        puts " - #{name[1 .. -1]}\n"
      end

      puts "\nEach command takes -h as an option to get help."

    end


    # Runs the args against the first argument as the command name.
    # If it has any errors it returns a false, otherwise it return true.
    def run(args)
      # find the command
      cmd_name = args.shift

      if !cmd_name or cmd_name == "?" or cmd_name == "help"
        print_command_list
        return true
      elsif cmd_name == "--version"
        puts "Golden Brindle #{GoldenBrindle::Const::VERSION}"
        return true
      end

      begin
        if ["start", "stop", "restart", "configure", "reload"].include? cmd_name
          cmd_name = "brindle::" + cmd_name
        end
        command = GemPlugin::Manager.instance.create("/commands/#{cmd_name}", :argv => args)
      rescue OptionParser::InvalidOption
        STDERR.puts "#$! for command '#{cmd_name}'"
        STDERR.puts "Try #{cmd_name} -h to get help."
        return false
      rescue
        STDERR.puts "ERROR RUNNING '#{cmd_name}': #$!"
        STDERR.puts "Use help command to get help"
        return false
      end

      # Normally the command is NOT valid right after being created
      # but sometimes (like with -h or -v) there's no further processing
      # needed so the command is already valid so we can skip it.
      if !command.done_validating
        if !command.validate
          STDERR.puts "#{cmd_name} reported an error. Use golden_brindle #{cmd_name} -h to get help."
          return false
        else
          command.run
        end
      end

      true
    end
  end
    
end