'use strict'

angular.module('appApp.controllers', ['appApp.services'])
  .controller('MainCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ]
    $scope.reps = {}
    $scope.reps_names_list = []

    $scope.get_all_reps_in_office = ()->
      ApiGet.congress "/legislators?per_page_all", $scope.callback_all_reps_in_office, this

    $scope.callback_all_reps_in_office = (error, data) ->
      if not error
        for rep in data
          rep.fullname = "#{rep.title}. #{rep.first_name} #{rep.last_name}"
          $scope.reps_names_list.push({name: rep.fullname})
      else
        console.log "Error: ", error
   
    $scope.get_all_reps_in_office()
    
  ])
  .controller('ChartCtrl', ['$scope', '$http', 'ApiGet' ($scope, $http) ->
    $scope.source = {}
    $scope.sources = []

    $scope.get.contributors = ()->
      if not $scope.loaded.contributors
        ApiGet.influence "aggregates/pol/#{$scope.selected_rep.transparencydata_id}/contributors.json?cycle=2012&limit=10&", $scope.callback.contributors, this

    $scope.callback.contributors = (error, data)->
      if not error
        $scope.selected_rep.funding = $scope.selected_rep.funding or {}
        $scope.selected_rep.funding.contributors = data.json
        $scope.loaded.contributors = true
      else console.log "Error: ", error
    


  # ])
  #Add new controller to module hered
