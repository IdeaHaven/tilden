'use strict';

angular.module('appApp.services')
  .factory 'ApiGet', ['$http', ($http) ->
    own: (path, callback, context) ->
      args = Array.prototype.slice.call(arguments, 3)
      $http
        url: "https://radiant-falls-9619.herokuapp.com/api/#{path}"
        method: "GET"
      .success (data, status, headers, config)->
        args.unshift data
        args.unshift null
        callback.apply(context, args)
      .error (data, status, headers, config) ->
        callback "Error pulling #{path} from Sunlight Congress API.", null
    congress: (path, callback, context) ->
      args = Array.prototype.slice.call(arguments, 2)
      context = args.shift()
      $http
        url: "http://congress.api.sunlightfoundation.com/#{path}&apikey=dbfd7316f90845b08767b06d2dd9441f"
        method: "GET"
      .success (data, status, headers, config)->
        args.unshift data.results
        args.unshift null
        callback.apply(context, args)
      .error (data, status, headers, config) ->
        callback "Error pulling #{path} from Sunlight Congress API.", null
    influence: (path, callback, context)->
      args = Array.prototype.slice.call(arguments, 2)
      context = args.shift()
      apiurl = "http://transparencydata.com/api/1.0/#{path}apikey=83c0368c509f468e992218f41e6529d7"
      $http
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\"#{apiurl}\""
          format: "json"
      .success (data, status, headers, config)->
        if data.query.results
          args.unshift data.query.results.json
          args.unshift null
          callback.apply(context, args)
      .error (data, status, headers, config)->
        callback "Error pulling #{path} from Sunlight Influence Explorer API", null
    nyt: (path, callback, context)->
      args = Array.prototype.slice.call(arguments, 2)
      context = args.shift()
      apiurl = "http://api.nytimes.com/svc/politics/v3/us/legislative/congress/#{path}.json?api-key=3c10766dde4415328ac78b4bb6b824ca:9:67943481"
      $http
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\"#{apiurl}\""
          format: "json"
      .success (data, status, headers, config)->
        if data.query.results
          args.unshift data.query.results.json
          args.unshift null
          callback.apply(context, args)
      .error (data, status, headers, config)->
        callback "Error pulling #{path} from New York Times API", null
    littleSis: (path, callback, context)->
      args = Array.prototype.slice.call(arguments, 2)
      context = args.shift()
      $http
        method: "GET"
        url: "http://api.littlesis.org/#{path}_key=f7415b282639a97967b87a0fa561a92960409a3e"
      .success (data, status, headers, config)->
        if data
          args.unshift data
          args.unshift null
          callback.apply(context, args)
      .error (data, status, headers, config)->
        callback "Error pulling #{path} from LittleSis", null
  ]
