'use strict';
# scale is number to base the percentage from
# contributor is an object with the following properties: total_amount, name

angular.module('appApp.directives')
  .directive 'd3Donut', ['ApiGet', (ApiGet)->
    restrict: 'E'
    scope:
      scale: '='
      onClick: '&'
      contributor: '='
    link: (scope, element, attrs)->

      scope.change = ->
        if scope.contributor
          scope.percent = (scope.contributor.total_amount / scope.scale)
          # get favicon url from contributor name
          ApiGet.own "favicon?company=\"#{scope.contributor.name}\"", scope.draw_favicon, this
          scope.drawD3()

      # on window resize, redraw d3 canvas
      scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.change()) )
      window.onresize = (-> scope.$apply())
      # make the canvas once
      canvas = d3.select(element[0]).append("svg")
      τ = 2 * Math.PI # http://tauday.com/tau-manifesto
      scope.draw_favicon = (err, data)->
        # check if api callback and set data
        if data then scope.favicon = data.favicon.url
        # replace company text with favicon if available
        if scope.favicon
          canvas.append("image")
            .attr("xlink:href", scope.favicon)
            .attr("width", scope.radius)
            .attr("height", scope.radius)
            .attr("transform", "translate(#{scope.radius/2},#{scope.radius/2})")

      # draw d3 here on the canvas defined above
      scope.drawD3 = ->
        #remove all old elements including favicon
        canvas.selectAll('*').remove()
        # define the radius based on element width
        scope.radius = (d3.select(element[0])[0][0].offsetWidth) / 2
        # pass click event through to controller
        canvas.on 'click', ->
          scope.onClick({item: scope.company})
        # put contributor name in circle until image is loaded from API
        canvas.append("text")
          .style("text-anchor", "middle")
          .classed("d3Donut-company", true)
          .attr("width", scope.radius)
          .attr("transform", "translate(#{scope.radius},#{scope.radius * 2 + 10})")
          .text(scope.contributor.name)
        canvas.append("text")
          .style("text-anchor", "middle")
          .classed("d3Donut-company", true)
          .attr("width", scope.radius)
          .attr("transform", "translate(#{scope.radius},#{scope.radius * 2 + 25})")
          .text(scope.contributor.total_amount)
        # create the paths for each donute section
        arc = d3.svg.arc()
          .innerRadius(scope.radius - 5)
          .outerRadius(scope.radius - 15)
          .startAngle(0)
        # define the tweening function for arc pieces
        arcTween = (transition, newAngle)->
          transition.attrTween "d", (d)->
            interpolate = d3.interpolate(d.endAngle, newAngle)
            (t)->
              d.endAngle = interpolate(t)
              arc(d)
        # set the new attrs based on element width
        svg = canvas
          .attr("width", "100%")
          .attr("height", scope.radius * 2 + 35)
        .append("g")
          .attr("transform", "translate(#{scope.radius},#{scope.radius})")
        # set the background donut
        background = svg.append("path")
          .datum({endAngle: τ})
          .classed("d3Donut-background", true)
          .attr("d", arc)
        # set the foreground donut
        foreground = svg.append("path")
          .datum({endAngle: 0.0 * τ})
          .classed("d3Donut-foreground", true)
          .attr("d", arc)
          .transition()
            .duration(750)
            .call(arcTween, scope.percent * τ)

      # watch for attribute changes and call the changed function
      scope.$watch 'contributor', (-> scope.change())
      scope.$watch 'scale', (-> scope.change())
  ]