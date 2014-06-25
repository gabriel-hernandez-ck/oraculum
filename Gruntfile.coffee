_ = require 'underscore'

jasmineConfig =
  src: ['build/src-cov/**/*.js']
  options:
    template: require 'grunt-template-jasmine-requirejs'
    templateOptions: requireConfig: require './require-config.json'
    specs: [
      'build/spec/**/*.helper.js'
      'build/spec/**/*.spec.js'
    ]
    helpers: [
      'components/sinon/lib/sinon.js'
      'components/sinon/lib/sinon/spy.js'
      'components/sinon/lib/sinon/**/*.js'
      'components/jasmine-sinon/lib/jasmine-sinon.js'
      'components/jasmine-jquery/lib/jasmine-jquery.js'
      'components/jasmine-matchers-util/jasmine-matchers-1.3.0.js'
      'components/jasmine-matchers/src/to*.js'
    ]

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-docker'
  grunt.loadNpmTasks 'grunt-blanket'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'


  grunt.initConfig
    pkg: require './package.json'
    component: require './bower.json'

    clean:
      docs  : ['docs/']
      dist  : ['dist/']
      build : ['build/']
      spec  : ['build/spec/']

    coffeelint:
      source: 'src/**/*.coffee'
      grunt: 'Gruntfile.coffee'
      options:
        max_line_length:
          level: 'ignore'

    coffee:
      src:
        expand: true
        flatten: false
        cwd: 'src/'
        src: ['**/*.coffee']
        dest: 'build/src/'
        ext: '.js'
      spec:
        expand: true
        flatten: false
        cwd: 'spec/'
        src: ['**/*.spec.coffee']
        dest: 'build/spec/'
        ext: '.spec.js'
      helper:
        expand: true
        flatten: false
        cwd: 'spec/'
        src: ['**/*.helper.coffee']
        dest: 'build/spec/'
        ext: '.helper.js'

    jshint:
      all: ['build/src/**/*.js']
      options:
        boss: true
        expr: true
        eqnull: true
        shadow: true
        newcap: false

    blanket:
      instrument:
        files:
          'build/src-cov/': ['build/src/']

    jasmine:
      normal: jasmineConfig
      live: _.extend({}, jasmineConfig, {
        options: _.extend({}, jasmineConfig.options, {
          host: 'http://localhost:9001'
          styles: ['lib/jscoverage/jscoverage.css']
          outfile: 'specs.html'
          keepRunner: true
          helpers: [].concat(jasmineConfig.options.helpers)
            .concat(['lib/jscoverage/jscoverage.js'])
        })
      })

    copy:
      dist:
        files: [{
          cwd: 'build/src/'
          dest: 'dist/'
          expand: true
          src: ['**/*.js']
        }]

    docker:
      options:
        colourScheme: 'monokai'
      oraculum:
        dest: 'docs/'
        src: [
          '*.md'
          'src/**/*.coffee'
        ]

    connect:
      test:
        options:
          port: 9001
          keepalive: Boolean grunt.option 'keepalive'

    watch:
      src:
        files: ['src/**/*.coffee']
        tasks: [
          'build'
          'jasmine:live'
          'clean:dist'
          'copy:dist'
        ]
      spec:
        files: [
          'spec/**/*.spec.coffee'
          'spec/**/*.helper.coffee'
        ]
        tasks: [
          'clean:spec'
          'coffee:spec'
          'coffee:helper'
          'jasmine:live'
        ]
      md:
        files: ['*.md']
        tasks: ['docs']

    bump:
      options:
        push: false
        commit: false
        createTag: false
        files: ['package.json', 'bower.json']
        updateConfigs: ['pkg', 'component']

  grunt.registerTask 'build', [
    'coffeelint'
    'clean:build'
    'coffee'
    'jshint'
    'blanket'
    'docs'
  ]

  grunt.registerTask 'default', [
    'build'
    'jasmine:normal'
    'clean:dist'
    'copy:dist'
  ]

  grunt.registerTask 'live', [
    'build'
    'connect:test'
    'jasmine:live'
    'clean:dist'
    'copy:dist'
    'watch'
  ]

  grunt.registerTask 'test', [
    'clean:build'
    'coffee'
    'blanket'
    'jasmine:normal'
  ]

  grunt.registerTask 'docs', [
    'clean:docs'
    'docker'
  ]
