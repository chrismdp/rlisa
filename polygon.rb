
class Polygon

  attr :draw

  VERT_COUNT = 8

  def random_vert
    rand * 2.0 - 1.0
  end

  def initialize
    starting = [random_vert, random_vert]
    @verts = Array.new(VERT_COUNT) { [starting[0], starting[1]] }
    @color = Array.new(3) { rand }
  end

  def draw
    glColor4f(@color[0], @color[1], @color[2], 0.5)
    glBegin(GL_POLYGON)
    @verts.each do |v|
    	glVertex(*v)
    end
  	glEnd
	end
	
	def to_s
    @verts.inspect + " :: " + @color.inspect
  end
	
	def mutate!
    @verts.each do |v|
      v[0] += mutation(0.05)
      v[0] = ensure_bound(v[0],-1.0, 1.0)
      v[1] += mutation(0.05)
      v[1] = ensure_bound(v[1],-1.0, 1.0)
    end
    @color = @color.collect do |c|
      c += mutation(0.1)
      ensure_bound(c, 0.0, 1.0)
    end
	end
	
	def ensure_bound(target, min, max)
    target = [[target, min].max, max].min
  end
	
	def mutation(plus_or_minus)
    rand() * plus_or_minus * 2 - plus_or_minus
  end

end


