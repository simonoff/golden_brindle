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

    class << self

      def constantize(camel_cased_word)
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?
        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end

      # Builds a list of possible commands from the Command derivates list
      def commands
        GoldenBrindle::Actions.constants.inject([]) do |memo, action|
          constants = constantize("GoldenBrindle::Actions::#{action.to_s}").constants
          if constants.empty?
            memo << action.to_s.downcase
          else
            constants.each do |subaction|
              memo << "#{action.to_s}::#{subaction.to_s}".downcase
            end
          end
          memo
        end
      end

      # Prints a list of available commands.
      def print_command_list
        puts "#{GoldenBrindle::Const::BANNER}\nAvailable commands are:\n\n"
        commands.each do |name|
          puts " - #{name}\n"
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
          cmd_name = cmd_name.split("::").map{|x| x.capitalize}.join("::")
          constant = constantize("GoldenBrindle::Actions::#{cmd_name}")
          command = constant.new(args)
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
    
end