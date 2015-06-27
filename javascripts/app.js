'use strict';

var app = angular.module('ngTableAsyncPages', [
  'hljs',
  'OverviewExample',
  'SimpleExample',
  'CustomLoadingExample',
  'CustomNoDataExample'
]);

app.config(function($locationProvider){

  $locationProvider.html5Mode({
    enabled: true,
    rewriteLinks: false
  });

});

app.run(function($rootScope, $window, $q, $timeout){

  $rootScope.simulateDelay = $window.simulateDelay($q, $timeout);

});
