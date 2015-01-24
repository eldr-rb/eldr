require 'rack/builder'

module Eldr
  class Builder < Rack::Builder
    attr_accessor :middleware
    def initialize(default_app = nil, &block)
      @middleware, @map, @run, @warmup = [], nil, default_app, nil
      instance_eval(&block) if block_given?
    end

    def self.app(default_app = nil, &block)
      new(default_app, &block).to_app
    end

    def use(middleware, *args, &block)
      if middleware.is_a? Array
        @middleware.push(*middleware)
      else
        if @map
          mapping, @map = @map, nil
          @middleware << proc { |app| generate_map app, mapping }
        end
        @middleware << proc { |app| middleware.new(app, *args, &block) }
      end
    end

    def run(app) # rubocop:disable Style/TrivialAccessors
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
      fail 'missing run or map statement' unless app
      app = @middleware.reverse.inject(app) { |a, e| e[a] }
      @warmup.call(app) if @warmup
      app
    end

    def call(env)
      to_app.call(env)
    end

    private

    def generate_map(default_app, mapping)
      mapped = default_app ? { '/' => default_app } : {}
      mapping.each { |r, b| mapped[r] = self.class.new(default_app, &b).to_app }
      URLMap.new(mapped)
    end
  end
end
