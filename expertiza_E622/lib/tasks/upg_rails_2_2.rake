# Based on the script http://gist.github.com/99535
# Extended for Expertiza

namespace :upg_rails_2_2 do
  desc "Checks Expertiza and warns you if you are using deprecated code."
  task :deprecated => :environment do
    deprecated = {
      '@params'                 => 'Use params[] instead',
      '@session'                => 'Use session[] instead',
      '@flash'                  => 'Use flash[] instead',
      '@request'                => 'Use request[] instead',
      '@env'                    => 'Use env[] instead',
      'find_all[^_]'            => 'Use find(:all) instead',
      'find_first[^_]'          => 'Use find(:first) instead',
      'render_.*\b'             => 'Use render (:partial, :text, etc.) instead of render_*',
      'component'               => 'Use of components are frowned upon',
      'paginate'                => 'The default paginator is slow. Writing your own may be faster',
      'start_form_tag'          => 'Use form_for instead',
      'end_form_tag'            => 'Use form_for instead',
      ':post => true'           => 'Use :method => :post instead',
      'auto_complete'           => 'is now a plugin',
      'acts_as_.*\b'            => 'many of the built-in acts_as features are now plugins; check them',
      'builder'                 => 'is now a plugin',
      'in_place_editor'         => 'is now a plugin',      
      'redirect_to_url'         => 'use redirect_to instead',
      ':dependent => true'      =>  'use :dependent => :destroy',
      ':exclusively_dependent'  => 'use :dependent => :delete_all',
      'push_with_attributes'    => 'use has_many :through',
      'count_by'                => 'use count(column_name, options)',
      'human_attribute_name'    => 'use .humanize',
      'img_tag'                 => 'make sure image tags include extensions',
      'radio_button_tag'        => 'behavior has changed with Rails 2; check docs', 
      'TzTime'                  => 'use built-in Active record Time.zone and drop tztime plugins'
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

    deprecated_reg_exp = {
      '<%= form_tag ... %>'       => "<%=[\\ ]\\{0,1\\}form_tag\\(.*\\)[\\ ]\\{0,1\\}%>/<% form_tag\\1do %>",
      '<%= start_form_tag ... %>' => "<%=[\\ ]\\{0,1\\}start_form_tag\\(.*\\)[\\ ]\\{0,1\\}%>/<% form_tag\\1do %>",
      '<%= end_form_tag %>'       => "<%=[\\ ]\\{0,1\\}end_form_tag[\\ ]\\{0,1\\}%>/<% end %>",
      ':post => true'             => ":post => true/:method => :post"
    }

    puts 'Replacing deprecated code by new code ...'
    puts

    deprecated_reg_exp.each do |key, reg_exp|
      puts "Looking for files with the deprecated '#{key}' code pattern"
      replacements = 0
      Dir.glob('app/views/**/*.erb').each do |file|
        result = `sed -n 's/#{reg_exp}/p' < #{file}`
        unless result.empty?
          `sed -i 's/#{reg_exp}/' #{file}`
          replacements += 1
          puts "\t#{file}"
        end
      end
      puts "The '#{key}' code pattern has been replaced #{replacements} times"
      puts
    end
  end
end