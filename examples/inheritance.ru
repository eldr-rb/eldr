class SimpleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['eldr.simple_counter'] ||= 0
    env['eldr.simple_counter'] += 1
    @app.call(env)
  end
end

class TestInheritanceApp < Eldr::App
  use SimpleCounterMiddleware
  set :bob, 'what about him?'
end

class InheritedApp < TestInheritanceApp
  get '/', proc { [200, {}, [env['eldr.simple_counter']]]}
end

run InheritedApp
