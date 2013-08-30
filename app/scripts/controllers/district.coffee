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
    $scope.FIPS_to_state = {1: ['AL', 'Alabama'], 2:['AK', 'Alaska'], 4:['AZ','Arizona'], 5:['AR', 'Arkansas'], 6:['CA', 'California'], 8:['CO', 'Colorado'], 9:['CT', 'Connecticut'], 10:['DE', 'Delaware'], 11:['DC', 'Washington, DC'], 12:['FL', 'Florida'], 13:['GA','Georgia'], 15:['HI', 'Hawaii'], 16:['ID', 'Idaho'], 17:['IL', 'Illinois'], 18:['IN', 'Indiana'], 19:['IA', 'Iowa'], 20:['KS', 'Kansas'], 21:['KY', 'Kentucky'], 22:['LA', 'Louisiana'], 23:['ME', 'Maine'], 24:['MD', 'Maryland'], 25:['MA', 'Massachusetts'], 26:['MI', 'Michigan'], 27:['MN', 'Minnesota'], 28:['MS', 'Mississippi'], 29:['MO', 'Missouri'], 30:['MT', 'Montana'], 31:['NE', 'Nebraska'], 32:['NV', 'Nevada'], 33:['NH', 'New Hampshire'], 34:['NJ', 'New Jersey'], 35:['NM', 'New Mexico'], 36:['NY', 'New York'], 37:['NC', 'North Carolina'], 38:['ND', 'North Dakota'], 39:['OH', 'Ohio'], 40:['OK', 'Oklahoma'], 41:['OR', 'Oregon'], 42:['PA', 'Pennsylvania'], 44:['RI', 'Rhode Island'], 45:['SC', 'South Carolina'], 46:['SD', 'South Dakota'], 47:['TN', 'Tennessee'], 48:['TX', 'Texas'], 49:['UT', 'Utah'], 50:['VT', 'Vermont'], 51:['VA', 'Virginia'], 53:['WA', 'Washington'], 54:['WV', 'West Virginia'], 55:['WI', 'Wisconsin'], 56:['WY', 'Wyoming']}
    $scope.state_to_FIPS = {'AL': '1', 'AK': '2', 'AZ': '4', 'AR': '5', 'CA': '6', 'CO': '8', 'CT': '9', 'DE': '10', 'DC': '11', 'FL': '12', 'GA': '13', 'HI': '15', 'ID': '16', 'IL': '17', 'IN': '18', 'IA': '19', 'KS': '20', 'KY': '21', 'LA': '22', 'ME': '20', 'MD': '24', 'MA': '25', 'MI': '26', 'MN': '27', 'MS': '28', 'MO': '29', 'MT': '30', 'NE': '31', 'NV': '32', 'NH': '33', 'NJ': '34', 'NM': '35', 'NY': '36', 'NC': '37', 'ND': '38', 'OH': '39', 'OK': '40', 'OR': '41', 'PA': '42', 'RI': '44', 'SC': '45', 'SD': '46', 'TN': '47', 'TX': '48', 'UT': '49', 'VT': '50', 'VA': '51', 'WA': '53', 'WV': '54', 'WI': '55', 'WY': '56' }

    $scope.getLocation = () ->
      $window.navigator.geolocation.getCurrentPosition((position)->
        $scope.$apply(()->
          $scope.position = position
          $scope.selected.position = position
          $scope.findDistrictByLongLat()
        , (error) -> console.log error)
      )

    $scope.findDistrictByLongLat = () ->
      ApiGet.congress "districts/locate?latitude=#{$scope.position.coords.latitude}&longitude=#{$scope.position.coords.longitude}", $scope.setDistrict, this

    $scope.findDistrictByZip = () ->
      ApiGet.congress "districts/locate?zip=#{$scope.selected_zip}", $scope.setDistrict, this, $scope.selected_zip

    $scope.setDistrict = (error, data, zip) ->
      if not error
        unless data.length
          return $scope.warning = "No district was found for #{$scope.selected_zip}."
        $scope.state_district = {state: data[0].state, district: data[0].district}
        $scope.selected.zip = zip
        $scope.selected.state = data[0].state
        $scope.selected.district = data[0].district
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
      if not $scope.state_district.district 
        for state in ["AK", "DE", "MT", "ND", "SD", "VT", "WY"]
          if $scope.state_district.state is state
            $scope.state_district.district = "0"
        if not $scope.state_district.district then $scope.state_district.district = "1"
      $scope.state_district = {state: $scope.state_district.state, district: $scope.state_district.district}
      d3.select('.districts').selectAll('path').classed('selected', false)
      district_element = d3.select(d3.select('.districts').selectAll('path').filter((d, i) -> return this.textContent == "#{$scope.state_district.state}-#{$scope.state_district.district}")[0][0])
      district_element.attr('class', 'selected')
      if $scope.map_width is 960 
        district_element.call($scope.zoomIn)
      else unless $scope.usMap.text().slice(0, 2) is $scope.state_district.state
          $("#map_holder").html('')
          $scope.drawMapByState($scope.state_to_FIPS[$scope.state_district.state])

    $scope.drawMap = () ->
      ready = (error, us, congress) ->
        $scope.usMap.append("defs").append("path").attr("id", "land").datum(topojson.feature(us, us.objects.land)).attr "d", path
        $scope.usMap.append("clipPath").attr("id", "clip-land").append("use").attr "xlink:href", "#land"
        district = $scope.usMap.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(topojson.feature(congress, congress.objects.districts).features).enter().append("path").attr("d", path).text (d) ->
          if $scope.FIPS_to_state[d.id / 100 | 0] then "#{$scope.FIPS_to_state[d.id / 100 | 0][0]}-#{d.id % 100}"
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
            $scope.selected.state = district_id.slice(0, 2)
            $scope.selected.district = district_id.slice(3, 6)
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
        .attr("class", "full-display")
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
            $scope.selected.state = data[0].state
            $scope.selected.district = data[0].district
          else console.log "Error, Senator/Rep not found."
      else console.log "No parameter"

    $scope.drawMapByState = (state_FIPS) ->
      state_districts = []
      ready = (error, us, congress) ->
        for obj in topojson.feature(congress, congress.objects.districts).features
          if obj.id and JSON.stringify(obj.id).slice(0, -2) is state_FIPS
            state_districts.push(obj)
        district = $scope.usMap.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(state_districts).enter().append("path").attr("d", path).text (d) ->
          if $scope.FIPS_to_state[d.id / 100 | 0] then "#{$scope.FIPS_to_state[d.id / 100 | 0][0]}-#{d.id % 100}"
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

      $scope.map_width = 220
      height = 220
      path = d3.geo.path()
      svg = d3.select("#map_holder").append("svg").attr("width", $scope.map_width).attr("height", height)
      $scope.usMap = svg.append("g").attr("id", "map_with_districts")
      dialog = d3.select("#map_dialog")
        .attr("class", "mobile-display")
        .style("opacity", 1e-6)
        .style("z-index", "15")
      tooltip = $scope.makeTooltip()
      $scope.makeMapGradients()
      queue().defer(d3.json, "data/us.json").defer(d3.json, "data/us-congress-113.json").await ready

    $scope.changeMapSize = (windowSize) ->
      console.log "changeMapSize called"
      if windowSize <= 600 and $scope.map_width is 0
        unless $scope.state_district.state
          $scope.drawMapByState("6")
        else $scope.drawMapByState($scope.state_to_FIPS[$scope.state_district.state])
      else if windowSize > 600 and $scope.map_width is 0
        $scope.drawMap()
      else if windowSize <= 600 and $scope.map_width is 960
        $("#map_holder").html('')
        unless $scope.state_district.state
          $scope.drawMapByState("6")
        else $scope.drawMapByState($scope.state_to_FIPS[$scope.state_district.state])
      else if windowSize >  600 and $scope.map_width is 220
        $("#map_holder").html('')
        $scope.drawMap()



    $scope.defaultFocus()

    $scope.$watch('state_district', (newVals, oldVals) ->
      if $scope.state_district.state
        $scope.setDistrictData(newVals, oldVals)
        $scope.highlightDistrict()
    , true)

    $scope.$watch('district_reps', (newVals, oldVals) ->
      if $scope.district_reps.length and $scope.state_district.state
        $scope.showDistrictDialog()
    , true)

    $scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> $scope.changeMapSize(newValue)) )
    window.onresize = (()-> $scope.$apply())

  ]
