_ = require 'underscore'

jasmineConfig =
  src: ['build/src/**/*.js']
  options:
    template: require 'grunt-template-jasmine-istanbul'
    templateOptions:
      coverage: 'build/coverage/coverage.json'
      template: require 'grunt-template-jasmine-requirejs'
      templateOptions: requireConfig: require './require-config.json'
      report:
        type: 'lcov'
        options:
          dir: 'build/coverage/lcov'
    specs: ['build/spec/**/*.spec.js']
    helpers: [
      'bower_components/sinonjs/sinon.js'
      'bower_components/jasmine-sinon/lib/jasmine-sinon.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/jasmine-jquery/lib/jasmine-jquery.js'
      'bower_components/jasmine-expect/dist/jasmine-matchers.js'
      'build/spec/**/*.helper.js'
    ]

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-docker'
  grunt.loadNpmTasks 'grunt-gh-pages'

  grunt.loadNpmTasks 'grunt-coveralls'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'

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

    jasmine:
      normal: jasmineConfig
      live: _.extend({}, jasmineConfig, {
        options: _.extend({}, jasmineConfig.options, {
          host: 'http://localhost:9001'
          keepRunner: true
        })
      })

    coveralls:
      main:
        src: 'build/coverage/lcov/lcov.info'
        options: force: true

    copy:
      dist:
        files: [{
          cwd: 'build/src/'
          dest: 'dist/'
          expand: true
          src: ['**/*.js']
        }, {
          cwd: 'src/'
          dest: 'dist/'
          expand: true
          src: ['**/static/**/*']
        }]

    docker:
      options:
        colourScheme: 'monokai'
      oraculum:
        dest: 'docs/'
        src: [
          '*.md'
          'src/**/*.md'
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
          'docs'
        ]
        options:
          spawn: true
          interrupt: true
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
        options:
          spawn: true
          interrupt: true
      md:
        files: [
          '*.md'
          'src/**/*.md'
        ]
        tasks: ['docs']
        options:
          spawn: true
          interrupt: true
      static:
        files: ['src/**/static/**/*']
        tasks: ['copy:dist']
        options:
          spawn: true
          interrupt: true

    bump:
      options:
        push: false
        commit: false
        createTag: false
        files: ['package.json', 'bower.json']
        updateConfigs: ['pkg', 'component']

    'gh-pages':
      src: [
        'docs/**'
        'dist/**'
        'examples/**'
        'bower_components/**'
        'README.md'
        'index.html'
      ]
      options:
        message: 'Generated by grunt-gh-pages'

  grunt.registerTask 'dist', [
    'clean:dist'
    'copy:dist'
  ]

  grunt.registerTask 'build', [
    'coffeelint'
    'clean:build'
    'coffee'
    'jshint'
  ]

  grunt.registerTask 'default', [
    'build'
    'jasmine:normal'
    'clean:dist'
    'copy:dist'
    'docs'
  ]

  grunt.registerTask 'live', [
    'build'
    'connect:test'
    'jasmine:live'
    'clean:dist'
    'copy:dist'
    'docs'
    'watch'
  ]

  grunt.registerTask 'test', [
    'clean:build'
    'coffee'
    'jasmine:normal'
  ]

  grunt.registerTask 'travis', [
    'build'
    'jasmine:normal'
    'coveralls'
  ]

  grunt.registerTask 'docs', [
    'clean:docs'
    'docker'
  ]

  grunt.registerTask 'publish-docs', [
    'docs'
    'gh-pages'
  ]
