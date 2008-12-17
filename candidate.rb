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
  POLYGON_LENGTH = VERTEX_COUNT * 2 + 4
  GENESTRING_LENGTH = POLYGON_LENGTH * POLYGONS
  
  def initialize(genestring = nil, &block)
    block ||= lambda { 0.5 }
    if genestring
      @genestring = genestring.dup
    else 
      @genestring = Array.new(GENESTRING_LENGTH, &block)
    end
  end
  
  def self.random_polygon_start(percentage_max = 1.0)
    (rand * POLYGONS * percentage_max).to_i * POLYGON_LENGTH
  end

  def self.procreate(mum, dad)
    genes = []
    genes = mum.genestring.dup
    percentage_to_xfer = 0.5
    polygons_to_xfer = (percentage_to_xfer * POLYGONS).to_i * POLYGON_LENGTH
    start = random_polygon_start(1.0 - percentage_to_xfer)
    genes[start, polygons_to_xfer] = dad.genestring[start, polygons_to_xfer]
    baby = Candidate.new(genes)
      1.times { baby.mutate! }
    baby
  end
    
  def mutate!
    @difference = nil
    seed = Candidate.random_polygon_start
    POLYGON_LENGTH.times do |x|
      gene_to_mutate = seed + x
      val = rand
      @genestring[gene_to_mutate] = val.ensure_bound(0.0, 1.0)
    end
    self
  end
  
  def draw
  	glClear(GL_COLOR_BUFFER_BIT)
    @genestring.each_slice(POLYGON_LENGTH) do |polystring|
      glColor4f(polystring[0], polystring[1], polystring[2], polystring[3]*0.1)
      glBegin(GL_POLYGON)
      polystring[4..-1].each_slice(VERTEX_COUNT * 2) do |vs|
        raise vs.inspect if vs.max > 1.0
        cursor = nil
        vs.each_slice(2) do |point|
          if cursor.nil?
            cursor = point
          else
            cursor[0] += gene_to_screen(point[0]) * 0.25
            cursor[1] += gene_to_screen(point[1]) * 0.25
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
  
