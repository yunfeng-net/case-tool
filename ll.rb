
class LL
  def initialize
    @rules = Hash.new
    @stack = Array.new
    @table = Hash.new
  end

  def reset(start)
    @stack = Array.new
    @stack.push(start)
    @input = nil
  end

  def is_ended
    return @stack.empty?
  end

  def feed(token)
    #puts "process ... #{token}"
    if is_ended
      puts "input is overflow"
      return
    end
    vn = @stack[0]
    if is_vt(vn)
      if token==vn
        @stack.shift
        return # success
      else
        puts "expect token #{vn} but #{token}"
      end
    end
    rule = @table[vn.to_s][token]
    if !rule || rule>=@rules[vn.to_s].size
      puts "invalid token #{token} on #{vn}.#{rule}"
      return
    end
    rules = @rules[vn.to_s][rule]
    #puts "run rule #{vn} ::= #{rules.join(', ')}"
    @stack.shift(1)
    @stack.unshift(*rules)
    #puts "stack #{@stack.join(', ')}"
    if is_vt(rules[0])
      @stack.shift(1)
      return # success
    else
      feed(token)
    end
  end

  def add_rule(vn, *rule)
    st = @rules[vn.to_s]
    if st==nil
      st = Array.new
      @rules[vn.to_s] = st
    end
    st.push(rule)
  end
  
  def is_vt(sym) 
    return sym[0]!='$'; 
  end
  
  def make_table
    first = Hash.new
    follow= Hash.new
    @rules.each_pair do |vn, rules|
      
      first[vn.to_s] = Array.new
      for x in 0..rules.size
       first[vn.to_s].push(Hash.new)
      end
      follow[vn.to_s] = Hash.new
      @table[vn.to_s] = Hash.new
    end
    ok = false
    while (!ok)
      ok = true
      @rules.each_pair do |vn, rules|	
        fir_num = 0
	first[vn.to_s].each { |x| fir_num += x.size }
	fol_num = follow[vn.to_s].size
	index = 0
        while index<rules.size
	  rule = rules[index]
          #puts "process ... #{vn} #{rule.join(', ')}"
          if(rule.size>0) # no epsilon first set
            if is_vt(rule[0])
	      first[vn.to_s][index][rule[0].to_s] = ""
	      #puts "#{vn}.#{index} FIRST #{rule.join(', ')}"
	    elsif first[rule[0].to_s] # merge all fi(A)
	      first[rule[0].to_s].each do |x|
	        x.each_key { |key| first[vn.to_s][index][key] = "" }
		#puts "#{vn} merge #{rule[0]} #{index}"
		#first[vn.to_s][index].each_key {|y| puts "M#{y}" }
	      end
	    end
          end
	  i = 0
	  while i<rule.size # follow set
	    if !is_vt(rule[i]) && i+1<rule.size
	      if is_vt(rule[i+1])
	        #puts "#{rule[i]} FOLLOW #{rule[i+1]}"
	        follow[rule[i].to_s][rule[i+1].to_s] = ""
	      else
	        follow[rule[i].to_s].merge(follow[rule[i+1].to_s])
	      end
	    elsif !is_vt(rule[i]) && i+1==rule.size
	      follow[vn.to_s].each_key do |x|
	        follow[rule[i].to_s][x] = ""
	      end
	    end
	    i += 1
	  end
	  index += 1
        end
	fir_num2 = 0
	first[vn.to_s].each { |x| fir_num2 += x.size }
	if fir_num2>fir_num || fol_num<follow[vn.to_s].size
	  #puts "FIR #{fir_num2}, FOL #{fol_num}"
	  ok = false
          # fill in table
          @rules.each_pair do |vn, rules|
            index2 = 0
            while index2<rules.size
              if first[vn.to_s][index2]
	        #puts "#{vn} FIRST #{index2}"
	        first[vn.to_s][index2].each_key do |x|
		  if !@table[vn.to_s][x]
	            @table[vn.to_s][x] = index2
		  elsif index2!=@table[vn.to_s][x] # conflict
		    puts "#{vn} conflict: #{x} #{index2} #{@table[vn.to_s][x]} "
		  end
	        end
	      end
              index2 += 1
            end
	  end
        end
      end
    end
  end

  def print
    @table.each_pair do |vn, vt|
      puts "#{vn} -> "
      vt.each_pair do |x, y|
        puts "(#{x}, #{y})"
      end
    end
  end
end

pr = LL.new
pr.add_rule("$S", "$F")
pr.add_rule("$S", "(", "$S", "+", "$F", ")")
pr.add_rule("$F", "a");

pr.make_table
pr.print

pr.reset("$S")
pr.feed("(")
pr.feed("a")
pr.feed("+")
pr.feed("a")
pr.feed(")")

if pr.is_ended
  puts "ok"
else 
  puts "no"
end
