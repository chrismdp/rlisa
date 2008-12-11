require 'opengl'
include Gl,Glu,Glut

require 'candidate'

begin
	require "RMagick"
rescue Exception
	print "This sample needs RMagick Module.\n"
	exit
end

class GAPolygon

  POPULATION = 50
  NUMBER_TO_KEEP = 5
  NUKE_EVERY = 100

  attr_accessor :width, :height

  def initialize(file)
    @source_image = Magick::Image.read(file).first
    @width = @source_image.columns
    @height = @source_image.rows
    @candidates = Array.new(POPULATION) { Candidate.new { rand } }
    @count = 0
    @start_time = formatted_time_now
    setup_next_iteration
  end
  
  def raster_image
    pixels = glReadPixels(0, 0, @width, @height, GL_RGBA, GL_UNSIGNED_SHORT)

  	@image ||= Magick::Image.new(@width, @height)
  	@image.import_pixels(0, 0, @width, @height, "RGBA", pixels, Magick::ShortPixel)
  	@image.flip!
    @image
  end

  def write
    file = "#{@start_time}_#{formatted_time_now}_image_#{@count}.png"
    raster_image.write(file)
    puts "Written image #{file}"
  end

  def difference
    raster_image.difference(@source_image)[1]
  end	
  
  def difference_for(c)
    c.draw
    difference
  end
  
  def finish_iteration
    @candidates = @candidates.sort_by {|c| c.difference }
    @count += 1

    nuke! if @count > 0 && @count % NUKE_EVERY == 0
    puts "#{@count} :: #{@candidates.first.difference} :: #{@candidates.size}" if @count % 10 == 0
    write if @count % 1000 == 0
    @candidates.first.draw
    glFlush
  end

  def nuke!
    Range.new((@candidates.size*0.75).to_i, @candidates.size).each do |x|
      @candidates[x] = Candidate.new { rand }
    end
  end
  
  def setup_next_iteration
    idx = 0
    size = @candidates.size
    candidates = []
    POPULATION.times do
      x = (Math.log(rand/2+1.0) * size).to_i
      y = (Math.log(rand/2+1.0) * size).to_i
      candidates << Candidate.procreate(@candidates[x], @candidates[y])
    end
    # Allow first few to be cloned to the next generation
    NUMBER_TO_KEEP.times { |x| candidates << @candidates[x] }
    @candidates = candidates
  end
  
  def iterate
    done_something = false
    @candidates.each_with_index do |c, i|
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
  
  def formatted_time_now
    Time.now.utc.strftime('%Y%m%d%H%M%S')
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

