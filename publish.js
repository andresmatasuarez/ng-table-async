'use strict';

module.exports = function(){
  return {
    humaName : 'ngTableAsync',
    // the name used as title in the gh-pages (ex: 'UI.Utils')

    repoName : 'ng-table-async',
    // the repo name used in github links in the gh-pages (ex: 'ui-utils')

    inlineHTML : '',
    // The html to inline in the index.html file in the gh-pages
    // (ex: 'Hello World' or fs.readFileSync(__dirname + '/demo/demo.html'))

    inlineJS : '',
    // The javascript to inline at the end of the index.html file in the gh-pages

    js : [],
    // Array.of(String) | Function
    // The js files to use in the gh-pages, loaded after angular by default (ex: ['dist/ui-utils.js'])
    // or
    // function that returns the final array of files to load
    // (ex: function(defaultJsFiles) { return ['beforeFile.js'].concat(defaultJsFiles); })

    css : [],
    // Array.of(String),
    // The css files to use in the gh-pages

    tocopy : [],
    // Array.of(String),
    // Additional files to copy in the vendor directory in the gh-pages

    main_dist_dir : '',
    // directory used to store the main sources in the './dist' directory (ex: 'main')

    sub_dist_dir : '',
    // directory used to store the sub component sources in the './dist' directory (ex: 'sub')

    bowerData : {
      // Bower data to overwrite.
      // (ex: { name: 'my-component', main: './my-component.js' })
    },

    subcomponents : {  // Collection of sub component
      "<sub component name>" : {
        // Bower data to overwrite.
        // (ex: { name: 'my-component', main: './my-component.js' })
      }
    }
  };
};
