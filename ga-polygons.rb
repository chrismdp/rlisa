require 'opengl'
include Gl,Glu,Glut

require 'polygon'
require 'candidate'

begin
	require "RMagick"
rescue Exception
	print "This sample needs RMagick Module.\n"
	exit
end

class GAPolygon

  attr_accessor :width, :height

  def initialize(file)
    @source_image = Magick::Image.read(file).first
    @width = @source_image.columns
    @height = @source_image.rows
    @candidate = Candidate.new
    @displayed_candidate = @candidate
    @count = 0
    setup_next_iteration
  end
  
  def raster_image
    pixels = glReadPixels(0, 0, @width, @height, GL_RGBA, GL_UNSIGNED_SHORT)

  	image = Magick::Image.new(@width, @height)
  	image.import_pixels(0, 0, @width, @height, "RGBA", pixels,Magick::ShortPixel)
  	image.flip!
    image
  end

  def draw(c)
  	glClear(GL_COLOR_BUFFER_BIT)
    c.draw
    glFlush
  end

  def write
    file = "image_#{@count}.png"
    raster_image.write(file)
    puts "Written image #{file}"
  end

  def difference
    raster_image.difference(@source_image)[1]
  end	
  
  def difference_for(c)
    draw(c)
    difference
  end
  
  def finish_iteration
    min = 1000000.0
    min_idx = 0
    @differences.each_with_index do |d, idx|
      if d < min
        min = d
        min_idx = idx
      end
    end
    @candidate = @candidates[min_idx]
    @count += 1
    puts "#{@count} :: #{min}"
  end
  
  def setup_next_iteration
    @candidates = [@candidate]
    10.times { @candidates << @candidate.mutation! }
    @differences = []
  end
  
  def iterate
    next_to_do = @differences.size
    @differences << difference_for(@candidates[next_to_do])
    if (@differences.size == @candidates.size)
      finish_iteration
      setup_next_iteration
    end
  end
end

@ga = GAPolygon.new(ARGV[0])
  
display = lambda do
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
  @ga.iterate
end

keyboard = lambda do |key, x, y|
	case (key)
		when ?\e
  		exit(0);
  	when ?\r
  	  @ga.write
	end
end

#  Main Loop
#  Open window with initial window size, title bar, 
#  color index display mode, and handle input events.
glutInit
glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_ALPHA)
glutInitWindowSize(@ga.width, @ga.height)
glutInitWindowPosition(100, 100)
glutCreateWindow($0)
glutDisplayFunc(display)
glutKeyboardFunc(keyboard)
glutIdleFunc(display)
glutMainLoop

