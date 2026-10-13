# frozen_string_literal: true

require 'fast_blank'

module Eldr
  # Given the app's route table, +#call(env)+ returns the ordered list of
  # routes whose pattern matches the request path for the request's verb,
  # raising {NotFound} when none match.
  class Recognizer
    class NotFound < StandardError
      def call(_env)
        [404, {}, ['']]
      end
    end

    attr_accessor :app, :env, :routes, :pattern

    def initialize(routes)
      @routes = routes
    end

    def call(env)
      @env = env

      ret_routes = routes[verb].reject { |route| route.match(pattern).nil? }
      raise NotFound if ret_routes.empty?

      ret_routes.sort! { |a, b| a.order <=> b.order }
      ret_routes
    end

    def pattern
      @pattern = env['PATH_INFO']
      @pattern = '/' if @pattern.blank?
      @pattern
    end

    def verb
      env['REQUEST_METHOD'].downcase.to_sym
    end
  end
end
