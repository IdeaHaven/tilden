'use strict';

angular.module('appApp.directives')
  .directive 'compareBarChart', ['$filter', ($filter)->
    restrict: 'E'
    scope:
      data1: '='
      data2: '='
      label: '='
      onClick: '&'

    link: (scope, element, attrs) ->    
      # on window resize, redraw d3 canvas
      scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawBarChart()) )
      window.onresize = (()-> scope.$apply())

      scope.drawBarChart = () ->
        this_data = [-scope.data1, scope.data2]
        x0 = Math.max(-d3.min(this_data), d3.max(this_data))  
        d3.select(element[0]).selectAll('*').remove()
        svg = d3.select(element[0]).append("svg")
          .attr('class', 'bar-holder')
          .style('fill', '#ddd')
          .attr('width', "100%")
          .attr('height', 30) # arbitrary

        x = d3.scale.linear()
          .domain([-x0, x0])
          .range([0 , "100%"])
          .nice()

        svg.selectAll("rect")
          .data(this_data)
          .enter().append("rect")
          .attr('class', (d, i) ->
            return 'bar' + (i+1)
          ).attr("x", (d, i) ->
            if i is 0 then x(x0*0.4 -(x0/2))
            else x(x0 *0.6 -(x0/2))
          ).attr("y", 0)
          .attr("width", 0)
          .attr("height", 30)
          .transition()
            .duration(1000)
            .attr("width", (d, i) -> 
              if i is 0
                Math.abs(parseInt(x(d)) - parseInt(x(x0 *0.4 -(x0/2)))) + "%"
              else Math.abs(parseInt(x(d)) - parseInt(x(x0 *0.6 -(x0/2)))) + "%"

            ).attr("x", (d, i) -> 
              if i is 0 then  x(Math.min(x0 *0.4 -(x0/2), d))
              else x(x0 *0.6 -(x0/2)))

        svg.selectAll('text')
          .data(this_data)
          .enter()
            .append("text")
            .attr("fill", "Black")
            .attr("y", 20)
            .attr("x", (d, i) ->
              if i is 0 then x(x0 *0.65-(x0/2))
              else x(x0 *0.35 -(x0/2))
            ).attr("text-anchor", (d, i) ->
              if i is 0 then "start"
              else "end"
            ).text( (d)-> $filter('currency')(Math.abs(d)) )
          
        svg.append("text")
            .attr("fill", "Black")
            .attr("y", 20)
            .attr("x", x(0))
            .attr("text-anchor", "middle")
            .text(scope.label)


  ]
