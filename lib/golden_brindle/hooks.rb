module GoldenBrindle
  module Hooks

    def collect_hooks
      [:after_fork, :after_reload, :before_fork, :before_exec].inject({}) do |memo, sym|
        memo[sym] = send(sym)
        memo
      end
    end

    def after_fork
      lambda do |server, worker|
        defined?(ActiveRecord::Base) and
          ActiveRecord::Base.establish_connection
          # trying to change user and group
		if Gem.available?("amqp")
        	require "amqp"
        	amqp_yaml = YAML.load_file("#{@cwd}/config/amqp.yml")
        	amqp_config = amqp_yaml[ENV['RAILS_ENV'] || 'development']
        	amqp_config.symbolize_keys!

	    	t = Thread.new {AMQP.start(amqp_config)}
	    end
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
    end

    def before_fork
      lambda do |server, worker|
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
    end

    def after_reload
      lambda do
        ::FileUtils.mkdir_p(%w(cache pids sessions sockets).map! { |d| "tmp/#{d}" })
      end
    end

    def before_exec
      lambda do |server|
        ENV["BUNDLE_GEMFILE"] = "#{@cwd}/Gemfile" if @bundler
      end
    end

  end
end
