# Based on the script http://gist.github.com/99535
# Extended for Expertiza

namespace :upg_rails_2_2 do
  desc "Checks Expertiza and warns you if you are using deprecated code."
  task :deprecated => :environment do
    deprecated = {
      '@params'    => 'Use params[] instead',
      '@session'   => 'Use session[] instead',
      '@flash'     => 'Use flash[] instead',
      '@request'   => 'Use request[] instead',
      '@env' => 'Use env[] instead',
      'find_all[^_]'   => 'Use find(:all) instead',
      'find_first[^_]' => 'Use find(:first) instead',
      'render_.*\b' => 'Use render (:partial, :text, etc.) instead of render_*',
      'component'  => 'Use of components are frowned upon',
      'paginate'   => 'The default paginator is slow. Writing your own may be faster',
      'start_form_tag'   => 'Use form_for instead',
      'end_form_tag'   => 'Use form_for instead',
      ':post => true'   => 'Use :method => :post instead',
      'auto_complete' => 'is now a plugin',
      'acts_as_.*\b' => 'many of the built-in acts_as features are now plugins; check them',
      'builder' => 'is now a plugin',
      'in_place_editor' => 'is now a plugin',      
      'redirect_to_url' => 'use redirect_to instead',
      ':dependent => true' =>  'use :dependent => :destroy',
      ':exclusively_dependent' => 'use :dependent => :delete_all',
      'push_with_attributes' => 'use has_many :through',
      'count_by' => 'use count(column_name, options)',
      'human_attribute_name' => 'use .humanize',
      'img_tag' => 'make sure image tags include extensions',
      'radio_button_tag' => 'behavior has changed with Rails 2; check docs', 
      'TzTime' => 'use built-in Active record Time.zone and drop tztime plugins'
    }

    deprecated.each do |key, warning|
      puts '--> ' + key
      output = `cd '#{File.expand_path('app', RAILS_ROOT)}' && grep -n --exclude=*.svn* -r '#{key}' *`
      unless output =~ /^$/
        puts "  !! " + warning + " !!"
        puts '  ' + '.' * (warning.length + 6)
        puts output
      else
        puts "  Clean! Cheers for you!"
      end
      puts      
    end
    
    puts 'Some configuration items to be aware of:'
    puts
    puts 'Check your config environments for: config.action_view.cache_template_extensions, and remove.'
    puts 'ActionView::Base is now ActionView::Template'
    
  end

  desc 'Renames (with SVN) all .rhtml views to .html.erb, .rjs to .js.rjs, .rxml to .xml.builder, and .haml to .html.haml'
  task :svn_rename do

    Dir.glob('app/views/**/*.rhtml').each do |file|
      puts `svn move #{file} #{file.gsub(/\.rhtml$/, '.html.erb')}`
    end

    Dir.glob('app/views/**/[^_]*.rxml').each do |file|
      puts `svn move #{file} #{file.gsub(/\.rxml$/, '.xml.builder')}`
    end

    Dir.glob('app/views/**/[^_]*.rjs').each do |file|
      puts `svn move #{file} #{file.gsub(/\.rjs$/, '.js.rjs')}`
    end

    Dir.glob('app/views/**/[^_]*.haml').each do |file|
      puts `svn move #{file} #{file.gsub(/\.haml$/, '.html.haml')}`
    end

  end

  desc 'Fixes the files that have deprecated code'
  task :update_deprecated_code do
    end_form_tag = 0
    start_form_tag = 0
    form_tag = 0

    puts 'Replacing old "start_form_tag", "form_tag" and "end_form_tag" tags ...'

    Dir.glob('app/views/**/*.erb').each do |file|
      form_tag_reg_exp = "<%=[\\ ]\\{0,1\\}form_tag\\(.*\\)[\\ ]\\{0,1\\}%>/<% form_tag\\1do %>"
      form_tag_result = `sed -n 's/#{form_tag_reg_exp}/p' < #{file}`
      unless form_tag_result.empty?
        `sed -i 's/#{form_tag_reg_exp}/' #{file}`
        form_tag += 1
        puts "\tform_tag: #{file}"
      end

      start_form_tag_reg_exp = "<%=[\\ ]\\{0,1\\}start_form_tag\\(.*\\)[\\ ]\\{0,1\\}%>/<% form_tag\\1do %>"
      start_form_tag_result = `sed -n 's/#{start_form_tag_reg_exp}/p' < #{file}`
      unless start_form_tag_result.empty?
        `sed -i 's/#{start_form_tag_reg_exp}/' #{file}`
        start_form_tag += 1
        puts "\tstart_form_tag: #{file}"
      end

      end_form_tag_reg_exp = "<%=[\\ ]\\{0,1\\}end_form_tag[\\ ]\\{0,1\\}%>/<% end %>"
      end_form_tag_result = `sed -n 's/#{end_form_tag_reg_exp}/p' < #{file}`
      unless end_form_tag_result.empty?
        `sed -i 's/#{end_form_tag_reg_exp}/' #{file}`
        end_form_tag += 1
        puts "\tend_form_tag: #{file}"
      end
    end

    puts "<%= start_form_tag ... %> has been replaced by <% <% form_tag ... do %> %> #{start_form_tag} times"
    puts "<%= form_tag ... %> has been replaced by <% <% form_tag ... do %> %> #{form_tag} times"
    puts "<%= end_form_tag %> has been replaced by <% end %> #{end_form_tag} times"
  end
end