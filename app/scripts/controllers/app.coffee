'use strict'

angular.module('appApp.controllers')
  .controller 'AppCtrl', ['$scope', 'ApiGet', '$location', ($scope, ApiGet, $location) ->
######################
# Variable Setup
######################

    # these are defined here and children $scopes will delegate to them
    # values placed here will be the defaults if no values is set as a url param
    $scope.reps = {}
    $scope.reps_list = []
    $scope.selected =
      rep1: {bioguide_id: "B000589", name: "Rep. John Boehner"}
      rep2: {bioguide_id: "P000197", name: "Rep. Nancy Pelosi"}
      zip: null
      bill: null
      commiitee: null
      district: null
      state: null
      position: null

    # init constants
    $scope.STATES = [{code: "AL", name: "Alabama - AL"},{code: "AK", name: "Alaska - AK"},{code: "AS", name: "American Samoa - AS"},{code: "AZ", name: "Arizona - AZ"},{code: "AR", name: "Arkansas - AR"},{code: "CA", name: "California - CA"},{code: "CO", name: "Colorado - CO"},{code: "CT", name: "Connecticut - CT"},{code: "DE", name: "Delaware - DE"},{code: "DC", name: "District Of Columbia - DC"},{code: "FM", name: "Federated States Of Micronesia - FM"},{code: "FL", name: "Florida - FL"},{code: "GA", name: "Georgia - GA"},{code: "GU", name: "Guam - GU"},{code: "HI", name: "Hawaii - HI"},{code: "ID", name: "Idaho - ID"},{code: "IL", name: "Illinois - IL"},{code: "IN", name: "Indiana - IN"},{code: "IA", name: "Iowa - IA"},{code: "KS", name: "Kansas - KS"},{code: "KY", name: "Kentucky - KY"},{code: "LA", name: "Louisiana - LA"},{code: "ME", name: "Maine - ME"},{code: "MH", name: "Marshall Islands - MH"},{code: "MD", name: "Maryland - MD"},{code: "MA", name: "Massachusetts - MA"},{code: "MI", name: "Michigan - MI"},{code: "MN", name: "Minnesota - MN"},{code: "MS", name: "Mississippi - MS"},{code: "MO", name: "Missouri - MO"},{code: "MT", name: "Montana - MT"},{code: "NE", name: "Nebraska - NE"},{code: "NV", name: "Nevada - NV"},{code: "NH", name: "New Hampshire - NH"},{code: "NJ", name: "New Jersey - NJ"},{code: "NM", name: "New Mexico - NM"},{code: "NY", name: "New York - NY"},{code: "NC", name: "North Carolina - NC"},{code: "ND", name: "North Dakota - ND"},{code: "MP", name: "Northern Mariana Islands - MP"},{code: "OH", name: "Ohio - OH"},{code: "OK", name: "Oklahoma - OK"},{code: "OR", name: "Oregon - OR"},{code: "PW", name: "Palau - PW"},{code: "PA", name: "Pennsylvania - PA"},{code: "PR", name: "Puerto Rico - PR"},{code: "RI", name: "Rhode Island - RI"},{code: "SC", name: "South Carolina - SC"},{code: "SD", name: "South Dakota - SD"},{code: "TN", name: "Tennessee - TN"},{code: "TX", name: "Texas - TX"},{code: "UT", name: "Utah - UT"},{code: "VT", name: "Vermont - VT"},{code: "VI", name: "Virgin Islands - VI"},{code: "VA", name: "Virginia - VA"},{code: "WA", name: "Washington - WA"},{code: "WV", name: "West Virginia - WV"},{code: "WI", name: "Wisconsin - WI"},{code: "WY", name: "Wyoming - WY"}]

######################
# Define API Methods
######################

    $scope.get_all_reps_in_office = ()->
      ApiGet.congress "legislators?per_page=all&", $scope.callback_all_reps_in_office, this

    $scope.callback_all_reps_in_office = (error, data) ->
      unless error
        for rep in data
          rep.fullname = "#{rep.title}. #{rep.first_name} #{rep.last_name}"
          $scope.reps_list.push({name: rep.fullname, bioguide_id: rep.bioguide_id})
          rep.chamber = rep.chamber.charAt(0).toUpperCase() + rep.chamber.slice(1)  # cap first letter
          rep.party_name = if rep.party is "D" then "Democrat" else if rep.party is "R" then "Republican" else rep.party
          $scope.reps[rep.bioguide_id] = $scope.reps[rep.bioguide_id] or {}
          $scope.reps[rep.bioguide_id].overview = rep
      else
        console.warn "Error setting reps_list and overview data: ", error

#####################
# Define Non-API Methods
#####################

    # active class navbar
    $scope.isActive = (viewLocation)->
      viewLocation is $location.path().match(/^(\/\w*)\/?/)[1]

    # this is used to update a selected rep based on the input boxes
    $scope.onSelect = ($item, $model, $label, rep)->
      $scope.selected[rep] = $item

######################
# Initial Method Calls
######################

    $scope.get_all_reps_in_office()

  ]
