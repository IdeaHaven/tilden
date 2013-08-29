'use strict';

angular.module('appApp.directives')
  .directive 'wordsBarChart', ['$filter', ($filter)->
    restrict: 'E'
    scope:
      data: '='

    link: (scope, element, attrs) ->
      canvas = d3.select(element[0])
        .append("svg")
        .attr("width", "100%")
        .attr("height", 545)

      # on window resize, redraw d3 canvas
      scope.$watch( (()-> angular.element(window)[0].innerWidth), ((newValue, oldValue)-> scope.drawBarChart()) )
      window.onresize = (()-> scope.$apply())
      
      scope.drawBarChart = () ->
        scope.$watch 'data', (newVals, oldVals)->
          console.log 'data', newVals, oldVals
          canvas.selectAll("*").remove()
          unless newVals
            return
          width = d3.select(element[0])[0][0].offsetWidth
          max = Math.max.apply(Math, _.map(newVals, ((val)-> val.count)))
          canvas.selectAll("rect")
            .data(newVals)
            .enter()
              .append("rect")
              .classed("wordsBarItem", true)
              .attr("height", 30)
              .attr("width", 0)
              .attr("y", ((d, i)-> i * 35))
              .transition()
                .duration(1000)
                .attr("width", ((d)-> d.count/(max/width) * 0.9))
          labels = canvas.selectAll("text").data(newVals).enter()
          labels.append("text")
            .attr("fill", "#1047A9")
            .classed("wordsBarText", true)
            .attr("y", ((d, i)-> i * 35 + 22))
            .attr("x", 5)
            .text((d)-> d.ngram)
            .transition()
              .duration(1000)
              .attr("fill", "#fff")
          labels.append("text")
            .attr("fill", "#fff")
            .classed("wordsBarText", true)
            .attr("y", ((d, i)-> i * 35 + 22))
            .attr("x", ((d)-> d.count/(max/width) * 0.9 + 5))
            .text((d)-> d.count)
            .transition()
              .duration(1000)
              .attr("fill", "#000")

      scope.drawBarChart()
  ]