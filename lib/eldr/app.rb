# frozen_string_literal: true

require 'forwardable'
require 'rack/request'

require_relative 'route'
require_relative 'matcher'
require_relative 'recognizer'
require_relative 'configuration'
require_relative 'builder'

# Eldr is a minimal Rack-based micro-framework.
module Eldr
  # The main class all Eldr apps extend. Subclasses define routes with the
  # verb DSL (get/post/...) and are themselves Rack apps via +call+.
  #
  # @example Defining an app
  #   class ExampleApp < Eldr::App
  #     get '/' do
  #       [200, { 'content-type' => 'text/plain' }, ['Hello, world!']]
  #     end
  #
  #     get '/hello/:name' do
  #       name = params['name']
  #       [200, { 'content-type' => 'text/plain' }, ["Hello, #{name}!"]]
  #     end
  #   end
  #
  #   # config.ru
  #   run ExampleApp
  class App
    # @return [Hash] the Rack env for the request currently being served
    attr_accessor :env

    # @return [Eldr::Configuration] the app's configuration
    attr_accessor :configuration

    # @return [Array<String>] the HTTP verbs the DSL exposes
    HTTP_VERBS = %w[DELETE GET HEAD OPTIONS PATCH POST PUT].freeze

    class << self
      # @return [Hash{Symbol => Array<Eldr::Route>}] routes keyed by verb
      attr_accessor :routes

      # @return [Eldr::Recognizer] the class-level route recognizer
      attr_accessor :recognizer

      # @return [Eldr::Builder] the class-level Rack builder
      attr_accessor :builder

      # @return [Hash{Symbol => Array<Proc>}] named before filters
      attr_accessor :before_filters

      # @return [Hash{Symbol => Array<Proc>}] named after filters
      attr_accessor :after_filters

      # @return [Eldr::Configuration] the class-level configuration
      attr_accessor :configuration

      extend Forwardable

      def_delegators :builder, :map, :use

      # The undecorated constructor. Most callers want {.new} instead; `_new` is
      # what internally creates the bare App instance.
      #
      # @return [Eldr::App]
      alias _new new

      # Public DSL: `Eldr::App.new` returns the app's {Eldr::Builder} (wired up
      # with the app instance via `builder.run`), not a bare App instance. This
      # is what makes `run ExampleApp` work in config files.
      #
      # @return [Eldr::Builder]
      def new(...)
        builder.run _new(...)
        builder
      end

      # @param env [Hash] a Rack env
      # @return [Array] a Rack response triple
      def call(env)
        new.call env
      end

      # Copies the parent's middleware and configuration onto a subclass.
      #
      # @param base [Class] the newly created subclass
      # @return [void]
      def inherited(base)
        base.builder.use builder.middleware
        base.configuration.merge!(configuration)
      end

      # @return [Eldr::Builder] the lazily created builder for this app
      def builder
        @builder ||= Builder.new
      end

      # @return [Eldr::Configuration] the lazily created configuration
      def configuration
        @configuration ||= Configuration.new
      end
      alias config configuration

      # Sets a configuration value.
      #
      # @param key [Symbol] the configuration key
      # @param value [Object] the value to store
      # @return [Object] the stored value
      def set(key, value)
        configuration.set(key, value)
      end

      # @return [Hash{Symbol => Array<Proc>}] before filters, with an `:all` key
      def before_filters
        @before_filters ||= { all: [] }
      end

      # @return [Hash{Symbol => Array<Proc>}] after filters, with an `:all` key
      def after_filters
        @after_filters ||= { all: [] }
      end

      # Registers one or more before filters. Called without keys, the block
      # runs before every route.
      #
      # @param keys [Array<Symbol>] route names the filter applies to
      # @yieldparam env [Hash] the Rack env
      # @return [void]
      def before(*keys, &block)
        *keys = [:all] if keys.empty?
        keys.each do |key|
          before_filters[key] ||= []
          before_filters[key] << block
        end
      end

      # Registers one or more after filters. Called without keys, the block runs
      # after every route.
      #
      # @param keys [Array<Symbol>] route names the filter applies to
      # @yieldparam env [Hash] the Rack env
      # @return [void]
      def after(*keys, &block)
        *keys = [:all] if keys.empty?
        keys.each do |key|
          after_filters[key] ||= []
          after_filters[key] << block
        end
      end

      # @return [Hash{Symbol => Array<Eldr::Route>}] routes keyed by verb
      def routes
        @routes ||= { delete: [], get: [], head: [], options: [], patch: [], post: [], put: [] }
      end

      # @return [Eldr::Recognizer] the lazily created recognizer
      def recognizer
        @recognizer ||= Recognizer.new(routes)
      end

      HTTP_VERBS.each do |verb|
        # Defines a route for +verb+.
        #
        # @param path [String, Regexp] the route pattern
        # @param args [Array] an optional handler and options hash
        # @yield [env] the request handler
        # @return [Eldr::Route] the created route
        define_method verb.downcase.to_sym do |path, *args, &block|
          handler = Proc.new(&block) if block
          handler ||= args.pop if args.last.respond_to?(:call)
          options ||= args.pop if args.last.is_a?(Hash)
          options ||= {}
          opts = { verb: verb.downcase.to_sym, path: path, handler: handler }.merge!(options)
          add(**opts)
        end
      end

      # Adds a route, attaching any matching named filters.
      #
      # @param verb [Symbol] the HTTP verb
      # @param route_attributes [Hash] passed through to {Eldr::Route.new}
      # @return [Eldr::Route]
      def add(verb: :get, **route_attributes)
        route = Route.new(**route_attributes)

        route.before_filters.push(*before_filters[route.name]) if before_filters.include? route.name
        route.after_filters.push(*after_filters[route.name])   if after_filters.include? route.name

        routes[verb] << route
        route
      end
      alias << add
    end

    # @param configuration [Eldr::Configuration, nil] defaults to the class's
    def initialize(configuration = nil)
      configuration ||= self.class.configuration
      @configuration = configuration
    end

    # Rack entry point. Serves a duplicate of the app so per-request state
    # (+@env+) never leaks between concurrent requests.
    #
    # @param env [Hash] a Rack env
    # @return [Array] a Rack response triple
    def call(env)
      dup.call!(env)
    end

    # Serves a request on this instance, without duping. Each matching route is
    # tried in turn; a handler may `throw :pass` to fall through to the next
    # one. Exceptions that respond to +#call+ are treated as error handlers.
    #
    # @param env [Hash] a Rack env
    # @return [Array] a Rack response triple
    def call!(env)
      @env = env

      recognize(env).each do |route|
        env['eldr.route'] = route
        params.merge!(route.params(env['PATH_INFO']))
        catch(:pass) do
          resp = route.call(env, app: self)
          # Normalize Rack::Response (and any object with #to_a) into the
          # [status, headers, body] Array required by the Rack 3 SPEC.
          return resp.is_a?(Array) ? resp : resp.to_a
        end
      end
    rescue StandardError => e
      raise e unless e.respond_to? :call

      resp = e.call(env)
      resp.is_a?(Array) ? resp : resp.to_a
    end

    # @return [Rack::Request] the memoized request for the current env
    def request
      env['eldr.request'] ||= Rack::Request.new(env)
    end

    # Query/form params merged with the current route's path params.
    #
    # @return [Hash] the merged params
    def params
      env['eldr.params'] ||= request.params
    end

    # @param env [Hash] a Rack env
    # @return [Array<Eldr::Route>] routes matching the request, in order
    def recognize(env)
      self.class.recognizer.call(env)
    end
  end
end
