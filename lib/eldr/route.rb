module Eldr
  class Route
    attr_accessor :name, :app, :capture, :order, :options, :handler
    attr_accessor :before_filters, :after_filters, :to

    def initialize(verb: :get, path: '/', name: nil, options: {}, handler: nil, app: nil)
      @path, @verb = path, verb.to_s.upcase

      @app            = app
      @capture        = {}
      @before_filters = []
      @after_filters  = []
      @name           = name

      merge_with_options!(options)

      @handler   = handler
      @handler ||= @to
    end

    def call(env, app: nil)
      # TODO Investigate
      # maybe if we passed this around between methods it would be more perfomant
      # than setting the accessor?
      @app = app

      app.class.before_filters[:all].each { |filter| app.instance_exec(env, &filter) } if app
      @before_filters.each                { |filter| app.instance_exec(env, &filter) }

      resp = response(env)

      app.class.after_filters[:all].each { |filter| app.instance_exec(env, &filter) } if app
      @after_filters.each                { |filter| app.instance_exec(env, &filter) }

      resp
    end

    def response(env)
      if @handler.is_a? Proc
        app.instance_exec(env, &@handler)
      elsif @handler.is_a? String
        rails_style_response(env)
      else
        @handler.call(env)
      end
    end

    def rails_style_response(env)
      controller, method = @handler.split('#')

      obj = Object.const_get(controller).new

      if method
        obj.send(method.to_sym, env)
      else
        obj.call(env)
      end
    end

    def merge_with_options!(options)
      @options = {} unless @options
      options.each_pair do |key, value|
        accessor?(key) ? __send__("#{key}=", value) : (@options[key] = value)
      end
    end

    def accessor?(key)
      respond_to?("#{key}=") && respond_to?(key)
    end

    def matcher
      @matcher ||= Matcher.new(path, capture: @capture)
    end

    def match(pattern)
      matcher.match(pattern)
    end

    def path(*args)
      return @path if args.empty?
      params = args[0]
      params.delete(:captures)
      matcher.expand(params)
    end

    def params(pattern)
      params   = matcher.handler.params(pattern)
      params ||= {}
      params
    end
  end
end
