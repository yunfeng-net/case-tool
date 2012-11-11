class User
  def act
    f = Frig.new
    f.open
    f.put_elephant
    f.close
  end
end

class Frig
  def indent; ' '*4; end
  
  def method_missing(name, *args)
    if name[0]=='_'
      return
    end
    puts "#{indent}Frig.#{name} "
  end
end

user = User.new
user.act