'use strict';

var gulp = require('gulp');

// ACCESS TO THE ANGULAR-UI-PUBLISHER
function targetTask(task){
  return function(done){

    var spawn = require('child_process').spawn;
    var path = require('path');

    spawn(path.resolve(process.cwd(), './node_modules/.bin/gulp'), process.argv.slice(2), {
      cwd : './node_modules/angular-ui-publisher',
      stdio: 'inherit'
    }).on('close', done);
  }
}


gulp.task('build', targetTask('build'));
gulp.task('publish', targetTask('publish'));
