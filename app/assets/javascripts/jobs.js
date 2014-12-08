angular.module("SearcherApp")
	.factory("Job", function ($resource){
		return $resource("/jobs.json");
});

angular.module("SearcherApp")
    .controller("SearchCtrl", function($scope, $filter, Job) {

    	$scope.jobs = Job.query();

});