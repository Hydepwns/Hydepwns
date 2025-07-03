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
  '';

  # Set environment variables
  ERL_AFLAGS = "-kernel shell_history enabled";
  ERL_LIBS = "${erlang}/lib/erlang/lib";
  
  # PostgreSQL setup
  PGDATA = "./.postgres";
  PGHOST = "localhost";
  PGPORT = "5432";
  PGUSER = "postgres";
  PGPASSWORD = "postgres";
}
