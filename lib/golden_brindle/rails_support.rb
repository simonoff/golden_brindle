module GoldenBrindle
  class RailsSupport
    class << self

      def rails3?
        ::Rails::VERSION::MAJOR == 3
      end

      def rails2?
        ::Rails::VERSION::MAJOR == 2
      end

      def support_rack?
        return true if rails3?
        return true if rails2? && ::Rails::VERSION::MINOR >= 3
        false
      end

      def rails3_application
        return unless rails3? || ::File.exist?('config/application.rb')
        return Object.const_get($1)::Application if \
           ::File.read('config/application.rb') =~ /^module\s+([\w:]+)\s*$/
      rescue NameError
        nil
      end

      def rails_dispatcher
        result = rails3_application
        if result.nil? && defined?(ActionController::Dispatcher)
          result = ActionController::Dispatcher.new
        end
        result || abort("Unable to locate the application dispatcher class")
      end

      def rails_builder(daemonize)
        # this lambda won't run until after forking if preload_app is false
        lambda do ||
          # Load Rails
          begin
            require ::File.expand_path('config/boot')
            require ::File.expand_path('config/environment')
          rescue LoadError => e
            abort "#{$0} must be run inside RAILS_ROOT: #{e.inspect}"
          end

          defined?(::Rails::VERSION::STRING) or
            abort "Rails::VERSION::STRING not defined by config/{boot,environment}"

          old_rails = !support_rack?

          ::Rack::Builder.new do
            map_path = ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
            if old_rails
              if map_path != '/'
                warn "relative URL roots may not work for older Rails"
              end
              warn "LogTailer not available for Rails < 2.3" unless daemonize
              warn "Debugger not available" if $DEBUG
              require 'unicorn/app/old_rails'
              map(map_path) do
                use Unicorn::App::OldRails::Static
                run Unicorn::App::OldRails.new
              end
            else
              use Rails::Rack::LogTailer unless daemonize
              use Rails::Rack::Debugger if $DEBUG
              map(map_path) do
                unless defined?(ActionDispatch::Static)
                  use Rails::Rack::Static
                end
                run ::GoldenBrindle::RailsSupport.rails_dispatcher
              end
            end
          end.to_app
        end
      end

    end
  end
end
