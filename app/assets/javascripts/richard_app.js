// API Key Logic //
var module = angular.module("Richard", []);

// CSRF Issue //
module.config(['$httpProvider', function($httpProvider) {
  var getToken = function() {
    // Rails 3+
    var el = document.querySelector('meta[name="csrf-token"]');
    if (el) {
      el = el.getAttribute('content');
    }
    return el;
  };

  var updateToken = function() {
    var headers = $httpProvider.defaults.headers.common, token = getToken();

    if (token) {
      headers['X-CSRF-TOKEN'] = getToken();
      headers['X-Requested-With'] = 'XMLHttpRequest';
    }
  };

  updateToken();
}]);

module.controller("ApiKeyController", ["$scope", "$http", function ($scope, $http) {
  $scope.apiKey = '';

  // Load Key the first Time //
  $http.get('/user/api_key.json').
    success(function(data, status, headers, config) {
      $scope.apiKey = data.apiKey;
    });

  $scope.resetApiKey = function () {
    $http.post('/user/reset_api_key.json').
      success(function(data, status, headers, config) {
        $scope.apiKey = data.apiKey;
      })
      .error(function(data, status, headers, config) {
        alert("Could not reset API Key");
      });
  };
}]);