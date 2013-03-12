#!/depot/ruby-1.9.2-p180/bin/ruby

class BodyLoader
  def initialize
    @class = ""
    @member = nil
    @curClass = ""
    @curFunc = ""
  end
  
  def setMember member
    @member = member
  end
  
  def load(body, className)
    @class = className
    @curClass = ""
    @funCount = 0
    @count = Hash.new
    
    loadCode body do |line|
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
    func = /(\w+)\:\:(\w+)\(/.match(line)
    if func
      @curClass = "#{func[1]}"
      if @class==@curClass
        @curFunc = "#{func[2]}"
	@funCount += 1
      else
        @curFunc = ""
      end
      @count = Hash.new
    elsif @curFunc.size>0
      @member.each_key { |key|
        hasMember = Regexp.new(key.to_s).match(line)
        if hasMember and !@count[key.to_s]
          @member[key.to_s] += 1
	  @count[key.to_s] =1 
        end
      }
    end
  end

  def printCBO
    @member.each { |name,value|
      print "#{name} : #{value}/#{@funCount}\n"
    }
  end
end

