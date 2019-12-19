#!/usr/bin/ruby

filelist = Dir["../00-documentation.backup/*aligned_stats.tsv"]

filelist.each do |filename|
  original_file = filename
  new_file = original_file + '.new'

  File.open(new_file, 'w') do |fo|
    fo.puts "SampleID\tQueries\tAligned"
    File.foreach(original_file) do |li|
      fo.puts li
    end
  end

  File.rename(original_file, original_file + '.old')
  File.rename(new_file, original_file)
end

