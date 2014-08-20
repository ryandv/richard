richardApp.controller('transactionCtrl', ['$scope', '$http',
  function($scope, $http){
    console.log('derp');
    $http.get('./queue_transactions/current.json').success(function(data){
      console.log(data);
      $scope.queue_transactions = data;
    })
  }]);
