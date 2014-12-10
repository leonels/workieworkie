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

        $scope.notFilteredJobs = Job.query();

    	$scope.reverse = false;

    	// $scope.originFilter = {};

    	var setReverse = function () {
    		if($scope.reverse == false){
    			$scope.reverse = true;
    		}else{
    			$scope.reverse = false;
    		}
    	};

    	$scope.setReverse = setReverse;

    	$scope.origins = [
    		{
    			'id': 1,
    			'name': 'City of Laredo'
    		},
    		{
    			'id': 2,
    			'name': 'Laredo Community College',	
    		},
    		{
    			'id': 3,
    			'name': 'Webb County'
    		}
    	];

    	$scope.currentOrigin = null;

    	function setCurrentOrigin(origin) {
    		$scope.currentOrigin = origin;
    	};

        function isCurrentOrigin(origin) {
            return $scope.currentOrigin !== null && origin.name === $scope.currentOrigin.name;
        };

        $scope.setCurrentOrigin = setCurrentOrigin;
        $scope.isCurrentOrigin = isCurrentOrigin;

        var whata = $filter('filter')($scope.notFilteredJobs, { origin: 'City of Laredo' });
        $scope.whata = whata;

    	var leLog = function () {
    		console.log($scope.jobs);
    		console.log($scope.originFilter);
    	};

    	$scope.leLog = leLog;

});