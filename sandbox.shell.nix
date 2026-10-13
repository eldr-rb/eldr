{ pkgs ? import <nixpkgs> {} }:

let
  # Fetch agent-sandbox.nix from GitHub
  agentSandboxSrc = builtins.fetchTarball {
    url = "https://github.com/archie-judd/agent-sandbox.nix/archive/main.tar.gz";
  };
  agentSandbox = import agentSandboxSrc { inherit pkgs; };

  # Package wrapper for pi executable
  piPkg = pkgs.writeShellScriptBin "pi" ''
    if [ -f "$HOME/.npm-global/bin/pi" ]; then
      exec "$HOME/.npm-global/bin/pi" "$@"
    else
      exec pi "$@"
    fi
  '';

  lib64Dir = if builtins.pathExists "/lib64" then [ "/lib64" ] else [];

  nixLdDirs = builtins.filter builtins.pathExists [
    "/run/current-system"
    "/run/nix-ld"
    "/etc/nix-ld-system-path"
  ];

  gitConfigFiles = builtins.filter builtins.pathExists [
    (builtins.getEnv "HOME" + "/.gitconfig")
    (builtins.getEnv "HOME" + "/.config/git/config")
    # The sandbox only follows symlinks to declared paths, and ~/.gitconfig is
    # often a symlink into a dotfiles repo (e.g. ~/.dotfiles/git/.gitconfig).
    # Declare the target so the git identity is visible inside the sandbox.
    (builtins.getEnv "HOME" + "/.dotfiles/git/.gitconfig")
  ];

  # Ruby dev environment, mirroring shell.nix. ruby_3_4 ships with bundler
  # 2.6.9, matching Gemfile.lock. gcc/gnumake/pkg-config let the agent build
  # gems with native extensions (fast_blank, parser, prism). nodejs is needed
  # because pi itself is a Node CLI. stdenv.cc.cc.lib stays in the closure so
  # NIX_LD can find libstdc++.
  appPackages = [
    pkgs.ruby_3_4
    pkgs.nodejs
    pkgs.fish
    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.openssl
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
    pkgs.bundix
  ];

  ldSoPath =
    if builtins.pathExists "${pkgs.glibc}/lib64/ld-linux-x86-64.so.2"
    then "${pkgs.glibc}/lib64/ld-linux-x86-64.so.2"
    else "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";

  ldLibPath = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.openssl
    pkgs.glibc
  ];

  # Sandbox arguments shared by pi-sandboxed and fish-sandboxed.
  sandboxArgs = {
    # The launch directory (the project) is read-write by default, so the
    # agent can edit code and install gems to ./.bundle via BUNDLE_PATH.
    rwDirs = [
      "$HOME/.pi"
    ];
    roDirs = [
      "$HOME/.npm-global"
    ] ++ lib64Dir ++ nixLdDirs;
    roFiles = gitConfigFiles;
    # Host-local services the agent may reach: 11434 is ollama.
    allowedHostPorts = [ 11434 ];
    # Servers the agent boots are reachable from the host browser.
    # 9292 is rackup's default port (see examples/*.ru).
    publishedPorts = [ 9292 ];
    env = {
      PI_CONFIG_DIR = "$HOME/.pi";
      BUNDLE_PATH = ".bundle";
      LD_LIBRARY_PATH = ldLibPath;
      NIX_LD = ldSoPath;
      NIX_LD_LIBRARY_PATH = ldLibPath;
    };
  };
in
rec {
  # Create sandboxed pi binary
  pi-sandboxed = agentSandbox.mkSandbox (sandboxArgs // {
    pkg = piPkg;
    binName = "pi";
    outName = "pi-sandboxed";
    allowedPackages = agentSandbox.commonTools ++ appPackages;
  });

  # Create sandboxed fish shell for manual permission testing
  fish-sandboxed = agentSandbox.mkSandbox (sandboxArgs // {
    pkg = pkgs.fish;
    binName = "fish";
    outName = "fish-sandboxed";
    allowedPackages = agentSandbox.commonTools ++ [ piPkg ] ++ appPackages;
  });

  shell = pkgs.mkShell {
    buildInputs = [
      pi-sandboxed
      fish-sandboxed
      pkgs.fish
    ] ++ appPackages;

    BUNDLE_PATH = ".bundle";
    LD_LIBRARY_PATH = ldLibPath;

    shellHook = ''
      alias pi="${pi-sandboxed}/bin/pi-sandboxed"
      alias fish-sandboxed="${fish-sandboxed}/bin/fish-sandboxed"
    '';
  };
}.shell