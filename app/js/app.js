'use strict';

var gorgonApp = angular.module('gorgonApp', [
  'ngRoute',
  'gorgonControllers',
  'gorgonServices'
]);

gorgonApp.config(['$routeProvider',
  function($routeProvider){
      $routeProvier.
          when('/', {
            templateUrl: 'views/users/index.html',
            controllers: 'UserCtrl'
          }).
          otherwise({
            redirectTo: '/'
          });
  }]);