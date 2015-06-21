'use strict'

_           = require 'lodash'
path        = require 'path'
del         = require 'del'
runSequence = require 'run-sequence'
eventStream = require 'event-stream'
through     = require 'through-pipes'
gulp        = require 'gulp'
tap         = require 'gulp-tap'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglify'
htmlmin     = require 'gulp-htmlmin'
concat      = require 'gulp-concat'
jade        = require 'gulp-jade'
minifyCss   = require 'gulp-minify-css'
ngTemplates = require 'gulp-ng-templates'
sourcemaps  = require 'gulp-sourcemaps'
extReplace  = require 'gulp-ext-replace'
pkg         = require './package.json'

BANNER = """
  /*
   * #{ pkg.name }
   * #{ pkg.description }
   * @author  #{ pkg.author }
   * @version #{ pkg.version }
   * @link    #{ pkg.homepage }
   * @license #{ pkg.license }
   */

"""

# Tasks global settings
config =
  paths:
    src:
      root        : './src'
      coffee      : [
        # Ensures that index gets concatenated first
        './src/index.coffee'
        './src/**/*.coffee'
      ]
      css         : './src/**/*.css'
      templates   : './src/templates/**/*.jade'
      index       : './src/index.coffee'
    dest:
      root       : './dist'
      coffee     : './dist'
      css        : './dist'
      templates  : './dist'
      sourcemaps : './dist'

  coffee:
    filename: 'ng-table-async.js'

  css:
    filename: 'ng-table-async.css'

  templates:
    filename : 'ng-table-async-tpls.js'
    module   : 'ngTableAsync'

  minExtensions:
    js   : '.min.js'
    html : '.min.html'
    css  : '.min.css'

appendTap = (content, atStart) ->
  atStart = if _.isUndefined(atStart) then false else atStart
  tap (file, t) ->
    str  = if _.isFunction(content) then content(file) else content
    contents = [ file.contents ]

    if atStart
      contents.unshift(new Buffer str)
    else
      contents.push(new Buffer str)

    file.contents = Buffer.concat contents
    t

headerTap = (header) -> appendTap header, true
footerTap = (header) -> appendTap header

uglifyProcess = (dest, sourcemapDest) ->
  through (readable) ->
    readable
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe headerTap BANNER
    .pipe extReplace config.minExtensions.js
    .pipe sourcemaps.write path.join('./', path.relative(dest, sourcemapDest))
    .pipe gulp.dest dest

# Internal tasks
gulp.task 'css', ->
  gulp.src config.paths.src.css
  .pipe sourcemaps.init()
  .pipe concat config.css.filename
  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.css
  .pipe minifyCss()
  .pipe headerTap BANNER
  .pipe extReplace config.minExtensions.css
  .pipe sourcemaps.write path.join('./', path.relative(config.paths.dest.css, config.paths.dest.sourcemaps))
  .pipe gulp.dest config.paths.dest.css

gulp.task 'coffee', ->
  gulp.src config.paths.src.coffee
  .pipe coffee()
  .pipe concat config.coffee.filename
  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.coffee
  .pipe uglifyProcess(config.paths.dest.coffee, config.paths.dest.sourcemaps)

gulp.task 'templates', ->
  coffeeStream = gulp.src config.paths.src.coffee
  .pipe coffee()

  templatesStream = gulp.src config.paths.src.templates
  .pipe jade pretty: true
  .pipe htmlmin collapseWhitespace: true
  .pipe ngTemplates
    standalone : false,
    filename   : config.templates.filename
    module     : config.templates.module
    path       : (path, base) ->
      path.replace(base, '').replace('/templates', '')
  .pipe headerTap '(function() {\n'
  .pipe footerTap '\n}).call(this);\n'

  eventStream.merge coffeeStream, templatesStream
  .pipe concat config.templates.filename
  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.templates
  .pipe uglifyProcess(config.paths.dest.templates, config.paths.dest.sourcemaps)

# Rerun the task when a file changes
gulp.task 'watch', ->
  gulp.watch config.paths.src.coffee,    [ 'coffee' ]
  gulp.watch config.paths.src.css,       [ 'css' ]
  gulp.watch config.paths.src.templates, [ 'templates' ]

# Public tasks
gulp.task 'clean', (cb) ->
  del [ config.paths.dest.root ], cb

gulp.task 'build', [ 'coffee', 'css', 'templates' ]

gulp.task 'default', [ 'clean' ], (cb) ->
  runSequence 'build', 'watch', cb
