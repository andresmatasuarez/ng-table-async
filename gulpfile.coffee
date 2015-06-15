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
ngTemplates = require 'gulp-ng-templates'
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
      templates  : './dist'
      sourcemaps : './dist'

  coffee:
    filename: 'ng-table-async.js'

  css:
    filename: 'ng-table-async.css'

  templates:
    filename : 'ng-table-async-tpls.js'
    module   : 'ngTableAsync.templates'

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
  .pipe concat config.coffee.filename
  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.coffee
  .pipe uglify()
  .pipe extReplace config.minExtensions.js
  .pipe sourcemaps.write path.join('./', path.relative(config.paths.dest.coffee, config.paths.dest.sourcemaps))
  .pipe gulp.dest config.paths.dest.coffee

gulp.task 'css', ->
  gulp.src config.paths.src.css
  .pipe concat config.css.filename
  .pipe gulp.dest config.paths.dest.root

# gulp.task 'templates', ->
#   gulp.src config.paths.src.templates
#   .pipe jade pretty: true
#   .pipe headerTap (file) -> "<script type=\"text/ng-template\" id=\"#{path.basename file.path}\">"
#   .pipe footerTap '\n</script>'
#   .pipe concat config.filenames.templates
#   .pipe gulp.dest config.paths.dest.templates
#   .pipe htmlmin
#     collapseWhitespace : true
#     processScripts     : [ 'text/ng-template' ]
#   .pipe extReplace config.minExtensions.html
#   .pipe gulp.dest config.paths.dest.templates

gulp.task 'templates', ->
  gulp.src config.paths.src.templates
  .pipe jade pretty: true
  .pipe htmlmin
    collapseWhitespace : true
  .pipe ngTemplates
    filename : config.templates.filename
    module   : config.templates.module
    path     : (path, base) ->
      path.replace(base, '').replace('/templates', '')

  .pipe headerTap BANNER
  .pipe gulp.dest config.paths.dest.templates
  .pipe extReplace config.minExtensions.js
  .pipe gulp.dest config.paths.dest.templates

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
