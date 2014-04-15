'use Strict';

var gorgonControllers = angular.module('gorgonControllers', []);

gorgonControllers.controller('UserCtrl', ['$scope', 'Users',
  function($scope, Users){
    $scope.users = Users.query();
}]);

