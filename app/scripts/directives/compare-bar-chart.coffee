'use strict';

angular.module('appApp.directives')
  .directive 'compareBarChart', ['$filter', ($filter)->
    restrict: 'E'
    scope:
      data1: '='
      data2: '='
      label: '='
      currency: '@'
      onClick: '&'

    link: (scope, element, attrs) ->    
      # on window resize, redraw d3 canvas
      scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawBarChart()) )
      window.onresize = (()-> scope.$apply())

      scope.drawBarChart = () ->
        scope.$watch '[data1, data2]', (newVals, oldVals)->
          d3.select(element[0]).selectAll('*').remove()
          if !newVals[0] or !newVals[1]
            return
          width = $(window).width() - 40
          this_data = [-scope.data1, scope.data2]
          x0 = Math.max(-d3.min(this_data), d3.max(this_data))  
          svg = d3.select(element[0]).append("svg")
            .attr('class', 'bar-holder')
            .style('fill', '#ddd')
            .attr('width', width)
            .attr('height', 30) # arbitrary

          x = d3.scale.linear()
            .domain([-x0, x0])
            .range([0 , width])
            .nice()

          svg.selectAll("rect")
            .data(this_data)
            .enter().append("rect")
            .attr('class', (d, i) ->
              return 'bar' + (i+1)
            ).attr("x", (d, i) ->
              if i is 0 then x(0) - 50
              else x(0) + 50
            ).attr("y", 0)
            .attr("width", 10)
            .attr("height", 30)
            .transition()
              .duration(1000)
              .attr("width", (d, i) -> 
                if i is 0
                  Math.abs(parseInt(x(d)) - parseInt(x(0) - 50))
                else Math.abs(parseInt(x(d)) - parseInt(x(0) + 50))
              ).attr("x", (d, i) -> 
                if i is 0 then  x(Math.min(parseInt(x(0) - 50), d))
                else x(0) + 50)

          svg.selectAll('text')
            .data(this_data)
            .enter()
              .append("text")
              .attr("fill", "Black")
              .attr("y", 20)
              .attr("x", (d, i) ->
                if i is 0 then x(0) - 90
                else x(0) + 90
              ).attr("text-anchor", (d, i) ->
                if i is 0 then "end"
                else "start"
              ).text( (d)-> 
                if scope.currency is "true" then $filter('currency')(Math.abs(d))
                else Math.abs(d)
              )
            
          svg.append("text")
            .attr("fill", "Black")
            .attr("y", 20)
            .attr("x", x(0))
            .attr("text-anchor", "middle")
            .text(scope.label)
  ]
