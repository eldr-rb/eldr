module Eldr
  ###
  # This a OpenStruct like class.
  # It wraps a hash and when you hit a method that doesn't exist it tries to pull it from the hash
  # Probably can break in 100 ways an is dumb, but it works.
  # And it performs astromnomically better than stuff like Hashie::Mash
  ###
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
      if !args.empty? # we assume we are setting something
        set(method.to_s.gsub(/\=$/, '').to_sym, args.pop)
      else
        @table[method.to_s.gsub(/\?$/, '').to_sym]
      end
    end
  end
end
