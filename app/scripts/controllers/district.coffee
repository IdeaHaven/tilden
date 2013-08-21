'use strict'

angular.module('appApp')
  .controller 'DistrictCtrl', ($scope) ->
    ready = (error, us, congress) ->
      svg.append("defs").append("path").attr("id", "land").datum(topojson.feature(us, us.objects.land)).attr "d", path
      svg.append("clipPath").attr("id", "clip-land").append("use").attr "xlink:href", "#land"
      svg.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(topojson.feature(congress, congress.objects.districts).features).enter().append("path").attr("d", path).append("title").text (d) ->
        d.id

      svg.append("path").attr("class", "district-boundaries").attr("clip-path", "url(#clip-land)").datum(topojson.mesh(congress, congress.objects.districts, (a, b) ->
        (a.id / 1000 | 0) is (b.id / 1000 | 0)
      )).attr "d", path
      svg.append("path").attr("class", "state-boundaries").datum(topojson.mesh(us, us.objects.states, (a, b) ->
        a isnt b
      )).attr "d", path
    width = 960
    height = 500
    path = d3.geo.path()
    svg = d3.select("body").append("svg").attr("width", width).attr("height", height)
    queue().defer(d3.json, "views/us.json").defer(d3.json, "views/us-congress-113.json").await ready