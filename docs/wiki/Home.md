# Eldr

Eldr is a minimal Ruby framework that doesn't hide the Rack. It aims to be
lightweight, simple, modular, and above all, clear — a Ruby framework without
all the magic.

Eldr apps *are* Rack apps:

```ruby
class App < Eldr::App
  get '/posts' do
    Rack::Response.new 'posts', 200
  end
end

run App
```

Because they are Rack apps you boot them like any other Rack app, and you can
compose them with `map` and `use` exactly as you would with `Rack::Builder`.

## Why Eldr?

- **Small** — the core is under 500 lines; you can learn it in an afternoon.
- **Flexible** — build apps how you want, with what you want.
- **Modular** — views, response helpers, sessions, etc. are independent gems.
- **No magic** — build apps you actually understand.
- **Fast** — among the fastest Ruby microframeworks, and getting faster.
- **Powerful router** — powered by [Mustermann](https://github.com/rkh/mustermann),
  so you can use everything from Sinatra- to Rails-style routing.

## Documentation

- [README](https://github.com/eldr-rb/eldr#readme) — the canonical quickstart.
- [API documentation](https://rubydoc.info/gems/eldr) — generated with YARD.
- [Examples](https://github.com/eldr-rb/eldr/tree/master/examples) — full,
  runnable versions of the quickstart examples.

## Installation

Eldr targets Ruby >= 3.1 and Rack >= 3.0:

```ruby
gem 'eldr'
# or, from master:
# gem 'eldr', github: 'eldr-rb/eldr'
```

## Getting help

- [Issues](https://github.com/eldr-rb/eldr/issues) for bug reports and feature
  requests.
- [@k_2052](https://twitter.com/k_2052) for quick questions.
- [The Mailing List](https://groups.google.com/forum/#!forum/eldr-ruby).
- [BuildYourOwnSinatra.com](http://buildyourownsinatra.com), a companion book
  on building Eldr.
