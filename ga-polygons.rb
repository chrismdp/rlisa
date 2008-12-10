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

  CHILDREN_COUNT = 15
  PARENT_COUNT = 5

  attr_accessor :width, :height

  def initialize(file)
    @source_image = Magick::Image.read(file).first
    @width = @source_image.columns
    @height = @source_image.rows
    @candidates = Array.new(PARENT_COUNT) { Candidate.new }
    @displayed_candidate = @candidate
    @count = 0
    @start_time = Time.now.utc.to_i
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
    file = "#{@start_time}_image_#{@count}.png"
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
    sorted = @candidates.sort_by {|c| c.difference }
    @candidates = sorted[0..PARENT_COUNT-1]
    @candidates << sorted[8] # Pick something bad also, just in case
    @count += 1
    puts "#{@count} :: #{sorted.first.difference}" if @count % 100 == 0
    write if @count % 1000 == 0
  end
  
  def setup_next_iteration
    idx = 0
    while @candidates.size < CHILDREN_COUNT do
      idx += 1
      @candidates << @candidates[idx % PARENT_COUNT].mutation!
    end
    # @candidates.each {|c| c.mutate! }
  end
  
  def iterate
    done_something = false
    @candidates.each do |c|
      if c.difference.nil?
        c.difference = difference_for(c)
        done_something = true
        break
      end
    end
    unless done_something
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
  	when ?w
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

