'use Strict';

var gorgonControllers = angular.module('gorgonControllers', []);

gorgonControllers.controller('UserCtrl', ['$scope', 'Users',
  function($scope){
    $scope.users = Users.query();
    console.log($scope.users);
    //  $scope.gorgon stuff....
}]);