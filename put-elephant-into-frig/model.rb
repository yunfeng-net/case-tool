class Model
  @@stack = Array.new

  def initialize(name = "", pos = 0)
    @name, @pos = name, pos
    @m_stm = Stm.new
    @switch = true
    @link = Hash.new
  end

  def _switch
    @switch = !@switch
  end
  
  def indent 
    str = ' '*@pos*8
    i = @@stack.size
    while i>0
      if  @@stack[i-1][0]==@name
        if str.index '*'
	  str += "  "
	else
          str += "*"
	end
	i -= 1
      else
        break
      end
    end
    str
  end
  
  def top; @@stack.length<1 ? "" : @@stack.last; end
  
  def isRecursive name
    @@stack.each do |x|
      if x[1]==name.to_s
        return true
      end
    end
    false
  end
  
  def method_missing(name, *args)
    if name[0]=='_'
      return
    end
    print "#{indent}#{@name}.#{name}: #{args.join(' ')}"
    if isRecursive(name.to_s)
      puts ""
      return
    end
    @@stack.push([@name.to_s, name.to_s])
    runStm name
    calling = @link[name.to_s]
    if calling
    calling.each do |x| # insert aspect
      x[0].instance_eval(x[1])
    end
    end
    err = 0
    if "#{name}"=="otherwise"
      err = true
      if @switch
        yield
      end    
    elsif methods.grep(/_#{name}/).size>0 
      err = send "_#{name}", *args
    elsif "#{name}".index("?")!=nil
      err = true
    end
    @@stack.pop
    err
  end

  def runStm name
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
  end

  def link(method, obj, calling)
    @link[method.to_s] ||= []
    @link[method.to_s].push [obj, calling]
  end

  def name; @name; end
  
end
