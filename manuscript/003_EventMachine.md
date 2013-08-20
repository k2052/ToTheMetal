# Events Events Oh My

Before we can dive seriously into the realm of EventMachine and servers we are first going to have 
to get our hands dirt in the realm of event driven programming. EventMachine uses at it's core 
the reactor pattern. I'll let wikipedia define it for you:

```
The reactor design pattern is an event handling pattern for handling service requests delivered concurrently to a service handler by one or more inputs. The service handler then demultiplexes the incoming requests and dispatches them synchronously to the associated request handlers.[1]
```

That clears everything up, we can probably just jump in right away. It's funny how most definitions 
are only really useful if you already know what the hell it is talking about. To quote about 
reactor programming one must already know reactor programming. So, lets learn reactor programming.

To understand reactor programming we must first understand what a multiplexer is. Multiplex is an
old term carried over from electronics/signal prcessing era of computing. Back in the day when the lines between digital and analog were blurry. A multiplexer takes multiple inputs/signals and converts them into one. Inverserely, a
demultiplexer takes one input and makes multiple outputs.

In the non-evented world everything is executed sequentially. Do this then that then that. Like a penguin
march it happens one after the other. Penguin marching like non-evented io
happens in a organized single-file fashion. Unfortunately, when you go single file, it's easy for things to get blocked. Maybe you have a fat penguin, maybe a penguin broke a flipper, maybe a fight broke out between to lover penguins; "Single files are best for singles." one never knows. The trick is to take this single file and break it out
into multiple files. The slow penguins can take their time and the fast penguins get moving.

Blocking code looks like this:

```ruby [Change this to something original]
response1 = Net::HTTP.get_response(uri1)
puts response1.code
puts response1.body

response2 = Net::HTTP.get_response(uri2)
puts response2.code
puts response2.body

response3 = Net::HTTP.get_response(uri3)
puts response3.code
puts response3.body
```

Non blocking code looks like this:

```rub [Replace]
request1 = EM::MadeUpHTTP.get(uri1)
request1.callback do |response1|
  puts response1.code
  puts response1.body
end

request2 = EM::MadeUpHTTP.get(uri2)
request2.callback do |response2|
  puts response2.code
  puts response2.body
end

request3 = EM::MadeUpHTTP.get(uri3)
request3.callback do |response|
  puts response3.code
  puts response3.body
end
```

A reactor starts with a loop (like a nuclear reactor) and it runs and runs and runs until things happen.