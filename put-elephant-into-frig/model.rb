class Model
  def initialize(name = "", pos = 0)
    @name, @pos = name, pos
    @m_stm = Stm.new
  end
  
  def indent; ' '*@pos*4; end

  def method_missing(name, *args)
    if name[0]=='_'
      return
    end
    print "#{indent}#{@name}.#{name} "
    if !@m_stm.empty?
      error = @m_stm.accept(name.to_s)
      if error && error[0]=='*'
        puts error+" when #{@name}'s  = #{@m_stm.get_current}"
      else
        puts 'STATUS("'+error+"\")"
      end
    else
      puts ""
    end
    if methods.grep(/_#{name}/)
      send "_#{name}", *args
    end
  end
end