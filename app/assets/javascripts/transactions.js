var transactionsModule = angular.module('transactions', []);

transactionsModule.factory('Transactions', function() {
    return {};
});

transactionsModule.controller('TransactionsCtrl', function($scope, Transactions) {

    $scope.init = function() {
        var source = new EventSource('/transactions');
        source.onmessage = function(event) {
            $scope.$apply(function() {
                console.log(event);
                $scope.entries = JSON.parse(event.data)
            });
        };
    };
});