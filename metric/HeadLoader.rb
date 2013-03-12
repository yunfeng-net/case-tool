#!/depot/ruby-1.9.2-p180/bin/ruby

class HeadLoader
  def initialize
    @class = ""
    @func = Hash.new
    @curClass = ""
    @member = Hash.new
  end
  
  def load header, className
    @class = className
    @curClass = ""
    
    loadCode header do |line|
      processLine line
    end

  end

  def loadCode fileName
    File.open(fileName,"r") do |file|
      while line  = file.gets
        yield(line)
      end
    end
  end

  def processLine line
    name = /^class (\w+)/.match(line)
    if !name
      if !@curClass.size; return; end
    else
      tmp = "#{name[1]}"
      if @class!=tmp
        @curClass = ""
      else
        @curClass = tmp
      end
    end
    if @curClass!=@class; return; end
    member = /[ \&\*](m_\w+)/.match(line)
    if member
      tmp = "#{member[1]}"
      @member[tmp.to_s] = 0
    end
    func = /[ \&\*](\w+)\(/.match(line)
    if func
      tmp = "#{func[1]}"
      if tmp=='if' || tmp=='for' || tmp=='while' || /_/.match(tmp)
        return;
      end
      @func[tmp.to_s] = line
    end
  end

  def getMember; return @member; end
  
  def printStat
    @member.each_pair { |key, value|
      print "#{key}\n"
    }
    print "#{@member.size}\n"
    @func.each_pair { |key, value|
      print "#{key}\n"
    }
    print "#{@func.size}\n"
  end

  def genTest
    m = 0
    @func.each_pair { |key, value|
      tok = value.split(/[ \*\&\,\(\)]/) 
      token = Array.new
      tok.each { |x| if x.size>0 && x!="\n"; token << x; end; }
      n = 0
      if token[n]=='static'; n += 1; end
      if token[n]==@class
      elsif token[n]=='void'
        n += 1
      else
        print token[n], " res#{m} = "
	m += 1
	n += 1
      end
      if "#{key}"==@class
        print "#{key} sut("
      else
        print "sut.#{key}("
      end
      n += 2 # skip name
      while n<token.size
        if "#{token[n]}"=='return'; break; end
        print "#{token[n]}"
	if n+2<token.size
	  print ", "
	end
	n += 2
      end 
      print ");\n"
    }
  end
end

