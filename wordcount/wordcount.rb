#!/usr/bin/env ruby

#Change rootDir to the location of your newsgroup files
rootDir = "/tmp/20_newsgroups"
#rootDir = "/tmp/mini_newsgroups"
raise rootDir + " does not exist" unless File.directory? rootDir

#Iterates over all files under rootDir, opens each one and passes it to the block
def files(rootDir)
  Dir.foreach(rootDir) do |dir|
    if dir != "." && dir != ".."
      puts "Processing " + dir
      Dir.foreach(rootDir + "/" + dir) do |file|
        if file != "." && file != ".."
          open(rootDir + "/" + dir + "/" + file) do |f|
            yield(f)
          end
        end
      end
    end
  end
end

t1 = Time.now
counts = Hash.new(0) #0 will be the default value for non-existent keys
files(rootDir) do |file|
  file.read.scan(/\w+/) { |word| counts[word.downcase] += 1 }
end

puts "Writing counts in decreasing order"
open("counts-descreasing-ruby", "w") do |out|
  counts.sort { |a, b| b[1] <=> a[1] }.each { |pair| out << "#{pair[0]}\t#{pair[1]}\n" }
end

puts "Writing counts in alphabetical order"
open("counts-alphabetical-ruby", "w") do |out|
  counts.sort { |a, b| a[0] <=> b[0] }.each { |pair| out << "#{pair[0]}\t#{pair[1]}\n" }
end

t2 = Time.now
puts "Finished in " + (t2 - t1).to_s + " seconds"

