# Migrating to 0.1

`0.1.0` is a maintenance release that brings Eldr forward to a modern Ruby and
Rack toolchain after a long gap. The public DSL is unchanged; the breaking
changes are dependency floors and Rack 3 response requirements.

## Ruby >= 3.1

Eldr now requires Ruby >= 3.1 (previously `~> 2.0`). The previous release no
longer installs on any supported Ruby.

## Rack >= 3.0

Eldr now depends on `rack ~> 3.0` (previously `~> 1.5`). Under the Rack 3 SPEC:

- Response bodies must be **enumerables of Strings** — not a bare String.
  `[200, {}, 'hello']` is invalid; use `[200, {}, ['hello']]`.
- Response headers must be **lowercase**. `'Content-Type'` becomes
  `'content-type'`.
- `Eldr::Cascade::NOTFOUND` uses a lowercase `content-type` header.

If you have custom response objects, make sure their `#to_a` returns Rack 3
shaped bodies and headers.

## `mustermann ~> 1.1`

Previously pinned to `0.4.0`. Routing now uses Mustermann 1.1.

## `fast_blank ~> 1.0`

Previously pinned to `0.0.2`.

## Builder changes

- `Eldr::Builder#generate_map` now uses `Rack::URLMap` explicitly. Previously
  it relied on a bare `URLMap` constant that did not resolve.
- `Eldr::Route#params` no longer performs a dead `params ||= {}` assignment.

## `require 'eldr'`

`require 'eldr'` now eagerly loads `Eldr::Cascade` and `Eldr::VERSION` in
addition to `Eldr::App`.

## Fixes

- Ruby 3 keyword-argument separation no longer breaks the route DSL:
  `Eldr::App.add` and the verb DSL splat route attributes into `Route.new`.
- `Eldr::Builder#generate_map` no longer raises
  `NameError: uninitialized constant Eldr::Builder::URLMap`.
- `Eldr::Configuration` defines `respond_to_missing?` alongside
  `method_missing`.
- `Eldr::Matcher` now raises `ArgumentError` for paths that are neither a
  `String` nor a `Regexp` (see [Routing](Routing)).
- Example apps are Rack 3 valid (`File.exists?` -> `File.exist?`, string
  bodies, etc.).

See `CHANGELOG.md` for the full list.
