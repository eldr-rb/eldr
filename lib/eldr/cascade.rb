# frozen_string_literal: true

module Eldr
  # A {Rack::Cascade} replacement that chains apps together and returns the
  # first response whose status is not "caught" (default 404 / 405).
  #
  # @example
  #   use Eldr::Cascade, [primary_app, fallback_app]
  class Cascade
    # The response returned when every app is caught.
    NOTFOUND = [404, { 'content-type' => 'text/plain' }, []].freeze

    # @return [Array<Object>] the chained Rack apps, in order
    attr_reader :apps

    # @param apps [Array<Object>] Rack apps to try in order
    # @param catch [Integer, Array<Integer>] status codes that trigger the next app
    def initialize(apps, catch = [404, 405])
      @apps    = []
      @has_app = {}

      apps.each { |app| add app }

      @catch = {}
      [*catch].each { |status| @catch[status] = true }
    end

    # Tries each app until one returns an uncatched status.
    #
    # @param env [Hash] a Rack env
    # @return [Array] a Rack response triple
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

    # Appends an app to the chain.
    #
    # @param app [Object] a Rack app
    # @return [Array<Object>] the updated list of apps
    def add(app)
      @has_app[app] = true
      @apps << app
    end

    # @param app [Object] a Rack app
    # @return [Boolean] whether +app+ is already in the chain
    def include?(app)
      @has_app.include? app
    end

    alias << add
  end
end
