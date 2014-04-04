'use strict';

var gorgonApp = angular.module('gorgonApp', [
  'ngRoute',
  'gorgonControllers',
  'gorgonServices',
  'gorgonFilters'
]);

gorgonApp.config(['$routeProvider',
  function($routeProvider){
      $routeProvider.
          when('/', {
            templateUrl: 'assets/index.html',
            controllers: 'UserCtrl'
          }).
          otherwise({
            redirectTo: '/'
          });
  }]);
