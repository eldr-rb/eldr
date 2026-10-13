# frozen_string_literal: true

require 'mustermann'

module Eldr
  # Wraps a route path (a String Mustermann pattern or a Regexp) and answers
  # +#match+ and params extraction.
  class Matcher
    def initialize(path, options = {})
      @path    = path
      @capture = options.delete(:capture)
    end

    def match(pattern)
      handler.match(pattern)
    end

    def handler
      @handler ||=
        case @path
        when String
          Mustermann.new(@path, capture: @capture)
        when Regexp
          /^(?:#{@path})$/
        end
    end
  end
end
