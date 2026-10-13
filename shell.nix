# Development environment for Eldr (Ruby >= 3.1, per eldr.gemspec).
#
#   nix-shell          # enter the environment
#   bundle install     # gems are installed to ./.bundle
#   bundle exec rspec
#   bundle exec rubocop
#   bundle exec rackup examples/... # boot a sample app

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    # Ships with bundler 2.6.9, matching the BUNDLED WITH in Gemfile.lock.
    pkgs.ruby_3_4

    # mkShell's stdenv provides gcc/make for gems with native extensions
    # (fast_blank, parser, prism). These are the headers gems commonly
    # link against if more get added to the Gemfile later.
    pkgs.pkg-config
    pkgs.openssl
    pkgs.zlib

    # Utilities
    pkgs.git    # the gemspec builds its file list with `git ls-files`
    pkgs.bundix # useful if you later want a pinned gemset.nix
  ];

  # Bundler must not try to write gems into the read-only Nix store;
  # keep them in the project directory instead.
  BUNDLE_PATH = ".bundle";

  shellHook = ''
    echo "Eldr dev shell: $(ruby --version), bundler $(bundle --version | cut -d' ' -f3)"
  '';
}