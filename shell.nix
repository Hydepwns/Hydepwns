{ pkgs ? import <nixpkgs> {} }:

let
  # Use Erlang 26 and Elixir 1.17 from the correct package set
  beamPkgs = pkgs.beam26Packages;
  
  # Elixir version from .tool-versions
  elixir = beamPkgs.elixir_1_17;
  
  # Erlang version from .tool-versions
  erlang = beamPkgs.erlang;
  
  # Node.js for asset management
  nodejs = pkgs.nodejs_20;
  
  # Additional tools
  inotify-tools = pkgs.inotify-tools;
  
  # Build tools for NIF compilation
  cmake = pkgs.cmake;
  gcc = pkgs.gcc;
  make = pkgs.gnumake;
  openssl = pkgs.openssl;
  
  # Chrome and ChromeDriver for Wallaby testing
  chrome = pkgs.google-chrome;
  chromedriver = pkgs.chromedriver;
  xvfb = pkgs.xorg.xvfb;
  
in pkgs.mkShell {
  buildInputs = [
    # Elixir and Erlang
    elixir
    erlang
    
    # Node.js and npm
    nodejs
    pkgs.nodePackages.npm
    
    # Database
    pkgs.postgresql_15
    
    # Development tools
    inotify-tools
    pkgs.git
    beamPkgs.rebar3
    
    # Build tools
    cmake
    gcc
    make
    openssl
    
    # Browser testing
    chrome
    chromedriver
    xvfb

    # Dart Sass for NixOS compatibility
    pkgs.dart-sass
    
    # Optional: Additional useful tools
    pkgs.curl
    pkgs.wget
    pkgs.tree
    pkgs.just
  ];

  shellHook = ''
    echo "🐘 Elixir development environment loaded!"
    echo "📦 Available tools:"
    echo "   - Elixir: $(elixir --version | head -n1)"
    echo "   - Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
    echo "   - Node.js: $(node --version)"
    echo "   - npm: $(npm --version)"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Run: mix deps.get"
    echo "   2. Run: cd assets && npm install"
    echo "   3. Run: mix setup"
    echo "   4. Run: mix phx.server"
    echo ""
    echo "🧪 Testing helpers:"
    echo "   - Run: mix test --max-failures=5"
    echo "   - Run: mix test test/hydepwns_liveview_web/features/"
    echo "   - Run: mix test --only integration"
    echo "   - Run: ./scripts/test_browser.sh (for browser tests)"
    echo ""
    echo "🔧 LiveView testing tips:"
    echo "   - Ensure PostgreSQL is running: pg_ctl start -D .postgres"
    echo "   - Use --max-failures=N to limit test failures"
    echo "   - Check tmp/test_error_summary.txt for detailed error reports"
    echo ""
    echo "🌐 Browser testing:"
    echo "   - Chrome: $CHROME_BIN"
    echo "   - Chromedriver: $CHROMEDRIVER_PATH"
    echo "   - Display: $DISPLAY"
    echo ""
  '';

  # Set environment variables
  ERL_AFLAGS = "-kernel shell_history enabled";
  ERL_LIBS = "${erlang}/lib/erlang/lib";
  
  # OpenSSL environment variables for NIF compilation
  OPENSSL_ROOT_DIR = "${openssl}";
  OPENSSL_INCLUDE_DIR = "${openssl}/include";
  OPENSSL_LIBRARIES = "${openssl}/lib";
  OPENSSL_CRYPTO_LIBRARY = "${openssl}/lib/libcrypto.so";
  OPENSSL_SSL_LIBRARY = "${openssl}/lib/libssl.so";
  
  # PostgreSQL setup
  PGDATA = "./.postgres";
  PGHOST = "localhost";
  PGPORT = "5432";
  PGUSER = "postgres";
  PGPASSWORD = "postgres";
  
  # LiveView testing environment
  MIX_ENV = "test";
  PHX_SERVER = "true";
  SQL_SANDBOX = "true";
  
  # Wallaby/Chrome testing environment
  CHROME_HEADLESS = "true";
  CHROME_NO_SANDBOX = "true";
  CHROME_DISABLE_DEV_SHM = "true";
  CHROMEDRIVER_PATH = "${chromedriver}/bin/chromedriver";
  CHROME_BIN = "${chrome}/bin/google-chrome";
  DISPLAY = ":99";
}
