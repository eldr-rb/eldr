# frozen_string_literal: true

module Eldr
  # An OpenStruct-like configuration object. It wraps a hash and answers
  # unknown methods by pulling values from that hash. Designed to be far
  # lighter than Hashie::Mash.
  #
  # @example
  #   config = Eldr::Configuration.new
  #   config.set(:lock, true)
  #   config.lock     # => true
  #   config.lock = false
  #   config.lock     # => false
  class Configuration
    # @return [Hash] the backing table
    attr_accessor :table

    def initialize
      defaults = { lock: false }
      table.merge!(defaults)
    end

    # @param key [Symbol] the configuration key
    # @param value [Object] the value to store
    # @return [Object] the stored value
    def set(key, value)
      @table[key] = value
    end

    # @return [Hash] the backing table, created on first access
    def table
      @table ||= {}
    end

    # @param hash [Hash, Eldr::Configuration] the values to merge in
    # @return [Hash] the merged table
    def merge!(hash)
      hash = hash.table unless hash.is_a? Hash
      @table.merge!(hash)
    end

    # Reads (no arguments) or writes (arguments) configuration values.
    #
    # @param method [Symbol] the key, optionally suffixed with +?+ or +=+
    # @param args [Array] the value when setting
    # @return [Object] the stored value
    def method_missing(method, *args)
      if args.empty?
        @table[method.to_s.gsub(/\?$/, '').to_sym]
      else # we assume we are setting something
        set(method.to_s.gsub(/=$/, '').to_sym, args.pop)
      end
    end

    # @param method [Symbol] the method name
    # @param _include_private [Boolean] unused
    # @return [Boolean]
    def respond_to_missing?(method, _include_private = false)
      name = method.to_s
      name.end_with?('=') || @table.key?(name.gsub(/[=?]$/, '').to_sym) || super
    end
  end
end
