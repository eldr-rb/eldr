# frozen_string_literal: true

require 'fast_blank'

module Eldr
  # Given the app's route table, {#call} returns the ordered list of routes
  # whose pattern matches the request path for the request's verb, raising
  # {NotFound} when none match.
  class Recognizer
    # Raised when no route matches the request. It doubles as a Rack app so it
    # can be used as an error handler.
    class NotFound < StandardError
      # @param _env [Hash] a Rack env
      # @return [Array] a 404 Rack response triple
      def call(_env)
        [404, {}, ['']]
      end
    end

    # @return [Object] the app the recognizer belongs to, when set
    attr_accessor :app

    # @return [Hash] the env of the request last passed to {#call} or {#pattern}
    attr_accessor :env

    # @return [Hash{Symbol => Array<Eldr::Route>}] routes keyed by verb
    attr_accessor :routes

    # @return [String, nil] the normalized path from the last {#pattern} call
    attr_accessor :pattern

    # @param routes [Hash{Symbol => Array<Eldr::Route>}] the app's route table
    def initialize(routes)
      @routes = routes
    end

    # Finds the routes matching the request. Routes are matched in registration
    # order and only sorted when more than one route matches.
    #
    # @param env [Hash] a Rack env
    # @return [Array<Eldr::Route>] the matching routes, in registration order
    # @raise [Eldr::Recognizer::NotFound] when no route matches
    def call(env)
      @env = env

      path = env['PATH_INFO']
      path = '/' if path.blank?

      matched = []
      routes[env['REQUEST_METHOD'].downcase.to_sym].each do |route|
        matched << route unless route.match(path).nil?
      end

      raise NotFound if matched.empty?

      matched.sort_by!(&:order) if matched.length > 1
      matched
    end

    # @return [String] the request path, normalized to +/+ when blank
    def pattern
      @pattern = env['PATH_INFO']
      @pattern = '/' if @pattern.blank?
      @pattern
    end

    # @return [Symbol] the downcased request method as a symbol
    def verb
      env['REQUEST_METHOD'].downcase.to_sym
    end
  end
end
