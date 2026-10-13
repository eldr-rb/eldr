# frozen_string_literal: true

require 'rack/builder'

module Eldr
  # A Rack::Builder subclass that also tracks middleware so subclasses of
  # Eldr::App can inherit it. +#new+ on an App class returns one of these.
  class Builder < Rack::Builder
    attr_accessor :middleware

    def initialize(default_app = nil, &)
      @middleware = []
      @map = nil
      @run = default_app
      @warmup = nil
      instance_eval(&) if block_given?
    end

    def self.app(default_app = nil, &)
      new(default_app, &).to_app
    end

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

    def run(app)
      @run = app
    end

    def warmup(prc = nil, &block)
      @warmup = prc || block
    end

    def map(path, &block)
      @map ||= {}
      @map[path] = block
    end

    def to_app
      app = @map ? generate_map(@run, @map) : @run
      raise 'missing run or map statement' unless app

      app = @middleware.reverse.inject(app) { |a, e| e[a] }
      @warmup&.call(app)
      app
    end

    def call(env)
      to_app.call(env)
    end

    private

    def generate_map(default_app, mapping)
      mapped = default_app ? { '/' => default_app } : {}
      mapping.each { |r, b| mapped[r] = self.class.new(default_app, &b).to_app }
      Rack::URLMap.new(mapped)
    end
  end
end
