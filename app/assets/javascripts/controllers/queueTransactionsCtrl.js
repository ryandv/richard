richardApp.controller('queueTransactionsCtrl', ['$scope', '$http', function($scope, $http){

  $http.get('queue_transactions/current.json').success(function(data){
    $scope.status = 'idle';
    $scope.queue_transactions = data;
    $.each(data, function(key, val){
      if(val.current_user == 't'){
        $scope.current_transaction = val;
        $scope.status = val.status;
      }
      if((val.status == 'running' || val.status == 'pending') && val.current_user == 'f'){
        $scope.status = 'blocked';  //TODO show start waiting | might be more cases to handle;
      }
    });
  });

  $http.get('queue_transactions/user.json').success(function(data){
    $scope.user = data;
  });

  if (typeof(EventSource) !== "undefined") {
    var source = new EventSource('/queue_transactions/event');
    source.addEventListener('queue_transactions.update', function(event) {
      console.log(JSON.parse(event.data));

      if(event.data == '[]'){
        console.log('nullme');
        $scope.queue_transactions = [];
        $scope.$apply();
      }
      else{
        $scope.queue_transactions = [];
        _.each(JSON.parse(event.data), function(a){
          $scope.queue_transactions.push(a);
        });
        $scope.$apply();
      }
    }, false);
  }
   else {
    alert('SSE not supported by browser.');
  }

  $scope.updateQueueTransaction  = function(blob){
    $scope.$apply(function () { $scope.msgs.push(JSON.parse(blob.data)); });
    console.log('look how fast im going');
  };

  $scope.run = function(){
    $http.post('/queue_transactions').success(function(){
      $scope.status = 'running';
    });
  };

  $scope.finish = function(id){
    console.log("id: " + id);

    $http.put('/queue_transactions/' + id + '/finish').success(function(){
      $scope.status = 'idle';
      remove_transaction(id);
    });
//    $scope.$apply();
  };

  $scope.run_after_pending = function(id){
    $http.put('/queue_transactions/' + id + '/run').success(function(){
      $scope.status = 'what';
      $scope.queue_transactions.push({email: $scope.user.email, status: 'running', duration: 0});
    });
  };

  $scope.cancel = function(id){
    $http.put('/queue_transactions/' + id + '/cancel').success(function(){
      $scope.status = 'idle';
      remove_transaction(id);
    });
    $scope.$apply();
  };

  $scope.start_waiting = function(){
    $http.post('/queue_transactions').success(function(){
      $scope.status = 'waiting';
    })
  };

  $scope.force_release = function(){
    $http.put('/queue_transactions/345/force_release').success(function(){
      $scope.status = 'what4';
    })
  };

  var remove_transaction = function(id){
    console.log("id:" + id);
    $.each($scope.queue_transactions, function(key,val){
      console.log(val.id);
      if(val.id == id){
        index = key;
      }
    })
    $scope.queue_transactions.splice(index, 1);
  };
}]);
