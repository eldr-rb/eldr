# Error Handling

## Callable errors

Raise any `StandardError` whose class responds to `#call` and Eldr will use
the exception itself as the error handler. This is handy in before filters,
where you want to halt the route:

```ruby
class ErrorResponse < StandardError
  def call(env)
    [500, { 'content-type' => 'text/plain' }, [message]]
  end
end

class App < Eldr::App
  get '/' do
    raise ErrorResponse, 'Bad Data'
  end
end
```

`Eldr::App#call!` rescues `StandardError`, and if the exception responds to
`#call` it serves the result. Errors that do **not** respond to `#call` are
re-raised.

## What Eldr does not catch

Eldr does not install a global error handler. In production, wrap your app in
resilience middleware such as
[rack-robustness](https://github.com/blambeau/rack-robustness):

```ruby
class App < Eldr::App
  use Rack::Robustness do |g|
    g.on(ArgumentError) { |_ex| 400 }
    g.on(SecurityError) { |_ex| 403 }
    g.content_type 'text/plain'
    g.body { |ex| ex.message }
    g.ensure(true) { |ex| env['rack.errors'].write(ex.message) }
  end
end
```

## `throw :pass`

To skip a route without raising, `throw :pass`; the next matching route is
tried:

```ruby
get '/' do
  throw :pass if params['agent'] == 'secret'
  # respond here
end

get '/' do
  # only reached when the first route passed
end
```

If every matching route passes and none returns, request handling falls
through to whatever middleware / `404` behavior surrounds the app.

## `Eldr::Recognizer::NotFound`

`Eldr::Recognizer#call` raises `Eldr::Recognizer::NotFound` when no route
matches. The class also responds to `#call`, so it can be used directly as an
error/`404` handler.
