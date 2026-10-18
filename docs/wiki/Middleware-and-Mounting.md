# Middleware and Mounting

`Eldr::App` subclasses are Rack apps. `map` and `use` are delegated to the
app's `Eldr::Builder`, a subclass of `Rack::Builder`, so they behave exactly
like their upstream Rack counterparts.

## `use`

```ruby
class App < Eldr::App
  use Rack::Session::Cookie
end
```

Middleware can also be declared with keyword arguments and blocks, which are
forwarded to the middleware constructor:

```ruby
use My::Middleware, option: true do |config|
  # configuration block
end
```

## `map`

```ruby
class App < Eldr::App
  map '/users' do
    UsersController
  end

  map '/admin' do
    run AdminApp
  end
end
```

`map` builds a `Rack::URLMap`; the default app (set with `run`) is mounted at
`/`.

## `run`

`run` sets the innermost app. `Eldr::App.new` calls it for you with an
instance of the app, which is why `run App` works in a `config.ru`:

```ruby
class App < Eldr::App
  use Rack::Session::Cookie
end

run App
```

If you need the bare app instance (for example to use it as a handler), use
`Eldr::App._new`.

## Ordering: `use` and `map`

Middleware ordering intentionally matches `Rack::Builder`:

- A `use` **before** `map` is applied inside each mapped branch.
- A `use` **after** `map` wraps the generated `URLMap` — i.e. it sees every
  request, but mapped paths are dispatched by the `URLMap` before the default
  app's middleware chain runs.
- A `use` **inside** a `map` block is scoped to that block only.

This is pinned by parity specs in `spec/builder_spec.rb` that build the same
stack with `Eldr::Builder` and `Rack::Builder` and assert identical responses.
Changing it would be a separate, breaking proposal.

## Inheritance

Subclasses inherit the parent's middleware and configuration:

```ruby
class Base < Eldr::App
  use Rack::Session::Cookie
  set :lock, true
end

class App < Base
  # has the session middleware and :lock configuration
end
```

## `warmup`

A `warmup` callback receives the built app and runs whenever it is built,
which is a convenient place to validate configuration without executing code
on every request:

```ruby
class App < Eldr::App
  warmup { |app| app.respond_to?(:call) or raise 'not a rack app' }
end
```
