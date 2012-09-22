require 'find'
require 'digest/md5'

VERBOSE = ARGV.delete('--verbose')
ROOT_DIR = ARGV[0] ||= "."

@full_paths_by_filename = {}

def md5_of_file(fullpath)
  Digest::MD5.hexdigest(File.read(fullpath))
end

def visit_file(fullpath)
  return if File.directory? fullpath
  return if File.symlink? fullpath
  basename = File.basename(fullpath)
  (@full_paths_by_filename[basename] ||= []) << fullpath
end

def print_results
  @full_paths_by_filename.select! { |filename, fullpaths| fullpaths.length >= 2 }
  if (VERBOSE)
    @full_paths_by_filename.each do |filename, fullpaths|
      puts "#{filename}:"
      for path in fullpaths do
        puts "  #{path}"
        puts "    #{md5_of_file(path)}"
      end
    end
  end
  puts "Total duped files found: #{@full_paths_by_filename.length}"
end

Find.find(ROOT_DIR) do |fullpath|
  visit_file(fullpath)
end

print_results