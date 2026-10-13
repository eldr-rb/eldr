# frozen_string_literal: true

module Eldr
  # A single route: a verb + path pattern + handler, with optional before/after
  # filters. Handlers may be a Proc, any object responding to +#call+, or a
  # Rails-style "Controller#action" string.
  class Route
    attr_accessor :app, :verb, :path, :name, :order, :handler, :before_filters, :after_filters

    def initialize(verb: :get, path: '/', name: nil, order: 0, handler: nil, to: nil)
      @verb = verb.to_s.upcase
      @path = path
      @name = name
      @order = order
      @before_filters = []
      @after_filters = []
      handler ||= to
      @handler = create_handler(handler)
    end

    def create_handler(handler)
      return handler unless handler.is_a? String

      controller, method = handler.split('#')

      proc do |env|
        obj = Object.const_get(controller).new
        obj.send(method.to_sym, env)
      end
    end

    def call(env, app: nil)
      @app = app

      call_before_filters(env)

      resp = call_handler(env)

      call_after_filters(env)

      resp
    end

    def call_before_filters(env)
      if app
        app.class.before_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        before_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        before_filters.each { |filter| filter.call(env) }
      end
    end

    def call_after_filters(env)
      if app
        app.class.after_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        after_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        after_filters.each { |filter| filter.call(env) }
      end
    end

    def call_handler(env)
      if app and handler.is_a? Proc
        app.instance_exec(env, &handler)
      else
        handler.call(env)
      end
    end

    def matcher
      @matcher ||= Matcher.new(path, capture: @capture)
    end

    def match(pattern)
      matcher.match(pattern)
    end

    def params(pattern)
      matcher.handler.params(pattern) || {}
    end
  end
end
