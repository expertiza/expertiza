module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'), // the package file to use
 
    react: {
      single_file_output: {
        files: {
          'public/js/react-bootstrap-treeview.js': 'src/react-bootstrap-treeview.jsx'
        }
      }
    },

    watch: {
      files: [/*'tests/*.js', 'tests/*.html', */'src/**'],
      tasks: ['default']
    },

    copy: {
      main: { 
        files: [
          // copy src to example
          { expand: true, cwd: 'src/', src: '*.css', dest: 'public/css/' },
          // { expand: true, cwd: 'src/js', src: '*', dest: 'public/js/' }
        ]
      }
    }
  });

  // load up your plugins
  grunt.loadNpmTasks('grunt-react');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');

  // register one or more task lists (you should ALWAYS have a "default" task list)
  grunt.registerTask('default', ['react', 'copy', 'watch']);
};
