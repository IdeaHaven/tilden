'use strict';

angular.module('appApp.directives')
  .directive 'wordsBarChart', ['$filter', ($filter)->
    restrict: 'E'
    scope:
      data: '='

    link: (scope, element, attrs)->
      canvas = d3.select(element[0])
        .append("svg")
        .attr("width", "100%")

      # on window resize, redraw d3 canvas
      scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.drawBarChart()) )
      window.onresize = (-> scope.$apply())

      scope.drawBarChart = ->
        scope.$watch 'data', (newVals, oldVals)->
          console.log 'data changed!!', newVals, oldVals
          canvas.selectAll("*").remove()
          unless newVals
            return

          #set variable
          width = d3.select(element[0])[0][0].offsetWidth - 20
          height = scope.data.length * 35
          max = Math.max.apply(Math, _.map(newVals, ((val)-> val.count)))

          #set height based on data
          canvas.attr("height", height)

          canvas.selectAll("rect")
            .data(newVals)
            .enter()
              .append("rect")
              .classed("wordsBarItem", true)
              .attr("height", 30)
              .attr("width", 0)
              .attr("x", 10)
              .attr("y", ((d, i)-> i * 35))
              .transition()
                .duration(1000)
                .attr("width", ((d)-> d.count/(max/width)))
          labels = canvas.selectAll("text").data(newVals).enter()
          labels.append("text")
            .attr("fill", "#eee")
            .classed("wordsBarText", true)
            .attr("y", ((d, i)-> i * 35 + 22))
            .attr("x", 15)
            .text((d)-> d.ngram)
            .transition()
              .duration(1000)
              .attr("fill", "#222")
          labels.append("text")
            .attr("fill", "#fff")
            .classed("wordsBarText", true)
            .attr("text-anchor", "end")
            .attr("y", ((d, i)-> i * 35 + 22))
            .attr("x", (d)->
              normal = d.count/(max/width)-5
              if normal >= 200 then normal
            )
            .text((d)-> d.count)
            .transition()
              .duration(1000)
              .attr("fill", "#222")
        # deep check for the watch function
        , true

      scope.drawBarChart()
  ]