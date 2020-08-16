'use strict'

_                    = require 'lodash'
path                 = require 'path'
del                  = require 'del'
runSequence          = require 'run-sequence'
eventStream          = require 'event-stream'
minimist             = require 'minimist'
gulp                 = require 'gulp'
gulpLoadPlugins      = require 'gulp-load-plugins'
pkg                  = require './package.json'
settings             = require './gulp/settings'

options = minimist process.argv.slice(2), string: 'type'
plugins = gulpLoadPlugins()

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

appendTap = (content, atStart) ->
  atStart = if _.isUndefined(atStart) then false else atStart
  plugins.tap (file, t) ->
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

# Couldn't make this after updating dependencies
# uglifyProcess = (dest, sourcemapDest) ->
#  lazypipe()
#  .pipe plugins.ngAnnotate
#  .pipe plugins.sourcemaps.init
#  .pipe plugins.uglify
#  .pipe headerTap, BANNER
#  .pipe plugins.extReplace, settings.minExtensions.js
#  .pipe plugins.sourcemaps.write, path.join('./', path.relative(dest, sourcemapDest))
#  .pipe gulp.dest, dest

# Internal tasks
gulp.task 'css', ->
  gulp.src settings.paths.src.css
  .pipe plugins.sourcemaps.init()
  .pipe plugins.concat settings.css.filename
  .pipe headerTap BANNER
  .pipe gulp.dest settings.paths.dest.css
  .pipe plugins.cleanCss()
  .pipe headerTap BANNER
  .pipe plugins.extReplace settings.minExtensions.css
  .pipe plugins.sourcemaps.write path.join('./', path.relative(settings.paths.dest.css, settings.paths.dest.sourcemaps))
  .pipe gulp.dest settings.paths.dest.css

gulp.task 'coffee', ->
  gulp.src settings.paths.src.coffee
  .pipe plugins.coffee()
  .pipe plugins.concat settings.coffee.filename
  .pipe headerTap BANNER
  .pipe gulp.dest settings.paths.dest.coffee

  # See uglifyProcess above
  #.pipe uglifyProcess(settings.paths.dest.coffee, settings.paths.dest.sourcemaps)()
  .pipe plugins.ngAnnotate()
  .pipe plugins.sourcemaps.init()
  .pipe plugins.uglify()
  .pipe headerTap(BANNER)
  .pipe plugins.extReplace(settings.minExtensions.js)
  .pipe plugins.sourcemaps.write(path.join('./', path.relative(settings.paths.dest.coffee, settings.paths.dest.sourcemaps)))
  .pipe gulp.dest(settings.paths.dest.coffee)

gulp.task 'templates', (cb) ->
  coffeeStream = gulp.src settings.paths.src.coffee
  .pipe plugins.coffee()

  templatesStream = gulp.src settings.paths.src.templates
  .pipe plugins.pug pretty: true
  .pipe plugins.htmlmin collapseWhitespace: true
  .pipe plugins.ngTemplates
    standalone : false,
    filename   : settings.templates.filename
    module     : settings.templates.module
    path       : (path, base) ->
      path.replace(base, '').replace('/templates', '')
  .pipe headerTap '(function() {\n'
  .pipe footerTap '\n}).call(this);\n'

  eventStream.merge coffeeStream, templatesStream
  .pipe plugins.concat settings.templates.filename
  .pipe headerTap BANNER
  .pipe gulp.dest settings.paths.dest.templates

  # See uglifyProcess above
  #.pipe uglifyProcess(settings.paths.dest.templates, settings.paths.dest.sourcemaps)()
  .pipe plugins.ngAnnotate()
  .pipe plugins.sourcemaps.init()
  .pipe plugins.uglify()
  .pipe headerTap(BANNER)
  .pipe plugins.extReplace(settings.minExtensions.js)
  .pipe plugins.sourcemaps.write(path.join('./', path.relative(settings.paths.dest.templates, settings.paths.dest.sourcemaps)))
  .pipe gulp.dest(settings.paths.dest.templates)

# Rerun the task when a file changes
gulp.task 'watch', ->
  gulp.watch settings.paths.src.coffee, [ 'coffee' ]
  gulp.watch settings.paths.src.css,    [ 'css' ]
  gulp.watch [
    settings.paths.src.coffee,
    settings.paths.src.templates
  ], [ 'templates' ]

# Public tasks
gulp.task 'clean', ->
  del [ settings.paths.dest.root ]

gulp.task 'build', gulp.parallel('coffee', 'css', 'templates')

gulp.task 'default', gulp.series('clean', 'build', 'watch')
