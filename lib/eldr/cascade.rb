# A version of Rack::Cascade that works with Rack::Response.
# Seriously? WTF Rack::Cascade
# TODO: Get fixes into rack and remove this entirely
module Eldr
  class Cascade
    NotFound = [404, {'CONTENT-TYPE' => "text/plain"}, []]

    attr_reader :apps

    def initialize(apps, catch=[404, 405])
      @apps = []; @has_app = {}
      apps.each { |app| add app }

      @catch = {}
      [*catch].each { |status| @catch[status] = true }
    end

    def call(env)
      result = NotFound

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

    alias_method :<<, :add
  end
end
