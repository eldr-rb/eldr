# frozen_string_literal: true

require 'rack/builder'

module Eldr
  # A Rack::Builder subclass that also tracks middleware so subclasses of
  # Eldr::App can inherit it. `Eldr::App.new` returns one of these.
  #
  # Semantics mirror {Rack::Builder} exactly, including `use` after `map`:
  # a middleware declared after a `map` wraps the generated URLMap, while a
  # middleware declared before it is applied inside each mapped branch.
  class Builder < Rack::Builder
    # @return [Array<Proc>] middleware appliers, in declaration order
    attr_accessor :middleware

    # @param default_app [Object, nil] the app to run when no block is given
    # @yield optional block evaluated via +instance_eval+ (the Rack DSL)
    def initialize(default_app = nil, &)
      @middleware = []
      @map = nil
      @run = default_app
      @warmup = nil
      instance_eval(&) if block_given?
    end

    # @param default_app [Object, nil] the default app
    # @return [Object] the built Rack app
    def self.app(default_app = nil, &)
      new(default_app, &).to_app
    end

    # Adds middleware. See {Rack::Builder#use} for the exact ordering rules.
    #
    # @param middleware [Class, Array] a middleware class or array of them
    # @return [void]
    def use(middleware, ...)
      if middleware.is_a? Array
        @middleware.push(*middleware)
      else
        if @map
          mapping = @map
          @map = nil
          @middleware << proc { |app| generate_map app, mapping }
        end
        @middleware << proc { |app| middleware.new(app, ...) }
      end
    end

    # Sets the innermost app.
    #
    # @param app [Object] a Rack app
    # @return [void]
    def run(app)
      @run = app
    end

    # Registers a warmup callback invoked with the built app by {#to_app}.
    #
    # @param prc [Proc, nil] the callback
    # @yield the callback, when no +prc+ is given
    # @return [void]
    def warmup(prc = nil, &block)
      @warmup = prc || block
    end

    # Maps a path prefix to a nested app.
    #
    # @param path [String] the URL prefix
    # @yield the nested builder body
    # @return [void]
    def map(path, &block)
      @map ||= {}
      @map[path] = block
    end

    # Builds the Rack app, applying middleware and running the warmup callback.
    #
    # @return [Object] a Rack app
    # @raise [RuntimeError] when no `run` or `map` statement was given
    def to_app
      app = @map ? generate_map(@run, @map) : @run
      raise 'missing run or map statement' unless app

      app = @middleware.reverse.inject(app) { |a, e| e[a] }
      @warmup&.call(app)
      app
    end

    # @param env [Hash] a Rack env
    # @return [Array] a Rack response triple
    def call(env)
      to_app.call(env)
    end

    private

    # @param default_app [Object, nil] the fallback app for unmatched paths
    # @param mapping [Hash{String => Proc}] path prefixes to builder bodies
    # @return [Rack::URLMap]
    def generate_map(default_app, mapping)
      mapped = default_app ? { '/' => default_app } : {}
      mapping.each { |r, b| mapped[r] = self.class.new(default_app, &b).to_app }
      Rack::URLMap.new(mapped)
    end
  end
end
