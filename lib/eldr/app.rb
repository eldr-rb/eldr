require 'forwardable'
require 'rack/request'

require_relative 'route'
require_relative 'matcher'
require_relative 'recognizer'
require_relative 'configuration'
require_relative 'builder'

###
# Eldr is a minimal Ruby framework
###
module Eldr
  ###
  # The main class all Eldr apps extend
  ###
  class App # rubocop:disable Metrics/ClassLength
    attr_accessor :env, :configuration
    HTTP_VERBS = %w(DELETE GET HEAD OPTIONS PATCH POST PUT)

    class << self
      attr_accessor :routes, :recognizer, :builder, :before_filters, :after_filters, :configuration
      extend Forwardable
      def_delegators :builder, :map, :use

      alias_method :_new, :new
      def new(*args, &block)
        builder.run _new(*args, &block)
        builder
      end

      def call(env)
        new.call env
      end

      def inherited(base)
        base.builder.use builder.middleware
        base.configuration.merge!(configuration)
      end

      def builder
        @builder ||= Builder.new
      end

      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :config, :configuration

      def set(key, value)
        configuration.set(key, value)
      end

      def before_filters
        @before_filters ||= { all: [] }
      end

      def after_filters
        @after_filters ||= { all: [] }
      end

      def before(*keys, &block)
        *keys = [:all] if keys.empty?
        keys.each do |key|
          before_filters[key] ||= []
          before_filters[key] << block
        end
      end

      def after(*keys, &block)
        *keys = [:all] if keys.empty?
        keys.each do |key|
          after_filters[key] ||= []
          after_filters[key] << block
        end
      end

      def routes
        @routes ||= { delete: [], get: [], head: [], options: [], patch: [], post: [], put: [] }
      end

      def recognizer
        @recognizer ||= Recognizer.new(routes)
      end

      HTTP_VERBS.each do |verb|
        define_method verb.downcase.to_sym do |path, *args, &block|
          handler = Proc.new(&block) if block
          handler ||= args.pop if args.last.respond_to?(:call)
          options ||= args.pop if args.last.is_a?(Hash)
          options ||= {}
          add(verb: verb.downcase.to_sym, path: path, handler: handler, options: options)
        end
      end

      def add(verb: :get, path: '/', options: {}, handler: nil)
        handler = Proc.new if block_given?
        route = Route.new(verb: verb, path: path, options: options, handler: handler)

        route.before_filters.push(*before_filters[route.name]) if before_filters.include? route.name
        route.after_filters.push(*after_filters[route.name]) if after_filters.include? route.name

        routes[verb] << route
        route
      end
      alias_method :<<, :add
    end

    def initialize(configuration = nil)
      configuration ||= self.class.configuration
      @configuration = configuration
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env

      recognize(env).each do |route|
        env['eldr.route'] = route
        params.merge!(route.params(env['PATH_INFO']))
        catch(:pass) { return route.call(env, app: self) }
      end
      rescue => error
        if error.respond_to? :call
          error.call(env)
        else
          raise error
        end
    end

    def request
      env['eldr.request'] ||= Rack::Request.new(env)
    end

    def params
      env['eldr.params'] ||= request.params
    end

    def recognize(env)
      self.class.recognizer.call(env)
    end
  end
end
