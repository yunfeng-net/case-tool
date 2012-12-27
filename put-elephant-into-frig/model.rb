class Model
  @@stack = Array.new
  @@pos = 0

  def initialize(name = "")
    @name, @pos = name, @@pos
    #@@pos += 1
    @m_stm = Stm.new
    @link = Hash.new
    @linkBack = Hash.new
    @linkInPlace = Hash.new
  end

  def indent
    str = ' '*@@pos*4
    @@pos += 1
    str
  end
  def indentBack
    @@pos -= 1
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
  
  def runAspect calling
    if calling==nil then return; end
    calling.each do |x| # insert aspect
      if x.size<3
        x[0].instance_eval(x[1])
      else
        send(x[2]) {
	  x[0].instance_eval(x[1])
	}
      end
    end
  end
  
  def runCall name, *args
    @@stack.push([@name.to_s, name.to_s])
    runStm name
    if "#{name}"=="otherwise" || "#{name}".index("?")
      yield
    elsif methods.grep(/_#{name}/).size>0 
      send "_#{name}", *args
    end
    @@stack.pop
  end
  
  def method_missing(name, *args)
    if name[0]=='_'
      return
    end
    alter = (@linkInPlace[name.to_s]||[]).reverse
    org = Proc.new do
      str = indent
      puts "#{str}#{@name}.#{name}: #{args.join(' ')}"
      if name.to_s=="otherwise" || !isRecursive(name.to_s)
        runAspect @link[name.to_s]
        runCall(name,*args) { if block_given?; then yield; end }
        runAspect (@linkBack[name.to_s]||[]).reverse
      end
      indentBack
    end
    p = Proc.new { |x| x[0].instance_eval(x[1]); }
    q = Proc.new { |i|
      if i<alter.size
        if alter[i].size<3
	  p.call(alter[i])
        else
          send(alter[i][2]) {
	    p.call(alter[i])
	  }
	  send("otherwise") {
	    q.call(i+1) 
	  }
        end
      else
        org.call 
      end
    }
    # replacing call
    q.call(0) 
    #puts "#{str}\} // #{@name}.#{name}"
    #indentBack
    true
  end

  def runStm name
    if @m_stm.empty? then return end
      error = @m_stm.accept(name.to_s)
      if error && error[0]=='*'
        puts error+" when #{@name}'s  = #{@m_stm.get_current}"
      else
        puts 'STATUS("'+error+"\")"
      end
  end

  def link(method, obj, calling, cond=nil)
    @link[method.to_s] ||= []
    if cond==nil
      @link[method.to_s].push [obj, calling]
    else
      @link[method.to_s].push [obj, calling, cond]
    end
  end

  def linkBack(method, obj, calling, cond=nil)
    @linkBack[method.to_s] ||= []
    if cond==nil
      @linkBack[method.to_s].push [obj, calling]
    else
      @linkBack[method.to_s].push [obj, calling]
    end
  end

  def linkInPlace(method, obj, calling, cond=nil)
    @linkInPlace[method.to_s] ||= []
    if cond==nil
      @linkInPlace[method.to_s].clear
      @linkInPlace[method.to_s].push [obj, calling]
    else
      @linkInPlace[method.to_s].push [obj, calling, cond]
    end
  end

  def name; @name; end
  
end
