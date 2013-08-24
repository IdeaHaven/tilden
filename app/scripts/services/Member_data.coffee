angular.module('appApp.services')
  .factory 'Member_data', [ 'ApiGet', (ApiGet) ->
    get_nyt: (bioguide_id, callback)->
      ApiGet.nyt "members/#{bioguide_id}", callback, bioguide_id, this #Biodguide_id hardcoded pending rep selection
    
    get_littleSis: (bioguide_id, callback)->
      ApiGet.littleSis "entities/bioguide_id/#{bioguide_id}", @callback_littleSis, bioguide_id, this
    
  ]
    