
class Polygon

  def draw
    glColor4f(rand(), rand(), rand(), 0.5)
    glBegin(GL_POLYGON)
  	glVertex(rand()*2-1, rand()*2-1)
  	glVertex(-0.5, -0.5)
  	glVertex(-0.5, 0)
  	glVertex(0.5, 0)
  	glEnd
	end
  	

end


