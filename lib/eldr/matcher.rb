# frozen_string_literal: true

require 'mustermann'

module Eldr
  # Wraps a route path (a String Mustermann pattern or a Regexp) and answers
  # {#match} and params extraction.
  #
  # @example
  #   matcher = Eldr::Matcher.new('/cats/:id')
  #   matcher.match('/cats/bob')  # => #<MatchData ...>
  #   matcher.params('/cats/bob') # => { "id" => "bob" }
  class Matcher
    # @param path [String, Regexp] the route pattern
    # @param options [Hash] options forwarded to Mustermann (`:capture`)
    # @raise [ArgumentError] when +path+ is neither a String nor a Regexp
    def initialize(path, options = {})
      unless path.is_a?(String) || path.is_a?(Regexp)
        raise ArgumentError, "unsupported path type: #{path.class} (expected String or Regexp)"
      end

      @path    = path
      @capture = options.delete(:capture)
    end

    # @param pattern [String] the path to match
    # @return [MatchData, nil] the match data, or nil when it does not match
    def match(pattern)
      handler.match(pattern)
    end

    # Extracts the pattern's params. Patterns without named captures (plain
    # literal paths) always yield an empty hash, so skip the match entirely.
    #
    # @param pattern [String] the path to extract params from
    # @return [Hash{String => String, Array<String>}] the extracted params
    def params(pattern)
      return {} if names.empty?

      handler.params(pattern) || {}
    end

    # @return [Array<String>] the pattern's named captures
    def names
      @names ||= handler.names
    end

    # @return [Mustermann::Pattern, Regexp] the compiled pattern
    def handler
      @handler ||= @path.is_a?(String) ? Mustermann.new(@path, capture: @capture) : /^(?:#{@path})$/
    end
  end
end
