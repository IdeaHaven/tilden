'use strict';

angular.module('appApp.directives')
  .directive 'd3Donut', [->
    restrict: 'E'
    scope:
      percent: '='
      onClick: '&'
    link: (scope, element, attrs)->
      scope.$watch 'percent', (newValue)->
        # onClick('hey')
        # on window resize, redraw d3 canvas
        scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.drawD3()) )
        window.onresize = (-> scope.$apply())

        canvas = d3.select(element[0]).append("svg")
        τ = 2 * Math.PI # http://tauday.com/tau-manifesto

        scope.drawD3 = ->
          canvas.selectAll('*').remove()
          radius = (d3.select(element[0])[0][0].offsetWidth) / 2

          arc = d3.svg.arc()
            .innerRadius(radius - 5)
            .outerRadius(radius - 15)
            .startAngle(0)

          arcTween = (transition, newAngle)->
            transition.attrTween "d", (d)->
              interpolate = d3.interpolate(d.endAngle, newAngle)
              (t)->
                d.endAngle = interpolate(t)
                arc(d)

          svg = canvas
            .attr("width", "100%")
            .attr("height", radius * 2)
          .append("g")
            .attr("transform", "translate(" + radius + "," + radius + ")")

          background = svg.append("path")
            .datum({endAngle: τ})
            .classed("d3Donut-background", true)
            .attr("d", arc)

          foreground = svg.append("path")
            .datum({endAngle: 0.0 * τ})
            .classed("d3Donut-foreground", true)
            .attr("d", arc)

          foreground.transition()
            .duration(750)
            .call(arcTween, newValue * τ)

        # initial run
        scope.drawD3()
  ]