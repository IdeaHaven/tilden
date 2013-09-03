'use strict'

angular.module('appApp.controllers')
  .controller('BillCtrl', ['$scope', '$http', '$location', ($scope, $http, $location) ->
    $scope.bill = {}
    $scope.bills = []
    $scope.bill_url = "http://gpo.gov/fdsys/pkg/BILLS-113hr3059ih/pdf/BILLS-113hr3059ih.pdf"
    $scope.bill_query = null
    $scope.title = ""
    $scope.sponsor = ""
    $scope.$watch "bill", ->
      billCode = makeBillCode()
      $location.path("bills/#{billCode}")
      getBillText makeBillUrl(billCode)
      getBillTitle()


    makeBillCode = ->
      return "BILLS-#{$scope.bill.congress}#{$scope.bill.bill_type}#{$scope.bill.number}#{$scope.bill.last_version.version_code}"

    makeBillUrl = (billCode) ->
      return "http://www.gpo.gov/fdsys/pkg/#{billCode}/pdf/#{billCode}.pdf"

    makeBillId = ->
      billCode = $location.path().split("").splice(13,15)
      bill = billCode.splice(3,12).join("").replace(/ih/, '').replace(/is/, '').replace(/ats/, '').replace(/enr/, '').replace(/rfs/, '')
      congress = billCode.splice(0,3).join("")
      return "#{bill}-#{congress}"

    getBillTextOnLoad = ->
      if $location.path() is not "/bills" then getBillText(makeBillUrl($location.path().split("").slice(7).join("")))
      getBillTitle()

    getBillTitle = ->
      bill_id = makeBillId()
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&bill_id=#{bill_id}"
      ).success((data, status) ->
        bioguide_id = data.results[0].sponsor_id
        $scope.sponsor_id = bioguide_id
        $scope.sponsor = $scope.reps[bioguide_id].overview.fullname
        $scope.selected.rep1 =
          bioguide_id: bioguide_id
          name: $scope.reps[bioguide_id].overview.fullname
        if data.results[0].short_title
          $scope.title = data.results[0].short_title
        else if data.results[0].official_title.length < 140
          $scope.title = data.results[0].official_title
        else
          $scope.title = "#{data.results[0].bill_type.toUpperCase()} #{data.results[0].number}"
      ).error (data, status) ->
        console.log "Error #{status}: #{data} (thrown by getBillTitle)"

    getQueryListOfBills = ->
      query = $scope.bill_query.replace(/\s/g, '%20')
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills/search?query=%22#{query}%22&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      ).success((data, status) ->
        $scope.bills = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    getBillList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/bills?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&per_page=100&page=1"
      ).success((data, status) ->
        $scope.bills = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    getBillText = (url) ->
      $scope.bill_url = url

    $scope.billQuery = ->
      $scope.bills = []
      getQueryListOfBills()
      $scope.bill_query = null


    getBillList()
    getBillTitle()
    getBillTextOnLoad()

  ])
