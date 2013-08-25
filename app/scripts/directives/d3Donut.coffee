'use strict';

angular.module('appApp.directives')
  .directive 'd3Donut', [->
    restrict: 'E'
    scope:
      data: '='
      onClick: '&'
    link: (scope, element, attrs)->

      # # on window resize, redraw d3 canvas
      # scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawD3()) )
      # window.onresize = (()-> scope.$apply())

      # radius = (d3.select(element[0])[0][0].offsetWidth) / 2
      # # color = d3.scale.category20();
      # τ = 2 * Math.PI # http://tauday.com/tau-manifesto

      # # An arc function with all values bound except the endAngle. So, to compute an
      # # SVG path string for a given angle, we pass an object with an endAngle
      # # property to the `arc` function, and it will return the corresponding string.
      # arc = d3.svg.arc()
      #   .innerRadius(radius - 5)
      #   .outerRadius(radius - 20)
      #   .startAngle(0)

      # # Create the SVG container, and apply a transform such that the origin is the
      # # center of the canvas. This way, we don't need to position arcs individually.
      # svg = d3.select(element[0])
      #   .append("svg")
      #   .attr("width", "100%")
      # .append("g")
      #   .attr("transform", "translate(" + radius + "," + radius + ")")

      scope.drawD3 = ()->

        width = 500
        height = 500
        τ = 2 * Math.PI; # http://tauday.com/tau-manifesto

        arc = d3.svg.arc()
          .innerRadius(180)
          .outerRadius(240)
          .startAngle(0);

        svg = d3.select("body").append("svg")
          .attr("width", width)
          .attr("height", height)
        .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

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