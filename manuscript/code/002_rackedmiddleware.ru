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
