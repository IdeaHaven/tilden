angular.module('appApp.services')
  .factory 'Member_data', [ 'ApiGet', (ApiGet) ->
    get_nyt: (bioguide_id, callback)->
      ApiGet.nyt "members/#{bioguide_id}", callback, bioguide_id, this #Biodguide_id hardcoded pending rep selection

    get_littleSis_id: (bioguide_id, callback)->
      ApiGet.littleSis "entities/bioguide_id/#{bioguide_id}", callback, bioguide_id, this

    get_littleSisDonors: (littleSis_id, callback)->
      ApiGet.littleSisDonors "#{littleSis_id}/related.json?cat_ids=5", callback, this

    get_littleSisSpouse: (littleSis_id, callback)->
      ApiGet.littleSisDonors "13287/related.json?cat_ids=4", callback, bioguide_id, this

  ]
