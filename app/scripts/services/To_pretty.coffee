'use strict';

angular.module('appApp.services')
  .factory 'ToPretty', [() ->
    num_to_dollars: (num)->
      if typeof num is 'number'
        return '$' + Math.round(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
      else
        pnum = parseInt(num)
        unless isNaN(pnum)
          return '$' + Math.round(pnum).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        else
          console.warn "Not a number: ", num
          return num
  ]