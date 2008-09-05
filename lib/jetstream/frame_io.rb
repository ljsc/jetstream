class FrameIO
  class InputBuilder
    def initialize(g)
      @g = g
    end
    
    def add(obj)
      @g.yield(obj) if obj.respond_to?(:length) and obj.length > 0
    end
  end
  
  def initialize(*args)
    unless block_given?
      @sources = args
    else
      require 'generator'  
      @sources = Generator.new {|g| yield InputBuilder.new(g) }
      
      class << @sources
        alias_method :shift, :next
        alias_method :empty?, :end?
      end
    end
    
    @io = StringIO.new(@sources.shift)
  end
  
  def read(*args)
    data = @io.read(*args)

    while @io.eof? and !@sources.empty?
      advance_source!
      more = @io.read(*args)
      data += more
    end
    
    data
  end
  
  def readline(*args)
    data = begin
      @io.readline(*args)
    rescue EOFError
      @io.read
    end

    sep = args.first || $/

    while @io.eof? and data[-1,1] != sep and !@sources.empty?
      advance_source!
      more = @io.readline(*args)
      data += more
    end
    
    data
  end
  
  def eof?
    @sources.empty? and @io.eof?
  end
    
  private
  
  def advance_source!
    @io = StringIO.new(@sources.shift)
  end
end