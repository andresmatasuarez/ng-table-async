'use strict';

var app = angular.module('CustomNoDataExample', [ 'ngTableAsync' ]);

app.controller('CustomNoDataExampleController', function($scope, $q, $timeout, $window){

  // Clone data array
  var data = [];

  $scope.tableOptions = {
    pageSize   : 5,
    pagerOnTop : true,
    getPage: function(skip, limit){
      var page = data.slice(skip, skip + limit);
      return $q.all([
        data.length,
        page
      ]);
    },
    actions: {
      increment: {
        method : function(user){
          console.log('Incrementing...');
          return $scope.simulateDelay(function(){
            user.counter += 1;
          });
        },
        reload: false
      },
      remove: function(user){
        return $scope.simulateDelay(function(){
          _.remove(data, { id: user.id });
        });
      }
    }
  };


});
