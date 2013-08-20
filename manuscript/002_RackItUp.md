# Rack It Up

Rack is ubiquitous through the ruby community. We use it to build all our frameworks, our webservers
integrate with it, we even emulate it for other stuff ([faraday](fararady_link)).
Few of us know how it works beyond the basics, `app.call(env)` right? It's just not worth our time,
it works, why bother digging in? It's a perfect layer of abstraction almost as solid as Ruby itself,
something we ignore, something that is just there. But what would happen if we knew how it worked?
How would we change as a developer? What would the knowledge do to us? Well for starters,
we might know how to build things like Faraday. Or when we move to other languages we will know
how to build Rack. We can become better creators. Not bound by the platform, knowledge will set us free.
Give us more opportunities. It increases our serendipity surface area.

First lets start with learning Rack by playing with it. Once we know Rack, what makes it tick,
what it does, how it responds, how it shifts and gravitates toward certain things; we can then start
to look into it's innards. Like a surgeon we must learn our patient before we cut it open. Learn the outs
before the innards.

## What Rack Does

Lets see here where to start? Nothing is better than getting our hands dirty with an example.

Look below:

```ruby
class Racked
  def call(env)
    ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!"]]
  end
end

run Racked.new
```

Delight:

	You may notice that we are wrapping the string `"Hit Me With a Que Ball!"` with array tags.
	This is due to changes in ruby 1.9, strings are no longer iteratable, i.e no each. 
	To see this in action lets boot up irb.

	```sh
	irb
	```

	Create two vars:

	```ruby
		good = ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!"]]
		bad  = ["200",{"Content-Type" => "text/plain"}, "Hit Me With a Que Ball!"]
	```
  
  Then inspect:

	```ruby
		good[2].each
		bad[2].each
	```

	The first (good var) will return:

	```sh
		#<Enumerator: ["Hit Me With a Que Ball!"]:each>
	```

	The second (bad var) will return:

	```sh
		NoMethodError: undefined method `each' for "Hit Me With a Que Ball!":String
	```

	If we don't add the array tags around the response string we will get:

  ```sh
		ERROR Rack::Lint::LintError: Response body must respond to each
	```

	Why does the response body need to be iteratable? Oh down the rabbit hole we go my friend.

	First up lets see what happens when we add two strings to our response:

	```ruby
	class Racked
	  def call(env)
	    ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!", "Oh gosh, no!"]]
	  end
	end

	run Racked.new
	```

	Run it:

	```sh
	rackup racked.ru
	```

	When we visit `http://localhost:9292` we now get:

	```
	Hit Me With a Que Ball!Oh gosh, no!
	```

	Oh so it can join multiple response bodies at once. Why and how does it do this?
	Well so it can stream of course. How and why this works. Is a bit beyond the scope for this
	section but we will get to it later, don't you worry.

This is pretty clear. Our app class `Racked` has a call method which takes an env param and returns an array.
The app is mounted by calling run. Save this as `racked.ru` and then boot it up with:

```sh
rackup racked.ru
```

If all goes well we will get back:

```sh
[2013-04-25 10:04:54] INFO  WEBrick 1.3.1
[2013-04-25 10:04:54] INFO  ruby 1.9.3 (2013-02-22) [x86_64-linux]
[2013-04-25 10:04:54] INFO  WEBrick::HTTPServer#start: pid=20319 port=9292
```

When we visit localhost:9292 we get:

```
Hit Me With a Que Ball!
```

So now what? Do we sit up an say "I know Rack!" or do we go further down the rabbit hole. Further down
my friend. All the way down. We won't stop until we hit metal.

## Middleware

Central to Rack is the concept of middleware. Rack apps are meant to be chained. Like a Zebra
wants to run, or a ocelot wants to scratch Archer, a rack app is meant to be connection. These connections
are called middleware. How does middleware work you ask? It's simple really.

By returing the same thing in every request it's easy to chain the apps together. All middleware 
responds just like a rack app it as has `call(env)` method that returns a status sting, headers and body response
array. Each rack middleware is called in turn until the chain is complete. 

It looks like this:

```ruby
module Rack
  class Cats
    def initialize(app)
      @app = app
    end
     
    def call(env)
      status, headers, response= @app.call(env)
      [status, headers, ["<div class='cats'>#{response}</div>"]]
    end
  end
end
```

The only difference between Rack middleware and a Rack app (i'm generalizing here) is that Rack
middleware takes an app in it's `initialize(app)` method. Like this:

```ruby
class Cats
  def initialize(app)
    @app = app
  end
end
```

Then we want the env for the request we call the app like so:

```ruby
status, headers, response= @app.call(env)
```

Delight:
	This utilizes ruby's ability to turn a returned array into vars. It looks a lot, exactly a lot, like this:

  ```ruby 
	cats, dogs = ['gods', 'friends'] # => cats = 'gods'; dogs = 'friends'
	cats, dogs = 'gods', 'friends'   # => cats = 'gods'; dogs = 'friends'
	cats, dogs = 'gods'              # => cats = 'gods'; dogs = nil
	```

	This has a key useful use cases like names for example:

  ```ruby
	name = 'John, Galt'

	firstname, lastname = name.split(',').join(' ').split # => firstname = 'John'; lastname = 'Galt'
	```
 
Now how do we tell Rack to use these things? It's called Rack::Builder and it's going to be your
best friend. You'll make chains together, play together, and rack things together. To use it is simple

```ruby
module Rack
  class Cats
    def initialize(app)
      @app = app
    end
     
    def call(env)
      status, headers, response= @app.call(env)
      [status, headers, ["<div class='cats'>#{response}</div>"]]
    end
  end
end

use Rack::Cats

class Racked
  def call(env)
    ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!"]]
  end
end

run Racked.new
```

Boot it up using rackup and then visit in the browser you should get back:

```
<div class='cats'>["Hit Me With a Que Ball!"]</div>
```

What is happening here?

1. Rack loads up the middleware and then the app.
2. Rack executes starting with the app, then to the middleware, building up the response along the way.
   Ultimately queuing this up in a variable for final output, for brevity's sake will call this the body.
3. Finally each is called on every item in the body and the final response built.
4. The response is returned.

No the third point in this cycle opens up a few neat possibilities. Namely, overriding each to do cool shit. Lets see an example:

```ruby
class RackWrap
  def initialize(app)
    @app = app
  end
 
  def call(env)
    status, headers, @response = @app.call(env)
    [status, headers, self]
  end
 
  def each(&block)
    block.call('<div class="cats">')
    @response.each(&block)
    block.call('</div>'')
  end
end

use RackWrap

class Racked
  def call(env)
    ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!"]]
  end
end

run Racked.new
```

This wraps everything in a div class cats just like before but in a different manner. Not too interesting in this case, but the importance of patterns is their potential for when things get complicated. Lets move on into how Rack works with a server, will come back to Rack itself in a bit.
