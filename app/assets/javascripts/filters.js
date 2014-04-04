'use strict';

/* Filters */
angular.module('gorgonFilters', []).filter('formatStatus', function() {
  return function(input) {
    if (input == 0) {
      return "Idle"
    } else if (input == 1) {
      return "Waiting"
    } else if  (input == 2) {
      return "Running"
    }   
  };  
});
