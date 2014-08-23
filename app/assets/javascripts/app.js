var richardApp = angular.module('richardApp', ['ngRoute', 'ngResource', 'templates']);

richardApp.config(function($routeProvider){
    $routeProvider.
      when('/', {
        templateUrl: 'transactions/index.html',
//        controller: 'transactionCtrl'
        controller: 'actions'
      }).
      otherwise({
        redirecTo: '/'
      })
  });