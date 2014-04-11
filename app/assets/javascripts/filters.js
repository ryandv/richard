'use strict';


angular.module('gorgonFilters', [])
    .filter('formatCurrentUserRow', function(current){
      return function(){
        console.log('sup');
        if(current == 'true'){
          return 'success';
        }
        else{
          return 'success';
        }
      }
});
