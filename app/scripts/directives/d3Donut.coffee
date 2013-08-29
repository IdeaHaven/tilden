'use strict';
# scale is number to base the percentage from
# contributor is an object with the following properties: total_amount, name

angular.module('appApp.directives')
  .directive 'd3Donut', ['ApiGet', '$filter', (ApiGet, $filter)->
    restrict: 'E'
    scope:
      scale: '='
      onClick: '&'
      contributor: '='
      number: '@'
      label: '@'
      type: '@'

    link: (scope, element, attrs)->

      scope.change = ->
        if scope.contributor
          scope.percent = (scope.contributor[scope.number] / scope.scale)
          if scope.type is 'organization'
            # get favicon url from contributor name
            company = scope.contributor[scope.label].replace(/&/i, "and")
            ApiGet.own "favicon?company=\"#{company}\"", scope.draw_favicon, this
          else
            scope.draw_bio()
          scope.drawD3()

      # make the canvas once
      canvas = d3.select(element[0]).append("svg")
      τ = 2 * Math.PI # http://tauday.com/tau-manifesto
      # on window resize, redraw d3 canvas
      scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.change()) )
      window.onresize = (-> scope.$apply())
      scope.draw_bio = ->
        canvas.append("text")
          .style("text-anchor", "middle")
          .classed("d3Donut-#{scope.type}", true)
          .attr("width", scope.radius)
          .attr("transform", "translate(#{scope.radius},#{scope.radius})")
          .text(scope.contributor[scope.label])

      scope.draw_favicon = (err, data)->
        # check if api callback and set data
        if data then scope.favicon = data.favicon.url
        # replace type text with favicon if available
        if scope.favicon
          canvas.append("image")
            .attr("xlink:href", scope.favicon)
            .attr("width", scope.radius*2/3)
            .attr("height", scope.radius*2/3)
            .attr("transform", "translate(#{scope.radius/3*2},#{scope.radius/3*2})")

      # draw d3 here on the canvas defined above
      scope.drawD3 = ->
        #remove all old elements including favicon
        canvas.selectAll('*').remove()
        # define the radius based on element width
        scope.radius = (d3.select(element[0])[0][0].offsetWidth) / 2
        # pass click event through to controller
        canvas.on 'click', ->
          scope.onClick({item: scope.contributor})
        # put contributor name in circle until image is loaded from API
        canvas.append("text")
          .style("text-anchor", "middle")
          .classed("d3Donut-#{scope.type}", true)
          .attr("width", scope.radius)
          .attr("transform", "translate(#{scope.radius},#{scope.radius * 2 + 10})")
          .text(scope.contributor[scope.label])
        canvas.append("text")
          .style("text-anchor", "middle")
          .classed("d3Donut-#{scope.type}", true)
          .attr("width", scope.radius)
          .attr("transform", "translate(#{scope.radius},#{scope.radius * 2 + 25})")
          .text($filter('currency')(scope.contributor[scope.number]))
        # create the paths for each donute section
        arc = d3.svg.arc()
          .innerRadius(scope.radius - 5)
          .outerRadius(scope.radius - 35)
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