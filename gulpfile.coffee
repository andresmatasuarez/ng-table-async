'use strict'

_           = require 'lodash'
path        = require 'path'
del         = require 'del'
runSequence = require 'run-sequence'
gulp        = require 'gulp'
tap         = require 'gulp-tap'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglify'
htmlmin     = require 'gulp-htmlmin'
concat      = require 'gulp-concat'
jade        = require 'gulp-jade'
sourcemaps  = require 'gulp-sourcemaps'
extReplace  = require 'gulp-ext-replace'
pkg         = require './package.json'

BANNER = """
  /**
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
      root     : './src'
      coffee   : './src/**/*.coffee'
      partials : './src/partials/**/*.jade'
    dest:
      root       : './dist'
      coffee     : './dist'
      partials   : './dist'
      sourcemaps : './dist'

  filenames:
    partials: 'templates.html'

  minExtensions:
    js   : '.min.js'
    html : '.min.html'

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
footerTap = (footer) -> appendTap footer

# Internal tasks
gulp.task 'coffee', ->
  gulp.src config.paths.src.coffee
  .pipe sourcemaps.init()
  .pipe coffee()
  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.coffee
  .pipe uglify()
  .pipe extReplace config.minExtensions.js
  .pipe sourcemaps.write path.join('./', path.relative(config.paths.dest.coffee, config.paths.dest.sourcemaps))
  .pipe gulp.dest config.paths.dest.coffee

gulp.task 'partials', ->
  gulp.src config.paths.src.partials
  .pipe jade pretty: true
  .pipe headerTap (file) -> "<script type=\"text/ng-template\" id=\"#{path.basename file.path}\">"
  .pipe footerTap '\n</script>'
  .pipe concat config.filenames.partials
  .pipe gulp.dest config.paths.dest.partials
  .pipe htmlmin
    collapseWhitespace : true
    processScripts     : [ 'text/ng-template' ]
  .pipe extReplace config.minExtensions.html
  .pipe gulp.dest config.paths.dest.partials

# Public tasks
gulp.task 'clean', (cb) ->
  del [ config.paths.dest.root ], cb

gulp.task 'build', [ 'coffee', 'partials' ]

gulp.task 'default', (cb) ->
  runSequence 'clean', 'build', cb
