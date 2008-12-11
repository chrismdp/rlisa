require "enumerator"

class Candidate
  
  attr :difference, true
  attr :genestring
  
  POLYGONS = 50
  VERTEX_COUNT = 8
  POLYGON_LENGTH = VERTEX_COUNT * 2 + 4
  
  def initialize(genestring = nil)
    if genestring
      @genestring = genestring.dup
    else 
      @genestring = Array.new(POLYGONS * POLYGON_LENGTH) { rand }
    end
  end
  
  def self.procreate(mum, dad)
    genes = []
    genes = mum.genestring.dup
    start = ((rand * mum.genestring.size).to_i / (POLYGON_LENGTH*2)).to_i * POLYGON_LENGTH
    genes[start,genes.size/2] = dad.genestring[start,genes.size/2]
    baby = Candidate.new(genes)
      10.times { baby.mutate! }
    baby
  end
    
  def mutate!
    @difference = nil
    gene_to_mutate = (rand * @genestring.size).to_i
    @genestring[gene_to_mutate] = rand
    self
  end
  
  def draw
  	glClear(GL_COLOR_BUFFER_BIT)
    @genestring.each_slice(POLYGON_LENGTH) do |polystring|
      glColor4f(polystring[0], polystring[1], polystring[2], polystring[3] / 2)
      glBegin(GL_POLYGON)
      polystring[4..-1].each_slice(VERTEX_COUNT * 2) do |vs|
        vs.each_slice(2) do |xy|
        	glVertex(xy[0] * 2.0 - 1.0, xy[1] * 2.0 - 1.0)
        end
      end
    	glEnd
    end
  end
end
  