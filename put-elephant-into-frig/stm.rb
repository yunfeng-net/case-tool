class Stm
  def initialize
    @edges = Hash.new
    @current = '$'
  end

  def get_current; @current; end
  def empty?; @edges.empty?; end
  
  def def_edge(from, to, event)
    edges = @edges[from.to_s]
    if edges==nil
      @edges[from.to_s] = Hash.new
    end
    @edges[from.to_s][event.to_s] = to.to_s
  end

  def accept(event)
    edges = @edges[@current.to_s]
    st = nil
    if edges!=nil
      st = edges[event.to_s]
      if st!=nil
        @current = st
      end
    end
    if st==nil
      "**error** #{event} is not accepted "
    else
      st
    end
  end

end
