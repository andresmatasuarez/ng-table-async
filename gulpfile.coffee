'use strict'

path   = require 'path'
gulp   = require 'gulp'
coffee = require 'gulp-coffee'
gutil  = require 'gulp-util'

# Tasks paths
paths =
  src  : './src'
  dest : './dist'

# Stream processors
streamCoffee = coffee
  bare: true
.on 'error', gutil.log

# Internal tasks
gulp.task 'coffee', ->
  gulp.src path.join(paths.src, '*.coffee')
  .pipe streamCoffee
  .pipe gulp.dest paths.dest

# Public tasks
gulp.task 'build', [ 'coffee' ]
gulp.task 'default', [ 'build' ]
