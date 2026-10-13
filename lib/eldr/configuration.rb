# frozen_string_literal: true

module Eldr
  # An OpenStruct-like configuration object. It wraps a hash and answers
  # unknown methods by pulling values from that hash. Designed to be far
  # lighter than Hashie::Mash.
  class Configuration
    attr_accessor :table

    def initialize
      defaults = { lock: false }
      table.merge!(defaults)
    end

    def set(key, value)
      @table[key] = value
    end

    def table
      @table ||= {}
    end

    def merge!(hash)
      hash = hash.table unless hash.is_a? Hash
      @table.merge!(hash)
    end

    def method_missing(method, *args)
      if args.empty?
        @table[method.to_s.gsub(/\?$/, '').to_sym]
      else # we assume we are setting something
        set(method.to_s.gsub(/=$/, '').to_sym, args.pop)
      end
    end

    def respond_to_missing?(method, _include_private = false)
      name = method.to_s
      name.end_with?('=') || @table.key?(name.gsub(/[=?]$/, '').to_sym) || super
    end
  end
end
