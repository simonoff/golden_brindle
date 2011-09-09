module GoldenBrindle
  class Base
    include Validations
    attr_reader :valid, :done_validating, :original_args

    # Called by the subclass to setup the command and parse the argv arguments.
    # The call is destructive on argv since it uses the OptionParser#parse! function.
    def initialize(argv)
      @opt = ::OptionParser.new
      @opt.banner = GoldenBrindle::Const::BANNER
      @valid = true
      # this is retarded, but it has to be done this way because -h and -v exit
      @done_validating = false
      @original_args = argv.dup
      configure
      # I need to add my own -h definition to prevent the -h by default from exiting.
      @opt.on_tail("-h", "--help", "Show this message") do
        @done_validating = true
        puts @opt
      end
      # I need to add my own -v definition to prevent the -v from exiting by default as well.
      @opt.on_tail("--version", "Show version") do
        @done_validating = true
        if VERSION
          puts "Version #{GoldenBrindle::Const::VERSION}"
        end
      end
      @opt.parse! argv
    end

    # Called by the implemented command to set the options for that command.
    # Every option has a short and long version, a description, a variable to
    # set, and a default value.  No exceptions.
    def options(opts)
      # process the given options array
      opts.each do |short, long, help, variable, default|
        self.instance_variable_set(variable, default)
        @opt.on(short, long, help) do |arg|
          self.instance_variable_set(variable, arg)
        end
      end
    end

    def configure
      options []
    end

    def config_keys
      GoldenBrindle::Const::CONFIG_KEYS
    end

    def load_config
      settings = {}
      begin
        settings = ::YAML.load_file(@config_file)
      ensure
        STDERR.puts "** Loading settings from #{@config_file} (they override command line)." unless @daemon || settings[:daemon]
      end

      # Config file settings will override command line settings
      settings.each do |key, value|
        key = key.to_s
        if config_keys.include?(key)
          key = 'address' if key == 'host'
          self.instance_variable_set("@#{key}", value)
        else
          failure "Unknown configuration setting: #{key}"
          @valid = false
        end
      end
    end

    # Returns true/false depending on whether the command is configured properly.
    def validate
      @valid
    end

    # Returns a help message.  Defaults to OptionParser#help which should be good.
    def help
      @opt.help
    end

    # Runs the command doing it's job.  You should implement this otherwise it will
    # throw a NotImplementedError as a reminder.
    def run
      raise NotImplementedError
    end
  end
end