# FAQ

## Why not Sinatra?

Sinatra is a great framework, and Eldr borrows its routing style (via
Mustermann). Eldr is deliberately smaller and less magical: there is no
implicit `Sinatra::Base` configuration DSL, no automatic view lookup, and no
large helper surface. You get a Rack app and a router, and you compose the rest
with Rack middleware and plain Ruby. If you want batteries included, use
Sinatra or Rails; if you want to see exactly what is happening, use Eldr.

## Is Eldr Rack 3 ready?

Yes. Eldr depends on `rack ~> 3.0`. That means response bodies must be
enumerables of Strings and response headers must be lowercase, per the Rack 3
SPEC. See [Migrating to 0.1](Migrating-to-0.1).

## How do I test an Eldr app?

Use `rack-test`, the same as any Rack app:

```ruby
RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  YourEldrApp.new
end
```

Or build a session explicitly:

```ruby
let(:rt) { Rack::Test::Session.new(YourEldrApp.new) }
response = rt.get '/'
expect(response.status).to eq(200)
```

See the `spec/` directory of the repo for runnable RSpec examples, including a
shared helper that runs every example app through `Rack::Lint`.

## How do I mount apps / use `map` and `use`?

`map` and `use` are delegated to the app's `Eldr::Builder` (a `Rack::Builder`
subclass), so they behave the same as upstream Rack. See
[Middleware and Mounting](Middleware-and-Mounting).

## What's the `App.new` returns-a-Builder thing?

`Eldr::App.new` returns the app's `Eldr::Builder`, wired up with an instance of
the app via `builder.run`. That is what makes `run ExampleApp` work in a
`config.ru`: Rack receives something that responds to `#call`. When you need
the bare app instance — for example to call it directly or to reuse it as a
handler — use `Eldr::App._new` (used internally by `App#call` and the specs).

## How do I add my app to the wiki?

Open a PR adding a line to [Projects using Eldr](Projects-using-Eldr).
