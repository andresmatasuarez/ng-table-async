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

app.run(function($rootScope, $window, $q, $timeout, $document){

  $rootScope.simulateDelay = $window.simulateDelay($q, $timeout);

  $rootScope.scrollTo = function(id){
    $document.duScrollTo(angular.element('#' + id), 0, 500);
  };

});
