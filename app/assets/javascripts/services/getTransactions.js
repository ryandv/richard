richardApp.factory('getTransactions', ['$http', function($http){

  $http.get('/queue_transactions/current.json').success(function(data){
    return data;
  })

  Tx = {};
  Tx.retrieve = function(){
    $http.get('/queue_transactions/current.json').success(function(){

    })
  }



}]);