#!/depot/ruby-1.9.2-p180/bin/ruby

class Counter
  def initialize
    @class = ""
    @member = ""
    @curClass = ""
    @curFunc = ""
    @count = Hash.new
  end
  
  def run argv
    if argv.size<3
      print " cbo.rb : running code-file class-name member-name \n";
      exit(1);
    end
    @class = argv[1]
    @member = argv[2]
    @curClass = ""
    @funCount = 0
    
    loadCode argv[0] do |line|
      processLine line
    end

    printStat
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
    elsif @curFunc.size>0
      hasMember = Regexp.new(@member).match(line)
      if hasMember
        if !@count[@curFunc.to_s]
	  @count[@curFunc.to_s] = 1
	end
      end
    end
  end

  def printStat
    @count.each_pair { |key, value|
      print "#{key}\n"
    }
    print "#{@count.size}/#{@funCount}\n"
  end
end

counter = Counter.new
counter.run ARGV
