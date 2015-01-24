### Perfomance Thoughts

We can get a lot of extra perfomance by using a C extension for parsing parameters.

Hashie::Mash is fucking slow. Need to switch to own custom class.
Use method_missing to support returning nil by default. Store everything on a hash table.

Looping through the routes takes a lot of time Instance verb methods will call self.add

Need to decrease memory usage a bit.
Instead of storing router on every route we pass it to the call method.
Dropping the inheritance of Pendragon and the monkey patching should help too.

Rack::Response is also slow. In the real world Rack::Response is used constantly;
so we cant expect to be any faster than it. The solution is to improve it's speed.
