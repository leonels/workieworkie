angular.module("SearcherApp")
	.factory("Job", function ($resource){
		return $resource("/jobs.json");
});

angular.module("SearcherApp")
	.filter("OriginFilter", function () {
		return function (items, types) {
			var filtered = [];
			angular.forEach(items, function (item) {

			});
			return filtered;
		};
});

angular.module("SearcherApp")
    .controller("SearchCtrl", function($scope, $filter, Job) {

    	$scope.jobs = Job.query();

    	$scope.predicate = 'title';

    	// $scope.originFilter = {};

    	var leLog = function () {
    		console.log($scope.jobs);
    		console.log($scope.originFilter);
    	};

    	$scope.leLog = leLog;

});