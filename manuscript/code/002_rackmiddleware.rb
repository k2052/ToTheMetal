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

