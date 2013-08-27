'use strict';

angular.module('appApp.directives')
  .directive 'compareBarChart', [->
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
        # label = "Test Label"
        x0 = Math.max(-d3.min(this_data), d3.max(this_data))  
        d3.select(element[0]).selectAll('*').remove()
        svg = d3.select(element[0]).append("svg")
          .attr('class', 'bar-holder')
          .style('fill', '#ddd')
          .attr('width', "100%") # arbitrary
          .attr('height', 100) # arbitrary

        x = d3.scale.linear()
          .domain([-x0, x0])
          .range([0 , "100%"])
          .nice()

        console.log "-40000, ", x(-35000)
        console.log "0, ", x(0)
        console.log "+35000, ", x(35000)

        svg.selectAll("rect")
          .data(this_data)
          .enter().append("rect")
          .attr('class', (d, i) ->
            return 'bar' + (i+1)
          ).attr("x", (d, i) ->
            if i is 0 then x(-35000)
            else x(35000)
          ).attr("y", 0)
          .attr("width", 0)
          .attr("height", 30)
          .transition()
            .duration(1000)
            .attr("width", (d, i) -> 
              if i is 0
                Math.abs(parseInt(x(d)) - parseInt(x(-35000))) + "%"
              else Math.abs(parseInt(x(d)) - parseInt(x(35000))) + "%"

            ).attr("x", (d, i) -> 
              if i is 0 then  x(Math.min(-35000, d))
              else x(35000))

        svg.selectAll('text')
          .data(this_data)
          .enter()
            .append("text")
            .attr("fill", "Black")
            .attr("y", 20)
            .attr("x", (d, i) ->
              if i is 0 then x(40000)
              else x(-40000)
            ).attr("text-anchor", (d, i) ->
              if i is 0 then "start"
              else "end"
            ).text( ((d)-> Math.abs(d)) )

  ]
