# Shared helpers for the example .ru specs.
#
# In Rack 3.x, `Rack::Builder.parse_file` returns the app directly,
# whereas in Rack 1.x/2.x it returned `[app, env]`. This helper papers
# over the difference so the example specs are Rack-version agnostic.
module ExampleAppHelper
  def load_example_app(relative_path)
    path = File.expand_path(relative_path, File.dirname(__FILE__) + '/..')
    # Wrap in Rack::Lint so the example specs enforce Rack 3 spec
    # conformance (lowercase headers, enumerable string bodies, etc.).
    Rack::Lint.new(load_raw_example_app(relative_path))
  end

  # Returns the example app without the Rack::Lint wrapper. Use this when a
  # spec needs to introspect the app object itself rather than call it.
  def load_raw_example_app(relative_path)
    path = File.expand_path(relative_path, File.dirname(__FILE__) + '/..')
    app = Rack::Builder.parse_file(path)
    app = app.first if app.is_a?(Array)
    app
  end
end

RSpec.configure do |config|
  config.include ExampleAppHelper, type: :request
  # Make it available to the example specs that do not declare a type.
  config.include ExampleAppHelper, file_path: %r{spec/examples/}
end