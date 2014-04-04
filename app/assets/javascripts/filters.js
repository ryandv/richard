'use strict';


angular.module('gorgonFilters', []).filter('formatCurrentUserRow',
    function(current){
        if(current == 'true'){
            return 'success';
        }
});
