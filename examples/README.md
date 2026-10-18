# Running these examples

All of these are runnable Rack apps. Boot one with `rackup`:

```sh
$ bundle exec rackup examples/hello_world.ru
```

| Example | What it shows |
|---|---|
| [`hello_world.ru`](hello_world.ru) | The smallest possible Eldr app. |
| [`app.ru`](app.ru) | A slightly larger app with several routes. |
| [`builder.ru`](builder.ru) | Using `Rack::Builder`/`Eldr::Builder` features (`use`, `map`, `run`). |
| [`multiple_apps.ru`](multiple_apps.ru) | Mounting several Eldr apps in one process. |
| [`inheritance.ru`](inheritance.ru) | Inheriting middleware and configuration from a base app. |
| [`errors.ru`](errors.ru) | Callable error classes and error handling. |
| [`custom_response.ru`](custom_response.ru) | Returning a custom response object that responds to `#to_a`. |
| [`rails_style_routing.ru`](rails_style_routing.ru) | Rails-style `get '/cats', to: 'cats#index'` routing. |
| [`rendering_templates.ru`](rendering_templates.ru) | Rendering templates with Tilt/Slim (see [`views/`](views)). |
| [`action_objects.ru`](action_objects.ru) | Using action objects as route handlers. |
| [`cascade.ru`](cascade.ru) | Chaining apps with `Eldr::Cascade` so unmatched routes fall through. |

Each example is also exercised by a spec under `spec/examples/`, wrapped in
`Rack::Lint` so it stays Rack 3 compliant.
