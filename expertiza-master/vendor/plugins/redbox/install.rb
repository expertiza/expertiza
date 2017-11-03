# Install hook code here

require 'ftools'

plugins_dir = File.expand_path(".")
redbox_dir = File.join(plugins_dir, 'redbox')
root_dir = File.join(redbox_dir, '..', '..', '..')

File.copy File.join(redbox_dir, 'javascripts', 'redbox.js'), File.join(root_dir, 'public', 'javascripts', 'redbox.js')
File.copy File.join(redbox_dir, 'stylesheets', 'redbox.css'), File.join(root_dir, 'public', 'stylesheets', 'redbox.css')
File.copy File.join(redbox_dir, 'images', 'redbox_spinner.gif'), File.join(root_dir, 'public', 'images', 'redbox_spinner.gif')