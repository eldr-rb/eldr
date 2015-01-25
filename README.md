# Eldr [![Build Status](https://travis-ci.org/eldr-rb/eldr.svg)](https://travis-ci.org/eldr-rb/eldr) [![Code Climate](https://codeclimate.com/github/eldr-rb/eldr/badges/gpa.svg)](https://codeclimate.com/github/eldr-rb/eldr) [![Coverage Status](https://coveralls.io/repos/eldr-rb/eldr/badge.svg)](https://coveralls.io/r/eldr-rb/eldr) [![Dependency Status](https://gemnasium.com/eldr-rb/eldr.svg)](https://gemnasium.com/eldr-rb/eldr) [![Inline docs](http://inch-ci.org/github/eldr-rb/eldr.svg?branch=master)](http://inch-ci.org/github/eldr-rb/eldr)

Eldr is a minimal ruby framework that doesn't hide the rack. It aims to be lightweight, simple, modular and above all, clear. Eldr is a ruby framework without all the magic.

Eldr apps are rack apps like this:

```ruby
class App < Eldr::App
  get '/posts' do |params|
    Rack::Response.new "posts", 200
  end
end
```

Since they are rack apps you can boot them like this:

```ruby
run App
```

And when you want to combine them you can do this:

```ruby
class Posts < Eldr::App
  get '/' do |params|
    Rack::Response.new "posts", 200
  end
end

class Tasks < Eldr::App
  get '/' do |params|
    Rack::Response.new "tasks", 200
  end
end

map '/posts' do
  Posts.new
end

map '/tasks' do
  run Tasks.new
end
```

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Eldr](#eldr)
  - [Features](#features)
  - [Installation and Usage](#installation-and-usage)
  - [Quickstart Guides](#quickstart-guides)
    - [Hello World](#hello-world)
    - [Rendering a Template](#rendering-a-template)
    - [Before/After Filters](#beforeafter-filters)
    - [Helpers](#helpers)
    - [Rails Style Routing](#rails-style-routing)
    - [Rails Style Responses](#rails-style-responses)
    - [Errors](#errors)
    - [Error Catching](#error-catching)
    - [Rails Style Requests](#rails-style-requests)
    - [Conditions](#conditions)
    - [Access Control](#access-control)
    - [Inheritance](#inheritance)
    - [Extensions](#extensions)
      - [Extending using Ruby patterns](#extending-using-ruby-patterns)
      - [Extending using Rack](#extending-using-rack)
    - [Using Rack inside Eldr](#using-rack-inside-eldr)
    - [Redirecting Things](#redirecting-things)
    - [Route Handlers: The Power of Action Objects](#route-handlers-the-power-of-action-objects)
    - [Testing Eldr Apps](#testing-eldr-apps)
  - [Performance](#performance)
  - [Help/Resources](#helpresources)
  - [Contributing](#contributing)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

- **Small**           Eldr's core is under 500 lines; you can learn it in an afternoon.
- **Flexible**        Build your apps how you want to and with what you want.
- **Modular**         Eldr's views, response helpers, sessions etc; are all independent gems.
- **No Magic**        Eldr encourages you to build apps that you actually understand.
- **Fast**            Eldr is among the fastest ruby microframeworks and it is getting faster.
- **Powerful Router** Powered by [Mustermann](https://github.com/rkh/mustermann) -- you can use everything from Sinatra to Rails style routing.
- **Flexible**        That router? Is also just a Rack app. You can swap it out just like everything else in Eldr.
- **Extensible** with standard ruby classes, modules, and patterns. In Eldr there are no mystical helper blocks.

## Installation and Usage

To install Eldr add the following to your gemfile:

```ruby
gem 'eldr'
# or if you want to use the master branch:
# gem 'eldr', github: 'eldr-rb/eldr'
```

Then run bundler:

```sh
$ bundle
```

To use it you need to create a rackup file. Add the following to a config.ru file:

```ruby
class HelloWorld < Edlr::App
  get '/', proc { [200, {'Content-Type' => 'txt'}, ['Hello World!']]}
end

run HelloWorld
```

Route handlers are anything that respond to call and return a valid Rack response. All the http verbs you expect are available:

```ruby
get '/',  proc { [200, {'Content-Type' => 'txt'}, ['Hello World!']]}
post '/', proc { [201, {'Content-Type' => 'txt'}, ['Hello World!']]}
```

etc...

For further usage examples checkout the  [https://github.com/eldr-rb/eldr/tree/master/examples](examples folder)

I have already built and released extensions for many common tasks:

- [https://github.com/eldr-rb/eldr-sessions](eldr-sessions): session helpers like `signed_in?` and `current_user?`
- [https://github.com/eldr-rb/eldr-rendering](eldr-rendering): a `render` helper for templating.
- [https://github.com/eldr-rb/eldr-assets](eldr-assets): asset tag helpers like `js('jquery', 'app')`, `css('app')` etc
- [https://github.com/eldr-rb/eldr-responders](eldr-responders): rails-responder like helpers
- [https://github.com/eldr-rb/eldr-action](eldr-action): Action Objects
- [https://github.com/eldr-rb/eldr-service](eldr-service): Action Objects for external services.
- [https://github.com/eldr-rb/eldr-cascade](eldr-cascade): A fork of Rack::Cascade that plays well with Rack::Response and eldr-action.

## Quickstart Guides

### Hello World

Start by adding the following to your gemfile:

```ruby
gem 'edlr'
```

Then run bundler:

```
$ bundle install
```

Now create a new file called app.rb with the following contents:

```ruby
class App < Eldr::App
  get '/' do |params|
    Rack::Response.new "Hello World!", 200
  end
end
```

This defines a new App with a root route that returns "Hello World!". To make use of this app we need to add a rackup file. In the root of your project create a new file called config.ru:

```ruby
require_relative 'app'
run App
```

Now boot it using rackup:

```sh
$ rackup
```

When you visit http:///localhost:9292 in your browser you should see "Hello World!"

### Rendering a Template

Eldr provides no render helper in it's core but it is easy to define your own.
One can use Tilt as the templating library (with your engine of choice) and then create some helper methods to handle finding the template and rendering it.

Create a module with the following:

```ruby
module RenderingHelpers
  def render(path, resp_code=200)
    Rack::Response.new Tilt.new(find_template(path)).render(self), resp_code
  end

  def find_template(path)
    template = File.join('views', path)
    raise NotFoundError unless File.exists? template
    template
  end
end
```

This takes a template, finds the template and then passes it off to tilt for handling.
If the template does not exist it raises a NotFoundError.

We can use these helpers by including them in our App:

```ruby
class App
  include RenderingHelpers

  get '/cats' do
    render 'cats.slim'
  end
end
```

Using it, is as simple as including it!

*Checkout*: [https://github.com/eldr-rb/eldr-rendering](eldr-rendering) for some pre-made rendering helpers.

### Before/After Filters

Eldr comes with support for before/after filters. You can add a filter like this:

```ruby
class App < Eldr::App
  before do
    @message = 'Hello World!'
  end

  after do
    puts 'after'
  end

  get '/', proc { [200, {}, [@message]] }
end
```

Filters can be limited to specific routes by giving your route a name:

```ruby
class App < Eldr::App
  before(:bob) do
    @message = 'Hello World!'
  end

  after(:bob) do
    puts 'after'
  end

  get '/', name: :bob, proc { [200, {}, [@message]] }
end
```

### Helpers

In Eldr, helpers are not mystical elements, they are plain ruby modules:

```ruby
module Helpers
end
```

If you need registration callbacks then you can make use of ruby's own included callback:

```ruby
module Helpers
  def included(klass)
  end
end
```

If you need to define these methods directly on the app class, something like _helpers do_, you can do the following:

```ruby
class App
  def helper_method
  end
end
```

This will put your helper method on every instance of your app's class and make it available to any templates.

### Rails Style Routing

In the rails world routes are methods on controller instances:

```ruby
class Cats
  def index
    # stuff here
  end
end
```

Then in a separate router object we map our routes to these action methods.

```ruby
get '/cats', to: 'cats#index'
```

This is easy to do with Eldr; because Eldr apps are Rack apps, we can use one as a dispatcher/router and then another as our controller.

```ruby
class Cats
  def index
    Rack::Response.new "Hello From all the Cats!"
  end
end
```

Then run it:

```ruby
run Router.new do
  get '/cats', to: 'cats#index'
end
```

We could add a lot more abstraction but this is simple enough and accomplishes our goals. Eldr encourages you to _build up_ abstractions as you go.

Pre-building flexibility and accounting for things you don't need to do yet is unnecessary work. You should build apps that you can _see into_ and actually understand, no magic.

### Rails Style Responses

The Rails world has a tremendous amount of conventions and abstraction for dealing with responses. They range from complex to simple, from format helpers to full fledged REST abstractions. At their core, they all take information from Rack::Request and turn it into a valid Rack response -- and a valid rack response is just an array.

Once we realize this, replicating rails becomes just a matter of patterns.

Eldr routes must return a valid rack response, which is an array -- actually its just something that can act like an array. We can return an object that responds to :to_a and Rack will be just as happy.

Let's create a object that holds a response string, response headers, and a status.

```ruby
class Response
  attr_accessor :status, :headers, :body

  def initialize(body, status=200, headers={})
    @body, @status, @headers = body, status, headers
  end
end
```

Now add a to_a method:

```ruby
def to_a
  [@status, @headers, [@body]]
end
alias_method :to_ary, :to_a # this makes ruby aware the object can act like an array
```

To use this we just return a new instance of it as our response:

```ruby
Eldr::App.new do
  get '/' do
    Response.new("Hello World!")
  end
end
```

This simple pattern is enough to build all sorts of powerful abstractions.

### Errors

You can `raise` an error with any class that inherits from StandardError and responds to call. This is useful in before filters, when you want to halt a route from executing.

An error class looks like this:

```ruby
class ErrorResponse < StandardErrro
  def call(env)
    Rack::Response.new message, 500
  end
end
```

And you can use it like a standard ruby error class:

```ruby
app = Edlr::App.new do
  get '/' do
    raise ErrorResponse, "Bad Data"
  end
end

run app
```

### Error Catching

Eldr will NOT catch all errors. In a production setting you will need to use middleware to make certain nothing ever explodes at your user. Something like [rack-robustness](https://github.com/blambeau/rack-robustness) will work fine:

```ruby
class App < Edlr::App
  use Rack::Robustness do |g|
    g.on(ArgumentError){|ex| 400 }
    g.on(SecurityError){|ex| 403 }

    g.content_type 'text/plain'

    g.body{|ex|
      ex.message
    }

    g.ensure(true){|ex|
      env['rack.errors'].write(ex.message)
    }
  end
end

run App
```

### Rails Style Requests

Rails provides all sorts of ways to digest the data passed to it by a client. At their core they all operate on Rack's env object. They take Rack's env object and pass it off to a wrapper.

The wrapper modifies the request _only_ on the env object, this means at any point we can duplicate the state of the wrapper by passing it the env; and any objects that need parsed request data (e.g params) will know to find it in the env object.

The most typical way rails helps us with requests is through parameter parsing and validation. If we of params a just a hash, then validating, error handling on them etc is simple, we can use all the tools we are already used to.

Lets start by getting our parameters into a hash. To do this we pass env into Rack::Request; a wrapper object that parses the query string and injects the results into @env["rack.request.query_hash"]:

```ruby
class App < Eldr::App
  post '/cats' do |env|
    request = Rack::Request.new(env)
    params  = request.GET # we could also access it from env["rack.request.query_hash"]
  end
end
```

Now we will need an object to _validate_ the parameters. We can use Virtus and ActiveModel::Validations for this:

```ruby
class CatParams
  include Virtus.model
  include ActiveModel::Validations

  attribute :name,       String
  attribute :age,        Integer
  attribute :human_kils, Integer

  validates :name, :age, :human_kills, presence: true
end
```

To _validate_ a request we need to instantiate CatParams:

```ruby
class InvalidParams < Edlr::ResponseError
  def status
    400
  end
end

class App < Eldr::App
  post '/cats' do |env|
    request = Rack::Request.new(env)
    params  = CatParams.new(request.GET)

    raise InvalidParams.new(errors) unless params.valid?

    cat = Cat.create(params.attributes)
    Rack::Response.new(cat.to_json)
  end
end
```

If our parameters are invalid we raise an InvalidParams response (Eldr has error handling). If they are valid, then we create our Cat and return it as JSON.

### Conditions

Most microframeworks provide a DSL for route conditions. This needlesly complicates a framework with multiple ways to do things. Do we check for _x_ in our conditions or do we check for it in the route's handler?

Eldr's strives for clarity. There is only one place to place logic for a route, in the route's handler.

If you want a route to only be executed under certain conditions you check those conditions in the handler and then `throw :pass` if conditions match/do not match:

```ruby
  get '/' do
    throw :pass if params['agent'] == 'secret'
    # respond here
  end

  # Executed only if we pass from the first route
  get '/' do
  end
```

### Access Control

Originally Eldr had an access control DSL that looked like this:

```ruby
access_control do
  allow :create, :registered, :admin
end
```

The DSL pulled a route's name and it's roles into a before filter, then checked them against the current_user's roles. The filter itself was five lines.

I soon realized that this was redundant abstraction. The DSL didn't save me any coding, it merely gave the code pretty words. I was sacrificing clarity for poetry.

To protect a route you need a before filter that checks the user for roles. It can look like this:

```ruby
before :create, :edit do
  unless current_user.has_role? :admin
    raise NotAuthorized, "You are not authorized to do this!"
  end
end
```

It is just as short as any DSL and ambiguity free. Any ruby developer can guess what
it means without having to know your framework's secret language.

### Inheritance

In many frameworks you are encouraged to wrap your controllers in a central app.
You build a main app that handles routing, scoping, sharing configuration and middleware etc; often controllers are merely blocks executed in the context of this app. This allows you to build DRY controllers but at the cost of a large central app.

In Eldr we reverse this model and encourage you to build up your controllers through inheritance. Eldr apps can inherit middleware and configuration from parent apps.
This allows you to define a base app and allow all your controllers to share the same configuration.

For example:

```ruby
class SimpleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['eldr.simple_counter'] ||= 0
    env['eldr.simple_counter'] += 1
    @app.call(env)
  end
end

class BaseApp < Eldr::App
  use SimpleCounterMiddleware
  set :bob, 'what about him?'
end

class InheritedApp < BaseApp
  get '/', proc { [200, {}, [env['eldr.simple_counter']]]}
end

run InheritedApp
```

### Extensions

Extending a framework is a mystical process full of esoteric patterns and confusing APIs. Engines, helper blocks, plugin apis, and if you are lucky yaml configuration.

You can extend Eldr in two ways;

1. Through standard Ruby patterns
2. Through standard Rack patterns

#### Extending using Ruby patterns

Ruby patterns are something you are already intimately familiar with. Include, extend, ducks, blocks, procs etc are something you know like the front of your MacBook (btw you should _really_ clean that smudge). Eldr is a DSL you already know how to speak.

I have designed Edlr to work well with common ruby patterns; you can include it, extend it, pass it blocks etc, and it wont blow up. If it does blow up its a bug.

You can add methods to your app (i.e helpers) by including them:

```ruby
class App < Eldr::App
  include Helpers
end
```

If you want to use an app as a block you can:

```ruby
run App.new do
  get '/' { Rack::Response.new "Hello World" }
end
```

Flexibility in Eldr is not accomplished through abstraction but through clarity. You can make Eldr do what you want it to because you will understand it not because it provides every feature.

#### Extending using Rack

Rails has a powerful code reuse model. You can generalize routes, controllers, even assets and views, then share them. Authentication/Authorization, shopping carts, social engines, admin panels, all abound in the rails world. This reuse of code allows one to build complex large apps that once took months, in a matter of minutes.

In Eldr you re-use applications the Rack way. You will architect your app so it can _be mounted_ as a Rack app, then an end-developer can mount it or extend it using Rack tools.

For example, imagine a user registration/authentication app, something like Devise.

First we create our app class:

```ruby
class EldrWise
  ###
  # Registrations
  ###

  # Register a new user
  post '/user' do
    # ... user creation stuff
    redirect_to "/users/#{user.id}"
  end

  # ...  more code

  ###
  # Users
  ###
  get '/users/:id' do
    render 'users/show'
  end
end
```

We would probably want to break this up into separate controllers:

```ruby
class EldrWise::Registrations
  # ... registration routes
end

class EldrWise::Users
  # ... user routes
end

module EldrWise
  map '/registration' do
    Registrations
  end

  map '/users' do
    Users
  end
end
```

Then an end user can either mount the entire thing:

```ruby
App.extend EldrWise
run App
```

Or just a part:

```ruby
map '/users' do
  EldrWise::Users
end
run App
```

To customize it they can either extend it:

```ruby
class UsersController < EldrWise::Users
end

map '/users' do
  UsersController
end
```

If we wan to define all our controllers on the root we can use [https://github.com/eldr/eldr-cascade](eldr-cascade). We define the routes we want to override, Cascade will get a 404 on the ones we didn't, then call the next app until it gets a response:

```ruby
class App
  # override the users post route but nothing else
  post '/users' do
  end
end
run Eldr::Cascade.new[App, EldrWise]
```

Thinking about Rack when you construct your Eldr apps will make them flexible and easy to reuse.

### Using Rack inside Eldr

Eldr apps are an instance of Rack::Builder; this means we can use any middleware or other Rack apps (including other Eldr apps) inside an app. To use Rack::Builder features you call the methods on the class.

For example, to use Rack session cookies we do:

```ruby
class App < Eldr::App
  use Rack::Session::Cookie
end
```

If we wanted to mount other Eldr apps/controllers in our app we would do the following:

```ruby
class App < Eldr::App
  map '/users' do
    UsersController
  end
end
```

Because rack builder itself can take rack builder instances we can run our App in config.ru just like we expect:

```ruby
class App < Eldr::App
  use Rack::Session::Cookie
end

run App
```

### Redirecting Things

Redirects are an _enormously_ complex subject involving thousands of lines of helper code. Just kidding, they are just a status code and a new path. We can create a redirection helper in 5 lines:

```ruby
module Helpers
  def redirect(path, message)
    [302, {'location' => path}, [message]]
  end
end
```

### Route Handlers: The Power of Action Objects

In Edlr (just like in Rack) route handlers are things that respond to call. This means we can use everthing from procs, to blocks, to instances of a class.

If we wanted to we could do the following:

```ruby
class Handler
  def call(env)
    Rack::Response.new "Hi there Dave!"
  end
end

class App
  get '/', Handler.new
end
```

This isn't as silly as it might seem. Its a common and powerful pattern that can clean up
complex controllers.

Imagine we have a complex show action that takes up hundreds of lines. Our first inclination will be to split this up into different methods on our controller. This would make our show action a lot shorter; but we would have logic for our show action spread across our controller. Our other actions don't need to be able to access the show action's logic. It would be better to have all the logic for the show action in one object.

We can do this by writing our show action as an Action Object. Our action's logic will be contained entirely in this object.

Action objects give us the freedom to instantiatie them, inject things, pass them around, test and generally just engage in whatever sociopathic whimsys we might want to do to them.

Let's take a look at that show action:

```ruby
class Show
  attr_accessor :env

  def helper_logic
    # do things here
  end

  def params
    env['eldr.params']
  end

  def call(env)
    @env = env

    helper_logic
    # @cat = Cat.find params[:id]
    Rack::Response.new "Found cat named #{params['name'].capitalize}!"
  end
end

class CatsController
  get '/cats/:name', Show.new
end

run CatsController
```

Once you start using this pattern you cant stop. Like nutella, you start putting it on everything, trying it on absurd things you know are wrong -- just in case it might work well.

Don't overuse action objects, but remember they are there when you want deliciousness.

### Testing Eldr Apps

You are ready to set out on your own but you are afraid of breaking all the things. You need some safety checks to keep you from hurting yourself or your apps. Testing Eldr apps is the same as testing rack apps.

In your spec helper include rack-test. With rspec that would look like this:

```ruby
RSpec.configure do |config|
  config.include Rack::Test::Methods
end
```

Now you need to define your app method so rack-test can mount your app. Eldr apps are rack apps so we can _simply_ return a new instance of it:

```ruby
def app
  YourEldrApp.new
end
```

If you want to test each of your apps individually you can use `let` to create a new Rack::Test session thingy:

```ruby
let(:rt) do
  Rack::Test::Session.new YourEldrApp.new
end
```

Then you'll be able to access the rack-test methods from `rt`. For example:

```ruby
response = rt.get '/'
response.status.should == 200
```

Rack apps sure are easy to work with!

See the spec/ in this repo for some specific rspec examples.

## Performance

Eldr has been built with perfomance in mind. Right now it performs in the middle of the pack and more performance improvements are forthcoming:

| Framework     |  Requests/sec | % from best |
|---------------|:-------------:|------------:|
| rack          |    10282.20   |    100.0%   |
| hobbit        |     8853.81   |    86.11%   |
| roda          |     8830.00   |    85.88%   |
| cuba          |     8517.00   |    82.83%   |
| lotus-router  |     8464.81   |    82.32%   |
| rack-response |     7939.67   |    77.22%   |
| brooklyn      |     7639.88   |     74.3%   |
| *eldr*        |     7170.15   |    69.73%   |
| rambutan      |     6954.75   |    67.64%   |
| nancy         |     6516.84   |    63.38%   |
| gin           |     3850.00   |    37.44%   |
| nyny          |     3745.96   |    36.43%   |
| sinatra       |     2740.50   |    26.65%   |
| rails         |     2475.50   |    24.08%   |
| scorched      |     1692.18   |    16.46%   |
| ramaze        |     1490.42   |     14.5%   |

See the [https://github.com/eldr-rb/bench-micro](bench-micro) repo to run your own perfomance benchmarks

## Help/Resources

You can get help from the following places:

- [@k_2052](http://twitter.com/k_2052) Feel free to mention me on twitter for quick questions
- [The Mailing List](https://groups.google.com/forum/#!forum/eldr-ruby) For questions that aren't a bug or feature request
- [The examples folder](https://github.com/eldr/eldr/tree/master/examples) in this repo has full runnable versions of the quickstart's examples
- [Issues](https://github.com/eldr/eldr/issues) on this repo for bug reports and feature requests
- [The Wiki](https://github.com/eldr/eldr/wiki) has a FAQ and links to projects using Eldrg
- And of course checkout the GitHub org [eldr/](https://github.com/eldr) for all the Eldr gems.

## Contributing

1. Fork. it
2. Create. your feature branch (git checkout -b cat-evolver)
3. Commit. your changes (git commit -am 'Add Cat Evolution')
4. Test. your changes (always be testing)
5. Push. to the branch (git push origin cat-evolver)
6. Pull. Request. (for extra points include funny gif and or pun in comments)

To remember this you can use the easy to remember and totally not tongue-in-check initialism:
FCCTPP.

I don't want any of these steps to scare you off. If you don't know how to do something or are struggle getting it to work feel free to create a pull request or issue anyway. I'll be happy to help you get your contributions up to code and into the repo!

## License

Licensed under MIT by K-2052.
