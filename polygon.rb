
class Polygon

  def random_vert
    rand * 2 - 1
  end

  def initialize
    @verts = Array.new(4) { [random_vert, random_vert] }
    @color = Array.new(4) { rand }
  end

  def draw
    glColor4f(*@color)
    glBegin(GL_POLYGON)
  	glVertex(*@verts[0])
  	glVertex(*@verts[1])
  	glVertex(*@verts[2])
  	glVertex(*@verts[3])
  	glEnd
	end
	
	def to_s
    @verts.inspect + " :: " + @color.inspect
  end
	
	def mutate!
    @verts.each do |v|
      v[0] += mutation(0.25)
      v[0] = ensure_bound(v[0],-1.0, 1.0)
      v[1] += mutation(0.25)
      v[1] = ensure_bound(v[1],-1.0, 1.0)
    end
    @color = @color.collect do |c|
      c += mutation(0.25)
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


