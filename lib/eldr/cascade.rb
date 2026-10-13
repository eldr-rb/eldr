# frozen_string_literal: true

# A Rack::Cascade replacement that chains apps together and returns the
# first response whose status is not "caught" (default 404 / 405).
module Eldr
  # See Eldr::Cascade (top-level docs).
  class Cascade
    NOTFOUND = [404, { 'content-type' => 'text/plain' }, []].freeze

    attr_reader :apps

    def initialize(apps, catch = [404, 405])
      @apps    = []
      @has_app = {}

      apps.each { |app| add app }

      @catch = {}
      [*catch].each { |status| @catch[status] = true }
    end

    def call(env)
      result = NOTFOUND

      last_body = nil

      @apps.each do |app|
        last_body.close if last_body.respond_to? :close

        result = app.call(env).to_a
        last_body = result[2]
        break unless @catch.include?(result[0].to_i)
      end

      result
    end

    def add(app)
      @has_app[app] = true
      @apps << app
    end

    def include?(app)
      @has_app.include? app
    end

    alias << add
  end
end
