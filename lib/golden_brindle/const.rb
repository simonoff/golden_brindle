module GoldenBrindle
  module Const
    # current version
    VERSION="0.3"
    # main banner
    BANNER = "Usage: golden_brindle <command> [options]"
    # config options names
    CONFIG_KEYS = %w(address host port cwd log_file pid_file environment servers daemon debug config_script workers timeout user group prefix preload listen bundler)
    ANSI_RED    = "\033[0;31m"
    ANSI_RESET  = "\033[0m"
  end
end
