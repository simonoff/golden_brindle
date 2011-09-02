
module Brindle
  
  class Start < GemPlugin::Plugin "/commands"
    include GoldenBrindle::Command::Base
    
    def configure
      options [
        ["-e", "--environment ENV", "Rails environment to run as", :@environment, ENV['RAILS_ENV'] || "development"],
        ["-b", "--bundler", "Use bundler to start unicorn instances", :@bundler, false],
        ["-d", "--daemonize", "Run daemonized in the background", :@daemon, false],
        ['', "--preload", "Preload application", :@preload, false],
        ['-p', '--port PORT', "Which port to bind to (if set numbers of servers - start port number)", :@port, Unicorn::Const::DEFAULT_PORT],
        ['-a', '--address ADDR', "Address to bind to", :@address, Unicorn::Const::DEFAULT_HOST],
        ['-o', '--listen {HOST:PORT|PATH}',"listen on HOST:PORT or PATH, separated by comma (default: #{Unicorn::Const::DEFAULT_LISTEN})", :@listen, Unicorn::Const::DEFAULT_LISTEN],
        ['-l', '--log FILE', "Where to write log messages", :@log_file, "log/unicorn.log"],
        ['-P', '--pid FILE', "Where to write the PID", :@pid_file, "tmp/pids/unicorn.pid"],
        ['-n', '--num-workers INT', "Number of Unicorn workers", :@workers, 4],
        ['-N', '--num-servers INT', "Number of Unicorn listen records", :@servers, 1],
        ['-t', '--timeout INT', "Time to wait (in seconds) before killing a stalled thread", :@timeout, 60],
        ['-c', '--chdir PATH', "Change to dir before starting (will be expanded)", :@cwd, Dir.pwd],
        ['-D', '--debug', "Enable debugging mode", :@debug, false],
        ['-C', '--config PATH', "Use a mongrel based config file", :@config_file, nil],
        ['-S', '--script PATH', "Load the Unicorn-specific config file", :@config_script, nil],
        ['', '--user USER', "User to run as", :@user, nil],
        ['', '--group GROUP', "Group to run as", :@group, nil],
        ['', '--prefix PATH', "URL prefix for Rails app", :@prefix, nil]
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
      
      if @config_script
        valid_exists?(@config_script, "Unicorn-specific config file not there: #@config_script")
        return false unless @valid
      end
      
      if @bundler
        valid_exists?('Gemfile', "Cannot use Bundler - no Gemfile in your application root dir")
        return false unless @valid
      end
      
      @cwd = File.expand_path(@cwd)
      valid_dir? @cwd, "Invalid path to change to during daemon mode: #{@cwd}"
      valid?(@prefix[0] == ?/ && @prefix[-1] != ?/, "Prefix must begin with / and not end in /") if @prefix
      valid_dir? File.dirname(File.join(@cwd,@log_file)), "Path to log file not valid: #{@log_file}"
      valid_dir? File.dirname(File.join(@cwd,@pid_file)), "Path to pid file not valid: #{@pid_file}"
      valid_user? @user if @user
      valid_group? @group if @group
      @valid
    end
    
    def run
      # Change there to start, then we'll have to come back after daemonize
      Dir.chdir(@cwd)
      if @bundler
        puts "Using Bundler"
        puts "reexec via bundle exec"
        cmd_for_exec = "bundle exec #{@opt.program_name}"
        @original_args.each_slice(2) do |arg_key,value|
          cmd_for_exec << " #{arg_key} #{value}" if arg_key != "-b"
        end
        exec(cmd_for_exec)
      end
      options = { 
        :listeners          => [],
        :pid                => @pid_file,
        :config_file        => @config_script,
        :worker_processes   => @workers.to_i,
        :working_directory  => @cwd,
        :timeout            => @timeout.to_i
      }
      # set user via Unicorn options. If we don't set group - then use only user
      options[:user] = @user unless @user.nil? 
      options[:stderr_path] = options[:stdout_path] = @log_file if @daemon
      # ensure Rails standard tmp paths exist
      options[:after_reload] = lambda do
        FileUtils.mkdir_p(%w(cache pids sessions sockets).map! { |d| "tmp/#{d}" })
      end
        
      options[:preload_app] = @preload
      # do base steps for Rails
      options[:after_fork] = lambda do |server, worker|
        defined?(ActiveRecord::Base) and
          ActiveRecord::Base.establish_connection
          # trying to change user and group
        begin
          # check if something not set in config or cli
          unless @user.nil? || @group.nil?
            uid, gid = Process.euid, Process.egid
            user, group = @user, @group
            target_uid = Etc.getpwnam(user).uid
            target_gid = Etc.getgrnam(group).gid
            worker.tmp.chown(target_uid, target_gid)
            if uid != target_uid || gid != target_gid
              Process.initgroups(user, target_gid)
              Process::GID.change_privilege(target_gid)
              Process::UID.change_privilege(target_uid)
            end
          end
         rescue => e
           if ENV['RAILS_ENV'] == 'development'
             STDERR.puts "couldn't change user, oh well"
           else
             raise e
           end
         end
      end   
      options[:before_fork] = lambda do |server, worker| 
        defined?(ActiveRecord::Base) and
          ActiveRecord::Base.connection.disconnect!
        # http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
        if GC.respond_to?(:copy_on_write_friendly=)
            GC.copy_on_write_friendly = true
        end
        old_pid = "#{server.config[:pid]}.oldbin"
        if File.exists?(old_pid) && server.pid != old_pid
          begin
            Process.kill("QUIT", File.read(old_pid).to_i)
          rescue Errno::ENOENT, Errno::ESRCH
          end
        end
      end
      ENV['RAILS_ENV'] = @environment
      ENV['RAILS_RELATIVE_URL_ROOT'] = @prefix
      unless @port.nil?
        start_port = end_port = nil
        start_port ||=  @port.to_i
        end_port ||=  start_port + @servers.to_i - 1
        (start_port..end_port).each do |port|
          options[:listeners] << "#{@address}:#{port}"
        end
      end
      unless @listen.nil? || @listen.empty?
        @listen.split(',').each do |listen|
          listen = File.join(@cwd,listen) if listen[0..0] != "/" && !listen.match(/\w+\:\w+/)
          options[:listeners] << "#{listen}"
        end
      end
      app = RailsSupport.rails_builder(@daemon)
      if @daemon
        Unicorn::Launcher.daemonize!(options)
      end
      puts "start Unicorn v#{Unicorn::Const::UNICORN_VERSION}..."
      if Unicorn.respond_to?(:run)
        Unicorn.run(app, options)
      else
        Unicorn::HttpServer.new(app, options).start.join
      end
    end
    
    
  end
end
