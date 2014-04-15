'use strict';

angular.module('gorgonFilters', [])
    .filter('formatCurrentUserRow', function(){
      return function(current){
        if(current){
          return 'success';
        }
      }
    })
    .filter('formatDateTime', function(){
      return function(datetime){
        return Date.parse(datetime);
    }})
    .filter('formatStatus',function(){
      return function(status){
        if(status == 2){
          return 'Running';
        }
        else if(status == 1){
          return 'Waiting';
        }
        else{
          return 'Idle';
        }
      }
    });


