'use strict'

angular.module('appApp')
  .controller 'DistrictCtrl', ['$scope', '$window', 'ApiGet', ($scope, $window, ApiGet) ->
    $scope.supportGeo = $window.navigator
    $scope.position = null
    $scope.state_district = {state: null, district: null}
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

    $scope.setDistrict = (error, data) ->
      if not error
        $scope.state_district = {state: data[0].state, district: data[0].district}
      else
        console.log "Error: ", error

    $scope.highlightDistrict = () ->
      if $scope.state_district.state
        $scope.district_element = d3.select(d3.selectAll('title').filter((d, i) -> return this.textContent == "#{$scope.state_district.state}-#{$scope.state_district.district}")[0][0].parentElement)
        $scope.district_element.attr('class', 'selected')
        $scope.bounding_box = $scope.district_element[0][0].getBoundingClientRect()
        $scope.district_element.call($scope.zoomIn)
        
 
    $scope.drawMap = () ->
      ready = (error, us, congress) ->
        $scope.usMap.append("defs").append("path").attr("id", "land").datum(topojson.feature(us, us.objects.land)).attr "d", path
        $scope.usMap.append("clipPath").attr("id", "clip-land").append("use").attr "xlink:href", "#land"
        district = $scope.usMap.append("g").attr("class", "districts").attr("clip-path", "url(#clip-land)").selectAll("path").data(topojson.feature(congress, congress.objects.districts).features).enter().append("path").attr("d", path).text (d) ->
          "#{$scope.FIPS_to_state[d.id / 100 | 0]}-#{d.id % 100}"
        district.on("mouseover", () ->
          return tooltip.style("visibility", "visible").text(d3.select(this).text())
        ).on("mousemove", () -> 
          return tooltip.style("top", (event.pageY-10)+"px").style("left", (event.pageX+10+"px"))
        ).on("mouseout", () -> 
          return tooltip.style("visibility", "hidden"))
        $scope.usMap.append("path").attr("class", "district-boundaries").attr("clip-path", "url(#clip-land)").datum(topojson.mesh(congress, congress.objects.districts, (a, b) ->
          (a.id / 1000 | 0) is (b.id / 1000 | 0)
        )).attr "d", path
        $scope.usMap.append("path").attr("class", "state-boundaries").datum(topojson.mesh(us, us.objects.states, (a, b) ->
          a isnt b
        )).attr "d", path
      width = 960
      height = 500
      path = d3.geo.path()
      svg = d3.select("#map_holder").append("svg").attr("width", width).attr("height", height)
      $scope.usMap = svg.append("g").attr("id", "map_with_districts")
      tooltip = d3.select("#map_holder")
        .append("div")
        .style("position", "absolute")
        .style("z-index", "10")
        .style("visibility", "hidden")
      queue().defer(d3.json, "views/us.json").defer(d3.json, "views/us-congress-113.json").await ready

    $scope.zoomIn = (d) ->
      element = d.node()
      bbox = element.getBBox()
      x = bbox.x + bbox.width/2
      y = bbox.y + bbox.height/2
      scale = 10
      $scope.usMap.transition().duration(750).attr("transform", "translate(" + 960 / 2 + "," + 600 / 2 + ")scale(" + scale + ")translate(" + -x + "," + -y + ")").style "stroke-width", 1.5 / scale + "px"

    $scope.drawMap()

    $scope.$watch('state_district', $scope.highlightDistrict);

  ]