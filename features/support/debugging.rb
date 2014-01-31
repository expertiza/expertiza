puts "debugging.rb is loading"
After do |scenario|
  if scenario.status == :failed
    puts "starting save_and_open_page"
    save_and_open_page
  end
end
