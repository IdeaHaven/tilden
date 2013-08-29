'use strict'

angular.module('appApp.controllers')
  .controller 'CompareCtrl', ['$scope','ApiGet', '$timeout', ($scope, ApiGet, $timeout) ->
######################
# Variable Setup
######################

    # these were defined in AppCtrl and $scope will delegate to $rootScope
      # $scope.reps
      # $scope.selected
      # $scope.reps_list

    # init local variables
    $scope.comparison =
      votes: null
      chamber: "house"
      congress: 113

    $scope.get =
      nyt: {}
      influence: {}
      littleSis: {}
    $scope.cb =
      nyt: {}
      influence: {}
      littleSis: {}

######################
# Define API Methods
######################
    $scope.get.nyt.overview = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      # only run if data is not already available
      unless $scope.reps[bioguide_id].nyt_overview
        ApiGet.nyt "members/#{bioguide_id}", $scope.cb.nyt.overview, this, bioguide_id

    $scope.cb.nyt.overview = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].nyt_overview = data.results
      else console.log 'error', error

    $scope.get.nyt.votes = (bioguide_id1, bioguide_id2, congress, chamber)->
      ApiGet.nyt "members/#{bioguide_id1}/votes/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.votes, this

    $scope.cb.nyt.votes = (error, data)->
      unless error
        $scope.comparison.votes = data.results
      else console.log 'Error pull nyt votes comparison: ', error

    $scope.get.influence.id = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      # only run if data is not already available
      unless $scope.reps[bioguide_id].influence
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{bioguide_id}&", $scope.cb.influence.id, this, bioguide_id

    $scope.cb.influence.id = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence = $scope.reps[bioguide_id].influence or {}
        $scope.reps[bioguide_id].influence.id = data.id

        # call depedents here
        $scope.get.influence.contributors(data.id, bioguide_id)
        $scope.get.influence.local(data.id, bioguide_id)
        $scope.get.influence.type(data.id, bioguide_id)
        $scope.get.influence.industries(data.id, bioguide_id)
      else console.log 'Error getting influence id: ', error

    $scope.get.influence.contributors = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors.json?cycle=2012&limit=3&", $scope.cb.influence.contributors, this, bioguide_id

    $scope.cb.influence.contributors = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.contributors = data.json
      else console.log 'error', error

    $scope.get.influence.local = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/local_breakdown.json?cycle=2012&", $scope.cb.influence.local, this, bioguide_id

    $scope.cb.influence.local = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.local = data
      else console.log 'error', error

    $scope.get.influence.type = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/type_breakdown.json?cycle=2012&", $scope.cb.influence.type, this, bioguide_id

    $scope.cb.influence.type = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.type = data
      else console.log 'error', error

    $scope.get.influence.industries = (transparency_id, bioguide_id)->
      # this is being called in the $scope.cb.influence.id callback so there is no need to check if the item was ever called before
      ApiGet.influence "aggregates/pol/#{transparency_id}/contributors/industries.json?cycle=2012&limit=3&", $scope.cb.influence.industries, this, bioguide_id

    $scope.cb.influence.industries = (error, data, bioguide_id) ->
      unless error
        $scope.reps[bioguide_id].influence.industries = data.json
        $scope.analysis.industries($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id)
      else console.log 'error', error


    $scope.get.nyt.bills = (bioguide_id1, bioguide_id2, congress, chamber)->
      ApiGet.nyt "members/#{bioguide_id1}/bills/#{bioguide_id2}/#{congress}/#{chamber}", $scope.cb.nyt.bills, this

    $scope.cb.nyt.bills = (error, data)->
      unless error
        $scope.comparison.bills = data.results
      else console.log 'Error pull nyt bills comparison: ', error

    $scope.get.littleSis.id = (bioguide_id)->
      ApiGet.littleSis "entities/bioguide_id/#{bioguide_id}.json?", $scope.cb.littleSis.id, this, bioguide_id

    $scope.cb.littleSis.id = (error, data, bioguide_id)->
      unless error
        $scope.reps[bioguide_id].littleSis = $scope.reps[bioguide_id].littleSis or {}
        $scope.reps[bioguide_id].littleSis.id = data.Response.Data.Entities.Entity.id
        $scope.reps[bioguide_id].littleSis.overview = data.Response.Data.Entities.Entity
        #call dependents here
        $scope.get.littleSis.donors(data.Response.Data.Entities.Entity.id, bioguide_id)

    $scope.get.littleSis.donors = (littleSis_id, bioguide_id)->
      unless $scope.reps[bioguide_id].littleSis.donors
        ApiGet.littleSis "entity/#{littleSis_id}/related.json?cat_ids=5&", $scope.cb.littleSis.donors, this, bioguide_id

    $scope.cb.littleSis.donors = (error, data, bioguide_id)->
      unless error
        match = []
        _.each data.Response.Data.RelatedEntities.Entity, (val) ->
          if val.Relationships.Relationship.amount
            if val.Relationships.Relationship.amount >= 15000
              match.push
                name: val.name
                summary: val.summary
                amount: val.Relationships.Relationship.amount

          else if val.Relationships.Relationship[0]
            _.each val.Relationships.Relationship, (subVal) ->
              if subVal.amount >= 15000
                match.push
                  name: val.name
                  summary: val.summary
                  amount: subVal.amount
        sorted = _.sortBy(match, ((val)-> val.amount*-1)).splice(0,10)
        $scope.reps[bioguide_id].littleSis.donors = sorted


