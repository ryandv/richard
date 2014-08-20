richardApp.controller('actions', ['$scope', '$http',
  function($scope, $http){
    $http.get('queue_transactions/action_status.json').success(function(data){
      console.log(data);
      $scope.status = data;
      // left off here just need to connect data to the action buttons!!!!!!!!
    })
  }]);
