class Show
  def initialize(name = "", pos = 0)
    @name, @pos = name, pos
  end
  
  def indent; ' '*@pos*4; end

  def method_missing(name, *args)
    if name[0]=='_'
      return
    end
    puts "#{indent}#{@name}.#{name} "
    if methods.grep(/_#{name}/)
      send "_#{name}", *args
    end
  end
end

class User < Show
  def _act
    f = Frig.new("frig", 1)
    f.open
    f.put_elephant
    f.close
  end
end

class Frig < Show
end

user = User.new('user')
user.act