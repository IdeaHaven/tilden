'use strict'

angular.module('appApp.controllers')
  .controller('BillCtrl', ['$scope', '$http', '$location', ($scope, $http, $location) ->
    $scope.bill = {}
    $scope.bills = []
    $scope.title = ""
    $scope.$watch "bill", ->
      billCode = makeBillCode()
      $location.path("bills/#{billCode}")
      getBillText makeBillUrl(billCode)
      setTimeout (->
        $("#billText").annotator().annotator('setupPlugins', {token: 'eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJpc3N1ZWRBdCI6ICIyMDEzLTA4LTIxVDE3OjU5OjQwWiIsICJjb25zdW1lcktleSI6ICI2N2NkYjJmOWNmZGY0NTE4YmIxMWQ3NTQ2YWUzMTExMSIsICJ1c2VySWQiOiAiYWxsIiwgInR0bCI6IDEyMDk2MDB9.mEQHB3rx81tfqGs7zA3VOcckOyo-Dsa3HyEeva_daIA'})
      ), 3000
      console.log "Ready to annotate!"

    makeBillCode = ->
      billCode = "BILLS-#{$scope.bill.congress}#{$scope.bill.bill_type}#{$scope.bill.number}#{$scope.bill.last_version.version_code}"
      return billCode
    
    makeBillUrl = (billCode) ->
      requestUrl = "http://www.gpo.gov/fdsys/pkg/#{billCode}/html/#{billCode}.htm"
      return requestUrl

    makeBillId = ->
      billCode = $location.path().split("").splice(13,15)
      bill = billCode.splice(3,12).join("").replace(/ih/, '').replace(/is/, '').replace(/ats/, '')
      congress = billCode.splice(0,3).join("")
      return "#{bill}-#{congress}"

    getBillTextOnLoad = ->
      if $location.path() != "/bills" then getBillText(makeBillUrl($location.path().split("").slice(7).join("")))

    getBillTitleOnLoad = ->
      bill_id = makeBillId()
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&bill_id=#{bill_id}"
      ).success((data, status) ->
        $scope.title = data.results[0].short_title or data.results[0].official_title
      ).error (data, status) ->
        console.log "Error #{status}: #{data} (thrown by getBillTitleOnLoad)"

    getBillList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&per_page=100&page=1"
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
        $scope.bill.text = data.query.results.body.pre.replace(/<all>/g, '').replace(/^[^_]*_/, '').replace(/\n/g, '<br>')
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    # wordGraph = (string) ->
    #   wordGraph(data.query.results.body.pre.replace(/<all>/g, '').replace(/^[^_]*_/, '').replace(/_\n\r/g, ''))
    #   array = string.replace(/[^a-zA-Z0-9 -]/g, "").split(" ")
    #   result = {}
    #   i = 0
    #   while i < array.length
    #     if array[i].length > 3
    #       if result[array[i]]
    #         result[array[i]] += 1
    #       else
    #         result[array[i]] = 1
    #     i++
    #   for key of result
    #     delete result[key] if result[key] < 3
    #     delete result[key] if key is 'the' or key is 'and' or key is 'for'
    #   result

    getBillList()
    getBillTitleOnLoad()
    getBillTextOnLoad()
  ])