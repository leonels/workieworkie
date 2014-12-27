angular.module("SearcherApp")
	.factory("Job", function ($resource){
		return $resource("/jobs.json");
});

angular.module("SearcherApp")
    .controller("SearchCtrl", function($scope, $filter, Job) {

    	$scope.jobs = Job.query();

        $scope.today = new Date();
        $scope.todayFormatted = $filter('date')($scope.today, 'MMM dd yy');

        // $scope.notFilteredJobs = Job.query();
        // jsonJobs = JSON.stringify($scope.notFilteredJobs[0]);
        // $scope.leNumber = _.countBy(jsonJobs, 'origin');

    	$scope.predicate = 'created_at'
        $scope.reverse = true;

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

});