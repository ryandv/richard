richardApp.controller('actions', ['$scope', '$http', function($scope, $http){

  $http.get('queue_transactions/current.json').success(function(data){

    //TODO default cant be idle, because it will show run when someone is already running
      $scope.status = 'idle';
      $scope.queue_transactions = data;

      $.each(data, function(key, val){
        if(val.current_user == 't'){
          console.log(val);
          $scope.current_transaction = val;
          $scope.status = val.status;
        }
        if((val.status == 'running' || val.status == 'pending') && val.current_user == 'f'){
          $scope.status = 'blocked';  //TODO show start waiting | might be more cases to handle;
        }
      });

    });

  $scope.run = function(){
    $http.post('/queue_transactions').success(function(){

      console.log($scope.queue_transactions);
      $scope.status = 'running';
    });
  };

  $scope.finish = function(id){
    console.log(id);
    $http.put('/queue_transactions/' + id + '/finish').success(function(){

      //TODO need to query for the appropriate status depending on the queue
      $scope.status = 'idle';

      $scope.apply();
    })
  };

  $scope.run_after_pending = function(id){
    $http.put('/queue_transactions/' + id + '/run').success(function(){
      $scope.status = 'what';
      $scope.apply();
    });
  };

  $scope.cancel = function(){
    $http.put('/queue_transactions/212/cancel').success(function(){
      $scope.status = 'what2';
      $scope.apply();
    });
  };

  $scope.start_waiting = function(){
    $http.post('/queue_transactions').success(function(){
      $scope.status = 'waiting';
      $scope.apply();
    })
  };

  $scope.force_release = function(){
    $http.put('/queue_transactions/345/force_release').success(function(){
      $scope.status = 'what4';
      $scope.apply();
    })
  };
}]);
