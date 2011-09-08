module GoldenBrindle
  module Const
    # current version
    VERSION="0.2"
    # main banner
    BANNER = "Usage: golden_brindle <command> [options]"
    # config options names
    CONFIG_KEYS = %w(address host port cwd log_file pid_file environment servers daemon debug config_script workers timeout user group prefix preload listen bundler)
  end
end
