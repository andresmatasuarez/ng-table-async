'use strict';

var app = angular.module('ngTableAsyncPages', [
  'duScroll',
  'hljs',
  'SimpleExample',
  'CustomLoadingExample',
  'CustomNoDataExample',
  'CustomPagerExample',
  'DialogExample'
]);

app.config(function($httpProvider, $locationProvider){

  $locationProvider.html5Mode(true);

  $httpProvider.interceptors.push(function($q){
    return {
      'request': function(config){
        console.log('template', config.url);
        // config.url = config.url.replace('partials/', 'ng-table-async/partials/');
        return config;
      },
    };
  });

});

app.run(function($rootScope, $window, $q, $timeout, $document){

  $rootScope.simulateDelay = $window.simulateDelay($q, $timeout);

  $rootScope.scrollTo = function(id){
    $document.duScrollTo(angular.element('#' + id), 0, 500);
  };

});
