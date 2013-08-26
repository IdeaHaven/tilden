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
        scope.$watch 'data', (newVals, oldVals) ->
          console.log newVals, oldVals
          svg.selectAll('*').remove
          if not newVals
            return # no change, do nothing

          this_data = [-newVals.amount2, newVals.amount1]

          x0 = Math.max(-d3.min(this_data), d3.max(this_data))  

          x = d3.scale.linear()
            .domain([-x0, x0])
            .range([0, '100%'])
            .nice()

          svg.selectAll("rect")
            .data(this_data)
            .enter().append("rect")
            .attr('class', (d, i) ->
              return 'bar' + (i+1)
            ).attr("x", (d, i) ->
              return x(Math.min(0, d))
            ).attr("y", 0)
            .attr("width", x)
            .attr("height", 30)

      scope.drawBarChart()

  ]
