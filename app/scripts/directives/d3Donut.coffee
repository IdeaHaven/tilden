'use strict';

angular.module('appApp.directives')
  .directive 'd3Donut', [->
    restrict: 'E'
    scope:
      data: '='
      onClick: '&'
    link: (scope, element, attrs)->

      # on window resize, redraw d3 canvas
      scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawD3()) )
      window.onresize = (()-> scope.$apply())


      scope.drawD3 = ()->

        radius = (d3.select(element[0])[0][0].offsetWidth) / 2
        τ = 2 * Math.PI # http://tauday.com/tau-manifesto

        arc = d3.svg.arc()
          .innerRadius(radius - 5)
          .outerRadius(radius - 15)
          .startAngle(0);

        svg = d3.select(element[0]).append("svg")
          .attr("width", "100%")
          .attr("height", radius * 2)
        .append("g")
          .attr("transform", "translate(" + radius + "," + radius + ")");

        background = svg.append("path")
          .datum({endAngle: τ})
          .style("fill", "#ddd")
          .attr("d", arc);

        foreground = svg.append("path")
          .datum({endAngle: 0.0 * τ})
          .style("fill", "orange")
          .attr("d", arc);

        arcTween = (transition, newAngle)->
          transition.attrTween "d", (d)->
            interpolate = d3.interpolate(d.endAngle, newAngle);
            return (t)->
              d.endAngle = interpolate(t);
              return arc(d);

        foreground.transition()
          .duration(750)
          .call(arcTween, 0.75 * τ);


      # initial run
      scope.drawD3()
  ]