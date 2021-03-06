'use strict';

module.exports = {
  paths: {
    pkg: './package.json',
    all: './*',
    src: {
      root      : './src',
      css       : './src/**/*.css',
      templates : './src/templates/**/*.pug',
      index     : './src/index.coffee',
      coffee    : [ './src/index.coffee', './src/**/*.coffee' ]
    },
    dest: {
      root       : './dist',
      coffee     : './dist',
      css        : './dist',
      templates  : './dist',
      sourcemaps : './dist'
    }
  },

  coffee: {
    filename: 'ng-table-async.js'
  },

  css: {
    filename: 'ng-table-async.css'
  },

  templates: {
    filename : 'ng-table-async-tpls.js',
    module   : 'ngTableAsync'
  },

  minExtensions: {
    js   : '.min.js',
    html : '.min.html',
    css  : '.min.css'
  }
};
