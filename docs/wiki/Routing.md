# Routing

Routing is powered by [Mustermann](https://github.com/rkh/mustermann), so Eldr
supports everything from Sinatra- to Rails-style paths.

## The verb DSL

```ruby
class App < Eldr::App
  get '/cats' do
    [200, { 'content-type' => 'text/plain' }, ['all the cats']]
  end

  post '/cats' do
    [201, { 'content-type' => 'text/plain' }, ['created']]
  end
end
```

The available verbs are `delete`, `get`, `head`, `options`, `patch`, `post`,
and `put` (see `Eldr::App::HTTP_VERBS`).

## Path patterns and `params`

Path parameters use Mustermann's `:name` syntax. `params` is the query/form
params merged with the current route's path params:

```ruby
get '/cats/:id' do
  id = params['id']          # from the path
  q  = params['q']           # from the query string
  [200, { 'content-type' => 'text/plain' }, ["cat #{id}"]]
end
```

Constraints can be attached with the `capture:` option:

```ruby
get '/cats/:id', capture: { id: /\d+/ } do
  # only matches numeric ids
end
```

## Handler forms

A route may be a block, a proc, anything responding to `#call`, or a
Rails-style `"Controller#action"` string:

```ruby
get '/cats', to: 'cats#index'
```

The string form resolves the constant lazily on each request and calls
`Controller.new.public_send(:index, env)`.

## Ordering

Routes are considered in registration order and then sorted by their `order`
(default `0`) when more than one route matches:

```ruby
get '/cats/:id', order: 2
get '/cats/new', order: 1
```

## Falling through with `throw :pass`

A handler can `throw :pass` to let the next matching route run. This is how
Eldr expresses route conditions without a conditions DSL:

```ruby
get '/' do
  throw :pass if params['agent'] == 'secret'
  [200, {}, ['public']]
end

get '/' do
  [200, {}, ['secret']]
end
```

## Regexp paths

A `Regexp` path is also accepted. It is anchored to the whole path, so
`/cats/.*` matches `/cats/bob` but not `/dogs/bob`:

```ruby
get %r{/cats/.*} do
  [200, {}, ['a cat']]
end
```

Regexp paths are matched, but extracting named captures through `params` is
only supported for Mustermann (String) patterns.

## Path type validation

Only `String` and `Regexp` paths are accepted. Anything else raises an
`ArgumentError` at route-definition time:

```ruby
get :cats # => ArgumentError: unsupported path type: Symbol (expected String or Regexp)
```
