'use strict'

angular.module('appApp.controllers', ['appApp.services', 'appApp.directives', 'ui.bootstrap'])
  .controller('MainCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->
    $scope.awesomeThings = ['HTML5 Boilerplate', 'AngularJS', 'Karma']
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
