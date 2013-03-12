#!/depot/ruby-1.9.2-p180/bin/ruby -I.

require "HeadLoader.rb"
require "BodyLoader.rb"

if ARGV.size<3
  print " cbo.rb header body class-name  \n";
  exit(1);
end

header = ARGV[0]
body = ARGV[1]
class_name = ARGV[2]

hl = HeadLoader.new
hl.load(header,class_name)

bl = BodyLoader.new
bl.setMember hl.getMember
bl.load(body,class_name)
bl.printCBO
