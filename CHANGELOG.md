# Changelog

All notable changes to this project are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-11

A maintenance release that brings the framework forward to a modern Ruby /
Rack toolchain after ~11 years without changes. The public DSL is unchanged;
these are dependency-floor and toolchain breaking changes.

### Changed (breaking)
- **Ruby**: require Ruby >= 3.1 (was ~> 2.0). The previous release no longer
  installs on any supported Ruby.
- **Rack**: depend on `rack ~> 3.0` (was ~> 1.5). Response bodies must be
  enumerables of Strings and headers must be lowercase; this affects custom
  response objects used with eldr. `Eldr::Cascade::NOTFOUND` now uses a
  lowercase `content-type` header.
- **mustermann**: depend on `mustermann ~> 1.1` (was pinned to 0.4.0).
- **fast_blank**: depend on `fast_blank ~> 1.0` (was pinned to 0.0.2).
- `Eldr::Builder#generate_map` now uses `Rack::URLMap` explicitly (previously
  relied on a bare `URLMap` constant that did not resolve correctly).
- `Eldr::Route#params` no longer performs a dead `params ||= {}` assignment;
  it returns `matcher.handler.params(pattern) || {}`.
- `require 'eldr'` now eagerly loads `Eldr::Cascade` and `Eldr::VERSION` in
  addition to `Eldr::App`.

### Fixed
- Ruby 3.0 keyword-argument separation no longer silently breaks the route
  DSL. `Eldr::App.add` and the verb DSL now splat route attributes into
  `Route.new` instead of passing a positional Hash (which Ruby 3 rejects).
- `Eldr::Builder#generate_map` raised `NameError: uninitialized constant
  Eldr::Builder::URLMap`; now resolves `Rack::URLMap`.
- `Eldr::Configuration` now defines `respond_to_missing?` alongside
  `method_missing`.
- Example apps: integer response bodies are now stringified (`[200, {}, [n]]`
  -> `[200, {}, [n.to_s]]`), `File.exists?` -> `File.exist?`, and the
  `inheritance.ru` example references the middleware class it actually
  defines.

### Added
- `Eldr::Cascade` example (`examples/cascade.ru`) and end-to-end spec.
- New specs covering `Eldr::Cascade`, `Eldr::Builder` URLMap mounting,
  `use`-after-`map` composition and `warmup`, `Eldr::Configuration`
  setters / `respond_to?` / `#merge!`, `Eldr::Matcher` Regexp paths, the
  `capture` option and unsupported path types, `Eldr::Recognizer` verb
  downcasing and blank-PATH_INFO normalization, and `Eldr::Route` ordering
  and unknown-constant behavior — plus named `after` filter attachment and
  re-raising of errors that do not respond to `#call` in `Eldr::App`.
- Shared spec helper `spec/support/example_app.rb` that loads `.ru` apps
  across Rack 2 / Rack 3 (the return shape of `Rack::Builder.parse_file`
  changed in Rack 3).
- Opt-in coverage via `COVERAGE=1 bundle exec rspec` using SimpleCov,
  kept at 100% of both line and branch coverage (the gate fails the run
  on any regression).
- GitHub Actions CI workflow (`.github/workflows/ci.yml`).
- This `CHANGELOG.md`.

### Removed
- Dropped the `coveralls` dependency (unmaintained, Travis-only) and the
  `COVERALLS_REPO_TOKEN` branch from `spec/spec_helper.rb`.
- Dropped the `bundler ~> 1.7` and `rubyforge_project` gemspec metadata.
- Removed `.travis.yml` (Travis CI is no longer operational for OSS).

## [0.0.4] - 2015-03-30

Last historical release. See git history for details.