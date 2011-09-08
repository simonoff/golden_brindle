module GoldenBrindle
  module Validations

    ANSI_RED    = "\033[0;31m"
    ANSI_RESET  = "\033[0m"

    # Validates the given expression is true and prints the message if not, exiting.
    def valid?(exp, message)
      if !exp
        failure message
        @valid = false
      end
    end

    # Validates that a file exists and if not displays the message
    def valid_exists?(file, message)
      valid?(File.exist?(file), message)
    end

    # Validates that the file is a file and not a directory or something else.
    def valid_file?(file, message)
      valid?(::File.file?(file), message)
    end

    # Validates that the given directory exists
    def valid_dir?(file, message)
      valid?(::File.directory?(file), message)
    end

    def can_change_user?
      valid?(::Process.euid.zero?, "if you want to change workers UID/GID you must run programm from root")
    end

    def valid_user?(user)
      return unless can_change_user?
      begin
        ::Etc.getpwnam(user)
      rescue
        failure "User does not exist: #{user}"
        @valid = false
      end
    end

    def valid_group?(group)
      begin
        ::Etc.getgrnam(group)
      rescue
        failure "Group does not exist: #{group}"
        @valid = false
      end
    end

    # Just a simple method to display failure until something better is developed.
    def failure(message)
      STDERR.puts "#{ANSI_RED}!!! * #{message}#{ANSI_RESET}"
    end

  end
end