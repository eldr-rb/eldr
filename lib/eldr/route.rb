# frozen_string_literal: true

module Eldr
  # A single route: a verb + path pattern + handler, with optional before/after
  # filters. Handlers may be a Proc, any object responding to +#call+, or a
  # Rails-style "Controller#action" string.
  class Route
    # @return [Eldr::App, nil] the app instance serving the route
    attr_accessor :app

    # @return [String] the uppercased HTTP verb
    attr_accessor :verb

    # @return [String, Regexp] the route pattern
    attr_accessor :path

    # @return [Symbol, nil] the route's name
    attr_accessor :name

    # @return [Integer] sort key used when several routes match
    attr_accessor :order

    # @return [Proc, Object] the route handler
    attr_accessor :handler

    # @return [Array<Proc>] filters run before the handler
    attr_accessor :before_filters

    # @return [Array<Proc>] filters run after the handler
    attr_accessor :after_filters

    # @param verb [Symbol, String] the HTTP verb (defaults to +:get+)
    # @param path [String, Regexp] the route pattern
    # @param name [Symbol, nil] an optional route name for named filters
    # @param order [Integer] sort key used when several routes match
    # @param handler [Proc, Object, nil] the handler
    # @param to [Proc, Object, nil] alias for +handler+
    def initialize(verb: :get, path: '/', name: nil, order: 0, handler: nil, to: nil)
      @verb = verb.to_s.upcase
      @path = path
      @name = name
      @order = order
      @before_filters = []
      @after_filters = []
      handler ||= to
      @handler = create_handler(handler)
      matcher # validate the path type eagerly so bad routes fail at definition time
    end

    # Converts a "Controller#action" string into a callable proc.
    #
    # @param handler [Object] a Proc, callable, or "Controller#action" string
    # @return [Object] the callable handler
    def create_handler(handler)
      return handler unless handler.is_a? String

      controller, method = handler.split('#')

      proc do |env|
        obj = Object.const_get(controller).new
        obj.send(method.to_sym, env)
      end
    end

    # Serves the route: runs before filters, the handler, then after filters.
    #
    # @param env [Hash] a Rack env
    # @param app [Eldr::App, nil] the app instance, when the handler needs it
    # @return [Array] a Rack response triple
    def call(env, app: nil)
      @app = app

      call_before_filters(env)

      resp = call_handler(env)

      call_after_filters(env)

      resp
    end

    # Runs the route's before filters (and the app's global ones).
    #
    # @param env [Hash] a Rack env
    # @return [void]
    def call_before_filters(env)
      if app
        app.class.before_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        before_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        before_filters.each { |filter| filter.call(env) }
      end
    end

    # Runs the route's after filters (and the app's global ones).
    #
    # @param env [Hash] a Rack env
    # @return [void]
    def call_after_filters(env)
      if app
        app.class.after_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        after_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        after_filters.each { |filter| filter.call(env) }
      end
    end

    # Invokes the handler. Proc handlers attached to an app are exec'd against
    # that app so the route block can use the app's helpers.
    #
    # @param env [Hash] a Rack env
    # @return [Array] a Rack response triple
    def call_handler(env)
      if app and handler.is_a? Proc
        app.instance_exec(env, &handler)
      else
        handler.call(env)
      end
    end

    # @return [Eldr::Matcher] the memoized matcher for this route
    def matcher
      @matcher ||= Matcher.new(path, capture: @capture)
    end

    # @param pattern [String] the path to match
    # @return [MatchData, nil] the match data, or nil when it does not match
    def match(pattern)
      matcher.match(pattern)
    end

    # @param pattern [String] the path to extract params from
    # @return [Hash{String => String, Array<String>}] the extracted params
    def params(pattern)
      matcher.params(pattern)
    end
  end
end
