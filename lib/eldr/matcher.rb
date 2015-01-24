require 'mustermann'

module Eldr
  class Matcher
    PATH_DELIMITER  = '/'.freeze
    QUERY_PREFIX    = '?'.freeze
    QUERY_DELIMITER = '&'.freeze

    def initialize(path, options = {})
      @path = path.is_a?(String) && path.empty? ? PATH_DELIMITER : path
      @capture = options.delete(:capture)
      @default_values = options.delete(:default_values)
    end

    def match(pattern)
      match_data = handler.match(pattern)
      return match_data if match_data
      pattern = pattern[0..-2] if mustermann? && pattern != PATH_DELIMITER && pattern.end_with?(PATH_DELIMITER)
      handler.match(pattern)
    end

    def mustermann?
      handler.instance_of?(Mustermann)
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
