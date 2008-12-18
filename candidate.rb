require "enumerator"

class Float
 def ensure_bound(min, max)
   [[self, min].max, max].min
 end
end

class Candidate
  
  attr :difference, true
  attr :genestring
  
  POLYGONS = 100
  VERTEX_COUNT = 3
  POLYGON_LENGTH = VERTEX_COUNT * 2 + 4 + 1 # 4 for color + 1 for weight
  GENESTRING_LENGTH = POLYGON_LENGTH * POLYGONS
  
  def initialize(genestring = nil, &block)
    block ||= lambda { 0.5 }
    if genestring
      @genestring = genestring.dup
    else 
      @genestring = Array.new(GENESTRING_LENGTH, &block)
    end
  end
  
  def self.random_start(percentage_max = 1.0)
    (rand * percentage_max * GENESTRING_LENGTH).to_i
  end

  def self.procreate(mum, dad)
    genes = []
    genes = mum.genestring.dup
    percentage_to_xfer = rand
    length = random_start(percentage_to_xfer)
    start = random_start(1.0 - percentage_to_xfer)
    genes[start, length] = dad.genestring[start, length]
    baby = Candidate.new(genes).mutate!
    baby
  end
    
  def mutate!
    @difference = nil
    seed = Candidate.random_start
    (GENESTRING_LENGTH/10).times do |x|
      to_change = (seed + x) % GENESTRING_LENGTH
      val = @genestring[to_change]
      val += rand * 0.25 - 0.125
      @genestring[to_change] = val.ensure_bound(0.0, 1.0)
    end
    self
  end
  
  def draw
  	glClear(GL_COLOR_BUFFER_BIT)
    orderstring = @genestring[0...POLYGONS]
  	
  	order = []
  	@genestring.each_slice(POLYGON_LENGTH) do |poly|
      order << [poly.shift, poly]
	  end
    order = order.sort_by{|a| a[0]}

  	order.each do |polyweightpair|
      poly = polyweightpair[1]
      glColor4f(poly[0], poly[1], poly[2], 1.0)
      glBegin(GL_POLYGON)
      poly[4..-1].each_slice(VERTEX_COUNT * 2) do |vs|
        cursor = nil
        vs.each_slice(2) do |point|
          if cursor.nil?
            cursor = point
          else
            cursor[0] += gene_to_screen(point[0])
            cursor[1] += gene_to_screen(point[1])
          end
      	  glVertex(gene_to_screen(cursor[0]), gene_to_screen(cursor[1]))
        end
      end
    	glEnd
    end
  end
  
  def gene_to_screen(gene)
    gene * 2.0 - 1.0
  end
end
  
