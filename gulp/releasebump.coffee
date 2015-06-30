'use strict'

###
  Based on:
    https://github.com/gulpjs/gulp/blob/master/docs/recipes/bump-version-and-create-git-tag.md

  REQUIREMENTS:
    * gulp-bump
    * gulp-git

  USAGE
    1. Include in your Gulpfile:
      gulp.task('releasebump', require('./releasebump')(gulp, plugins, settings, options));

      where:
        * 'gulp'     : Gulp module.
        * 'plugins'  : Plugins loades with gulp-load-plugins.
        * 'settings' : Configuration object with source/destination paths.
        * 'options'  : Runtime options.

    2. Run 'releasebump' task:
      gulp releasebump [--type=minor|major|patch=default]
###

fs          = require 'fs'
runSequence = require 'run-sequence'

VERSION_BUMPED     = '[Prerelease] Bumped version number.'
TAG_CREATED        = '[Release] Created tag for version: '
RELEASE_SUCCESSFUL = 'Release finished successfully!'

module.exports = (gulp, plugins, settings, options) ->
  options      = options || {}
  options.type = options.type || 'patch'

  dependenciesBeforeCommit = options.dependencies || []

  getPackageVersion = ->
    # We parse the json file instead of using require because require caches multiple calls so the version number won't be updated
    JSON.parse(fs.readFileSync settings.paths.pkg, 'utf8').version;

  gulp.task 'commit', ->
    gulp.src settings.paths.all
    .pipe plugins.git.commit VERSION_BUMPED, args: '-a'

  gulp.task 'push', (cb) ->
    plugins.git.push 'origin', 'master', cb

  gulp.task 'push-tag', (cb) ->
    version = getPackageVersion()
    plugins.git.tag version, TAG_CREATED + version, (error) ->
      return cb(error) if error
      plugins.git.push 'origin', 'master', { args: '--tags' }, cb

  gulp.task 'bump', ->
    gulp.src settings.paths.src.bump
    .pipe plugins.bump type: options.type
    .pipe gulp.dest settings.paths.dest.bump

  (cb) ->
    runSequence 'bump', dependenciesBeforeCommit, 'commit', 'push', 'push-tag', (error) ->
      if error
        console.log error.message
      else
        console.log RELEASE_SUCCESSFUL

      cb error
