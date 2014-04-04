'use strict';

var  gorgonServices = angular.module('gorgonServices', ['ngResource']);

gorgonServices.factory('Users', ['$resource',
  function($resource){
    return $resource('users_json.json', {}, {
      query: {method: 'GET', params: { }, isArray:true}
    });
  }]);