puts """Which folder to use?
RefSeqOnly
RefSeqPasolliMAGs"""

folder = $stdin.gets.chomp

filelist = Dir["../04-analysis/kraken/output/#{folder}/*.report.*"]

filelist.each do |filename|
  original_file = filename
  new_file = original_file + '.new'

  File.open(new_file, 'w') do |fo|
    fo.puts "Taxonomy\t#{original_file}"
    File.foreach(original_file) do |li|
      fo.puts li
    end
  end

  File.rename(original_file, original_file + '.old')
  File.rename(new_file, original_file)
end

