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
  .controller('BillCtrl', ['$scope', '$http', '$location', ($scope, $http, $location) ->
    $scope.bill = {}
    $scope.bills = []
    $scope.$watch "bill", ->
      getBillText $scope.bill.last_version.urls.html
      setTimeout (->
        $("#billText").annotator().annotator('setupPlugins', {token: 'eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJpc3N1ZWRBdCI6ICIyMDEzLTA4LTIxVDE3OjU5OjQwWiIsICJjb25zdW1lcktleSI6ICI2N2NkYjJmOWNmZGY0NTE4YmIxMWQ3NTQ2YWUzMTExMSIsICJ1c2VySWQiOiAiYWxsIiwgInR0bCI6IDEyMDk2MDB9.mEQHB3rx81tfqGs7zA3VOcckOyo-Dsa3HyEeva_daIA'})
      ), 3000
      console.log "Ready to annotate!"

    getBillList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&per_page=20&page=1"
      ).success((data, status) ->
        $scope.bills = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    getBillText = (url) ->
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from html where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        console.log wordGraph(data.query.results.body.pre.replace(/<all>/g, '').replace(/^[^_]*_/, '').replace(/_\n\r/g, ''))
        $scope.bill.text = data.query.results.body.pre.replace(/<all>/g, '').replace(/^[^_]*_/, '').replace(/\n/g, '<br>')
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    wordGraph = (string) ->
      array = string.replace(/[^a-zA-Z0-9 -]/g, "").split(" ")
      result = {}
      i = 0
      while i < array.length
        if array[i].length > 3
          if result[array[i]]
            result[array[i]] += 1
          else
            result[array[i]] = 1
        i++
      for key of result
        delete result[key] if result[key] < 3
        delete result[key] if key is 'the' or key is 'and' or key is 'for'
      result

    getBillList()
  ])
