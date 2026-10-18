# Cascade

`Eldr::Cascade` is a `Rack::Cascade` replacement that chains apps together and
returns the first response whose status is not "caught". By default the caught
statuses are `404` and `405`, so a request falls through to the next app when
the previous one could not find (or could not route) it.

## Usage

```ruby
require 'eldr'

class Primary < Eldr::App
  get '/' do
    [200, { 'content-type' => 'text/plain' }, ['primary']]
  end
end

class Fallback < Eldr::App
  get '/other' do
    [200, { 'content-type' => 'text/plain' }, ['fallback']]
  end
end

run Eldr::Cascade.new([Primary, Fallback])
```

`require 'eldr'` already loads `Eldr::Cascade`, so no extra require is needed.

## Customizing the caught statuses

Pass an array (or a single status) as the second argument:

```ruby
run Eldr::Cascade.new([Primary, Fallback], [403, 404, 405])
```

## API

- `Cascade.new(apps, catch = [404, 405])`
- `#add(app)` / `#<<` — append an app to the chain
- `#include?(app)` — membership test
- `#apps` — the chained apps, in order
- `#call(env)` — try each app until one returns an uncatched status

`Eldr::Cascade::NOTFOUND` is the response returned when every app is caught.

## Runnable example

`examples/cascade.ru` demonstrates the chain. Run it with:

```sh
bundle exec rackup examples/cascade.ru
```

Then `GET /` returns `200 "Hello from the cascade!"` and `GET /missing`
returns `404` from the first app.
