'use strict';

var app = angular.module('ngTableAsyncPages', [
  'hljs',
  'OverviewExample',
  'SimpleExample',
  'CustomLoadingExample',
  'CustomNoDataExample'
]);

app.run(function($rootScope, $window, $q, $timeout){

  $rootScope.simulateDelay = $window.simulateDelay($q, $timeout);

});
