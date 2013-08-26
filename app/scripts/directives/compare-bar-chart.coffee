'use strict';

angular.module('appApp.directives')
  .directive 'compareBarChart', [->
    restrict: 'E'
    scope:
      data: '='
      onClick: '&'

    link: (scope, element, attrs) ->    
      # on window resize, redraw d3 canvas
      scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawBarChart()) )
      window.onresize = (()-> scope.$apply())

      svg = d3.select(element[0]).append("svg")
        .attr('class', 'bar-holder')
        .style('fill', '#ddd')
        .attr('width', "100%") # arbitrary
        .attr('height', 100) # arbitrary
      
      scope.drawBarChart = () ->
        raw_data = JSON.parse(d3.select(element[0]).attr('data'))
        this_data = [-raw_data[0], raw_data[1]]
        x0 = Math.max(-d3.min(this_data), d3.max(this_data))  

        x = d3.scale.linear()
          .domain([-x0, x0])
          .range([0 , 900]) #arbitrary
          .nice()

        svg.selectAll("rect")
          .data(this_data)
          .enter().append("rect")
          .attr('class', (d, i) ->
            return 'bar' + (i+1)
          ).attr("x", x(0))
          .attr("y", 0)
          .attr("width", 0)
          .attr("height", 30)
          .transition()
            .duration(1000)
            .attr("width", (d, i) -> 
              return Math.abs(x(d) - x(0))
            ).attr("x", (d, i) -> return x(Math.min(0, d)))

      scope.drawBarChart()

  ]
