class Candidate
  
  attr :polygons
  attr :difference, true
  
  protected :polygons
  
  def initialize
    @polygons = Array.new(50) { Polygon.new }
  end

  def to_s
    "CANDIDATE: First poly: #{@polygons.first}"
  end

  def deep_clone
    Marshal::load(Marshal.dump(self))
  end

  def mutation!
    other = self.deep_clone.mutate!
  end
  
  def mutate!
    @difference = nil
    # mutate 10% on average
    @polygons.each { |p| p.mutate! if rand < 0.05 }
    self
  end
  
  def draw
    @polygons.each do |poly|
      poly.draw
    end
  end
  
end
  