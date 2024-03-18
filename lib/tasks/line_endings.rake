desc 'Convert line endings to unix for all files under the current directory'
task :alldos2unix do
  `find ./*`.split("\n").each do |str|
    `dos2unix #{str}`
  end
end