#####################
# Define Non-API Methods
#####################

    # this is used to update a selected rep based on the input boxes
    $scope.onSelect = ($item, $model, $label, rep)->
      $scope.selected[rep] = $item

#####################
# Define Data Analysis
#####################

    $scope.analysis = {}

    $scope.analysis.industries = (bioguide_id1, bioguide_id2 )->
      both = {}
      _.each $scope.reps[bioguide_id1].influence.industries, (val)->
        _.each $scope.reps[bioguide_id2].influence.industries, (val1)->
          if val.id is val1.id
            both[val.name] = [val.amount, val1.amount]

      $scope.compareIndustries = both


#####################
# Define D3 Data
#####################

    $scope.scale_company = 175000
    $scope.scale_individual = 80000
    $scope.d3DonutClick = (item)->
      console.log 'D3 clicked', item

#####################
# Define Watchers
#####################

    # Watchers
    $scope.$watch 'selected.rep1', (newVal, oldVal)->
      console.log "Rep1 changed from #{oldVal.name} to #{newVal.name}"
      $scope.selected_watcher_functions('rep1', newVal.bioguide_id)
    $scope.$watch 'selected.rep2', (newVal, oldVal)->
      console.log "Rep2 changed from #{oldVal.name} to #{newVal.name}"
      $scope.selected_watcher_functions('rep2', newVal.bioguide_id)

    # Watcher Callbacks
    $scope.selected_watcher_functions = (rep, bioguide_id)->
      $scope.get.nyt.overview(bioguide_id)
      # nyt have a rate limit of 2 calls per secon
      $timeout(()->
        $scope.get.nyt.bills($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, $scope.comparison.congress, $scope.comparison.chamber)
        $scope.get.nyt.votes($scope.selected.rep1.bioguide_id, $scope.selected.rep2.bioguide_id, $scope.comparison.congress, $scope.comparison.chamber)
      , 1000)
      $scope.get.influence.id($scope.selected[rep].bioguide_id)
      $scope.get.littleSis.id(bioguide_id)

#####################
# Set Reps by Route Params and Init
#####################

    # set selected reps to show in input boxes
    $scope.rep1 = $scope.selected.rep1.name
    $scope.rep2 = $scope.selected.rep2.name

  ]