module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-less')

  grunt.initConfig
    watch:
      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee']
      less:
        files: 'src/**/*.less'
        tasks: ['less']

    coffee:
      glob_to_multiple:
        expland: true,
        #flatten: true,
        cwd: "src/coffee",
        src: ['**/*.coffee'],
        dest: 'src/js',
        ext: '.js'

    less:
      css:
        options:
          paths: ['src/less']

        files: [
          expand: true,
          cwd: 'src/less'
          src: ['*.less']
          dest: 'src/css/'
          ext: '.css'
        ]
        
