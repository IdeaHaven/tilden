'use strict'

angular.module('appApp.controllers')
  .controller 'DistrictCtrl', ['$scope', '$window', '$location', '$routeParams', '$compile', 'ApiGet', ($scope, $window, $location, $routeParams, $compile, ApiGet) ->
    $scope.supportGeo = $window.navigator
    $scope.position = null
    $scope.selected_zip = null
    $scope.warning = null
    $scope.state_district = {state: null, district: null}
    $scope.district_reps = []
    $scope.map_width = 0
    $scope.FIPS_to_state = {1:'AL', 2:'AK', 4:'AZ', 5:'AR', 6:'CA', 8:'CO', 9:'CT', 10:'DE', 11:'DC', 12:'FL', 13:'GA', 15:'HI', 16:'ID', 17:'IL', 18:'IN', 19:'IA', 20:'KS', 21:'KY', 22:'LA', 23:'ME', 24:'MD', 25:'MA', 26:'MI', 27:'MN', 28:'MS', 29:'MO', 30:'MT', 31:'NE', 32:'NV', 33:'NH', 34:'NJ', 35:'NM', 36:'NY', 37:'NC', 38:'ND', 39:'OH', 40:'OK', 41:'OR', 42:'PA', 44:'RI', 45:'SC', 46:'SD', 47:'TN', 48:'TX', 49:'UT', 50:'VT', 51:'VA', 53:'WA', 54:'WV', 55:'WI', 56:'WY', 60:'AS', 64:'FM', 66:'GU', 68:'MH', 69:'MP', 70:'PW', 72:'PR', 74:'UM', 78:'VI'}

    $scope.getLocation = () ->
      $window.navigator.geolocation.getCurrentPosition((position)->
        $scope.$apply(()->
          $scope.position = position
          $scope.findDistrictByLongLat()
        , (error) -> console.log error)
      )

    $scope.findDistrictByLongLat = () ->
      ApiGet.congress "districts/locate?latitude=#{$scope.position.coords.latitude}&longitude=#{$scope.position.coords.longitude}", $scope.setDistrict, this

    $scope.findDistrictByZip = () ->
      ApiGet.congress "districts/locate?zip=#{$scope.selected_zip}", $scope.setDistrict, this

    $scope.setDistrict = (error, data) ->
      if not error
        unless data.length
          return $scope.warning = "No district was found for #{$scope.selected_zip}."
        $scope.state_district = {state: data[0].state, district: data[0].district}
      else console.log "Error: ", error

    $scope.setDistrictData = (newVals, oldVals) ->
      #TODO: See about reimplementing the behavior below or caching another way.
      # Old and new values are passed in to see if there has been a change in state.
      # if newVals.state is oldVals.state
      #   $scope.district_reps.pop()
      #   ApiGet.congress "legislators?state=#{$scope.state_district.state}&district=#{$scope.state_district.district}", (error, data) ->
      #     if not error
      #       $scope.district_reps.push(data[0])
      #     else console.log "Error: ", error
      #     , this
      # else
        $scope.district_reps = []
        ApiGet.congress "legislators?state=#{$scope.state_district.state}&title=Sen", (error, data) ->
          if not error
            for sen in data
              $scope.district_reps.push(sen)
          else console.log "Error: ", error
          , this
        ApiGet.congress "legislators?state=#{$scope.state_district.state}&district=#{$scope.state_district.district}", (error, data) ->
          if not error
            $scope.district_reps.push(data[0])
          else console.log "Error: ", error
          , this

    $scope.highlightDistrict = () ->
      d3.select('.districts').selectAll('path').classed('selected', false)
      district_element = d3.select(d3.select('.districts').selectAll('path').filter((d, i) -> return this.textContent == "#{$scope.state_district.state}-#{$scope.state_district.district}")[0][0])
      district_element.attr('class', 'selected')
      if $scope.map_width is 960 then district_element.call($scope.zoomIn)

    $scope.drawMap = () ->
      ready = (error, us, congress) ->
        $scope.usMap.append("defs").append("path").attr("id", "land").datum(topojson.feature(us, us.objects.land)).attr "d", path
        $scope.usMap.append("clipPath").attr("id", "clip-land").append("use").attr "xlink:href", "#land"
        district = $scope.usMap.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(topojson.feature(congress, congress.objects.districts).features).enter().append("path").attr("d", path).text (d) ->
          "#{$scope.FIPS_to_state[d.id / 100 | 0]}-#{d.id % 100}"
        district.on("mouseover", () ->
          return tooltip.style("visibility", "visible").text(d3.select(this).text())
        ).on("mousemove", () ->
          return tooltip.style("top", (event.pageY-27)+"px").style("left", (event.pageX+"px"))
        ).on("mouseout", () ->
          return tooltip.style("visibility", "hidden")
        ).on("click", () ->
          if !$scope.district_reps.length and $scope.zoomed
            $scope.usMap.transition().duration(750).attr("transform", "translate(0,0)scale(1)").style "stroke-width", 1 + "px"
            d3.select('#map_dialog').transition().duration(750).style("opacity", 1e-6)
            $scope.state_district = {state: null, district: null}
            $scope.district_reps = []
          else
            district_id = d3.select(this).text()
            $scope.state_district = {state: district_id.slice(0, 2), district: district_id.slice(3, 6)}
            $scope.$apply()
        )
        $scope.usMap.append("path").attr("class", "district-boundaries").attr("clip-path", "url(#clip-land)").datum(topojson.mesh(congress, congress.objects.districts, (a, b) ->
          (a.id / 1000 | 0) is (b.id / 1000 | 0)
        )).attr "d", path
        $scope.usMap.append("path").attr("class", "state-boundaries").datum(topojson.mesh(us, us.objects.states, (a, b) ->
          a isnt b
        )).attr "d", path
        $('#map_holder').on("dblclick", () ->
          $scope.zoomOut()
        )

      $scope.map_width = 960
      height = 500
      path = d3.geo.path()
      svg = d3.select("#map_holder").append("svg").attr("width", $scope.map_width).attr("height", height)
      $scope.usMap = svg.append("g").attr("id", "map_with_districts")
      tooltip = $scope.makeTooltip()
      dialog = d3.select("#map_dialog")
        .style("opacity", 1e-6)
        .style("z-index", "15")
      $scope.makeMapGradients()
      $scope.makeMapGradients()      
      queue().defer(d3.json, "data/us.json").defer(d3.json, "data/us-congress-113.json").await ready

    $scope.makeTooltip = () ->
      return d3.select("#map_holder")
        .append("div")
        .attr("class", "map_tooltip")
        .style("z-index", "10")
        .style("visibility", "hidden")

    $scope.makeMapGradients = () ->
      d3.select("#map_holder").select("svg")
        .append("radialGradient")
          .attr("id", "selected_gradient")
          .attr("x1", "0%")
          .attr("y1", "0%")
          .attr("x2", "100%")
          .attr("y2", "100%")
        .selectAll("stop")
          .data([
            {offset: "0%", color: "#d2ff52"},
            {offset: "100%", color: "#91e842"}
          ])
        .enter().append("stop")
          .attr("offset", (d)-> return d.offset)
          .attr("stop-color", (d)->  return d.color)

      d3.select("#map_holder").select("svg")
        .append("radialGradient")
          .attr("id", "hover_gradient")
          .attr("x1", "0%")
          .attr("y1", "0%")
          .attr("x2", "100%")
          .attr("y2", "100%")
        .selectAll("stop")
          .data([
            {offset: "0%", color: "#f1e767"},
            {offset: "100%", color: "#FCA625"}
          ])
        .enter().append("stop")
          .attr("offset", (d)-> return d.offset)
          .attr("stop-color", (d)->  return d.color)

    $scope.zoomIn = (d) ->
      console.log "Called zoomIn"
      element = d.node()
      bbox = element.getBBox()
      x = bbox.x + bbox.width/2
      y = bbox.y + bbox.height/2
      if y < 106 and (bbox.height > 53 or bbox.width > 53) then y += (106 - y)
      scale = 200/Math.sqrt(Math.pow(bbox.width, 2) + Math.pow(bbox.height,2))
      $scope.usMap.transition().duration(750).attr("transform", "translate(" + 960 / 2 + "," + 600 / 2 + ")scale(" + scale + ")translate(" + -x + "," + -y + ")").style "stroke-width", 1.5 / scale + "px"

    $scope.zoomOut = (d) ->
      d3.select('.districts').selectAll('path').classed('selected', false)
      $scope.position = null
      $scope.selected_zip = null
      $scope.warning = null
      $scope.state_district = {state: null, district: null}
      $scope.district_reps = []
      d3.select('#map_dialog').transition().duration(750).style("opacity", 1e-6)
      if $scope.map_width is 960 then $scope.usMap.transition().duration(750).attr("transform", "translate(0,0)scale(1)").style "stroke-width", 1 + "px"

    $scope.showDistrictDialog = () ->
      $('#map_dialog').html($compile("<sub-view template='partials/district_reps'></sub-view>")($scope))
      d3.select('#map_dialog')
        .transition()
        .duration(750)
        .style("opacity", 1)

    $scope.defaultFocus = () ->
      # TODO: refactor this to not use an API call but only scope variables if possible.
      if $routeParams.bioguide_id.length > 0
        ApiGet.congress "legislators?bioguide_id=#{$routeParams.bioguide_id}", (error, data) ->
          if not error
            if not data[0].district 
              for state in ["AK", "DE", "MT", "ND", "SD", "VT", "WY"]
                if data[0].state is state
                  data[0].district = "0"
              if not data[0].district then data[0].district = "1"
            $scope.state_district = {state: data[0].state, district: data[0].district}
          else console.log "Error, Senator/Rep not found."
      else console.log "No parameter"

    $scope.drawMapByState = (state_FIPS) ->
      state_districts = []
      ready = (error, us, congress) ->
        for obj in topojson.feature(congress, congress.objects.districts).features
          if obj.id and JSON.stringify(obj.id).slice(0, -2) is state_FIPS
            state_districts.push(obj)
        #find min top/left, find width/height
        district = $scope.usMap.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(state_districts).enter().append("path").attr("d", path).text (d) ->
          "#{$scope.FIPS_to_state[d.id / 100 | 0]}-#{d.id % 100}"
        district_boundaries = $scope.usMap.append("path").attr("class", "district-boundaries").attr("clip-path", "url(#clip-land)").datum(topojson.mesh(congress, congress.objects.districts, (a, b) ->
          (a.id / 1000 | 0) is (b.id / 1000 | 0) and (a.id and JSON.stringify(a.id).slice(0, -2) is state_FIPS)
        )).attr "d", path
        district.on("mouseover", () ->
          return tooltip.style("visibility", "visible").text(d3.select(this).text())
        ).on("mousemove", () -> 
          return tooltip.style("top", (event.pageY-27)+"px").style("left", (event.pageX+"px"))
        ).on("mouseout", () -> 
          return tooltip.style("visibility", "hidden")
        ).on("click", () ->
          if !$scope.district_reps.length and $scope.zoomed
            $scope.usMap.transition().duration(750).attr("transform", "translate(0,0)scale(1)").style "stroke-width", 1 + "px"
            d3.select('#map_dialog').transition().duration(750).style("opacity", 1e-6)
            $scope.state_district = {state: null, district: null}
            $scope.district_reps = []
          else
            district_id = d3.select(this).text()
            $scope.state_district = {state: district_id.slice(0, 2), district: district_id.slice(3, 6)}
            $scope.$apply()
        )
        $('#map_holder').on("dblclick", () ->
          $scope.zoomOut()
        )
        # The below is based off zoom code, maybe refactor to call zoom or related func
        bbox = d3.select("#map_with_districts").node().getBBox()
        o_x = bbox.x + bbox.width/2
        o_y = bbox.y + bbox.height/2
        # scale = 100/Math.sqrt(Math.pow(bbox.width, 2) + Math.pow(bbox.height,2))
        scale = 1
        $scope.usMap.attr("transform", "translate(" + 220 / 2 + "," + 220 / 2 + ")scale(" + scale + ")translate(" + -o_x + "," + -o_y + ")").style "stroke-width", 1.5


      #    element = d.node()
      # bbox = element.getBBox()
      # x = bbox.x + bbox.width/2
      # y = bbox.y + bbox.height/2
      # if y < 106 and (bbox.height > 53 or bbox.width > 53) then y += (106 - y)
      # scale = 200/Math.sqrt(Math.pow(bbox.width, 2) + Math.pow(bbox.height,2))
      # $scope.usMap.transition().duration(750).attr("transform", "translate(" + 960 / 2 + "," + 600 / 2 + ")scale(" + scale + ")translate(" + -x + "," + -y + ")").style "stroke-width", 1.5 / scale + "px"

      $scope.map_width = 220
      height = 220
      path = d3.geo.path()
      svg = d3.select("#map_holder").append("svg").attr("width", $scope.map_width).attr("height", height)
      $scope.usMap = svg.append("g").attr("id", "map_with_districts")
      dialog = d3.select("#map_dialog").style("opacity", 1e-6).style("z-index", "15")
      tooltip = $scope.makeTooltip()
      $scope.makeMapGradients()
      queue().defer(d3.json, "data/us.json").defer(d3.json, "data/us-congress-113.json").await ready

    $scope.drawMap()
    $scope.defaultFocus()
    # $scope.drawMapByState("49")

    $scope.$watch('state_district', (newVals, oldVals) ->
      if $scope.state_district.state
        $scope.setDistrictData(newVals, oldVals)
        $scope.highlightDistrict()
    , true)

    $scope.$watch('district_reps', (newVals, oldVals) ->
      if $scope.district_reps.length and $scope.state_district.state
        $scope.showDistrictDialog()
    , true)

  ]
