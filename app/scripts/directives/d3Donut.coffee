'use strict';

angular.module('appApp.directives')
  .directive 'd3Donut', [->
    restrict: 'E'
    scope:
      percent: '='
      onClick: '&'
      company: '='
    link: (scope, element, attrs)->
      scope.$watch 'percent', (newValue)->
        # on window resize, redraw d3 canvas
        scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.drawD3()) )
        window.onresize = (-> scope.$apply())
        # make the canvas once
        canvas = d3.select(element[0]).append("svg")
        τ = 2 * Math.PI # http://tauday.com/tau-manifesto
        # draw d3 here on the canvas defined above
        scope.drawD3 = ->
          #remove all old elements
          canvas.selectAll('*').remove()
          # define the radius based on element width
          radius = (d3.select(element[0])[0][0].offsetWidth) / 2
          # pass click event through to controller
          canvas.on 'click', ->
            scope.onClick({item: scope.company})
          # create the paths for each donute section
          arc = d3.svg.arc()
            .innerRadius(radius - 5)
            .outerRadius(radius - 15)
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
            .attr("height", radius * 2)
          .append("g")
            .attr("transform", "translate(" + radius + "," + radius + ")")
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
              .call(arcTween, newValue * τ)

        # initial run
        scope.drawD3()
  ]