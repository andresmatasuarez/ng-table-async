var app = angular.module('ngTableAsync.examples.overview', [ 'ngTable', 'ngTableAsync.templates', 'ngTableAsync' ]);

var DATA = [
  { id:  1, name:  'A', counter: 0, email: 'a@mail.com' },
  { id:  2, name:  'B', counter: 0, email: 'b@mail.com' },
  { id:  3, name:  'C', counter: 0, email: 'c@mail.com' },
  { id:  4, name:  'D', counter: 0, email: 'd@mail.com' },
  { id:  5, name:  'E', counter: 0, email: 'e@mail.com' },
  { id:  6, name:  'F', counter: 0, email: 'f@mail.com' },
  { id:  7, name:  'G', counter: 0, email: 'g@mail.com' },
  { id:  8, name:  'H', counter: 0, email: 'h@mail.com' },
  { id:  9, name:  'I', counter: 0, email: 'i@mail.com' },
  { id: 10, name: 'AA', counter: 0, email: 'aa@mail.com' },
  { id: 11, name: 'BB', counter: 0, email: 'bb@mail.com' },
  { id: 12, name: 'CC', counter: 0, email: 'cc@mail.com' },
  { id: 13, name: 'DD', counter: 0, email: 'dd@mail.com' },
  { id: 14, name: 'EE', counter: 0, email: 'ee@mail.com' },
  { id: 15, name: 'FF', counter: 0, email: 'ff@mail.com' },
  { id: 16, name: 'GG', counter: 0, email: 'gg@mail.com' },
  { id: 17, name: 'HH', counter: 0, email: 'hh@mail.com' },
  { id: 18, name: 'II', counter: 0, email: 'ii@mail.com' },
  { id: 19, name: 'JJ', counter: 0, email: 'jj@mail.com' }
];

app.controller('MainController', function($scope, $q, $timeout){

  var simulatePromiseDelay = function(cb){
    var defer = $q.defer();
    $timeout(function(){
      var result = cb();
      defer.resolve(result);
    }, 2500);
    return defer.promise;
  };

  $scope.tableOptions = {
    pageSize      : 7,
    pagerOnTop    : true,
    getPage: function(skip, limit){
      var page = DATA.slice(skip, skip + limit);
      return $q.all([
        DATA.length,
        page
      ]);
    },
    actions: {
      increment: {
        method : function(user){
          console.log('Incrementing...');
          return simulatePromiseDelay(function(){
            user.counter += 1;
          });
        },
        reload: false
      },
      reset: function(user){
        console.log('Resetting...');
        return simulatePromiseDelay(function(){
          user.counter = 0;
        });
      },
      remove: {
        method : function(user){
          _.remove(DATA, { id: user.id });
        },
        dialog : {
          templateUrl : '_delete_user_confirm.html',
          params      : function(item){
            return { username: item.email };
          }
        }
      }
    }
  };


});
