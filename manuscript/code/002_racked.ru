class Racked
  def call(env)
    ["200",{"Content-Type" => "text/plain"}, ["Hit Me With a Que Ball!"]]
  end
end

run Racked.new
