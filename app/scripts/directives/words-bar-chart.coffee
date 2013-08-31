'use strict';

angular.module('appApp.directives')
  .directive 'wordsBarChart', ['$filter', ($filter)->
    restrict: 'E'
    scope:
      data: '='
      onClick: '&'

    link: (scope, element, attrs)->
      canvas = d3.select(element[0])
        .append("svg")
        .attr("width", "100%")

      tooltip_div = d3.select(element[0]).append("div")
        .attr("class", "tooltip tooltip_words")
        .style("opacity", 1e-6)

      # on window resize, redraw d3 canvas
      scope.$watch( (-> angular.element(window)[0].innerWidth), (-> scope.drawBarChart(scope.data)) )
      window.onresize = (-> scope.$apply())
      scope.$watch 'data', (newVals, oldVals)->
        scope.drawBarChart(newVals, oldVals)
      # deep check for the watch function
      , true

      scope.tooltipText = (data)->
        "The word <span class='red'>#{data.ngram}</span> has been said <span class='red'>#{data.count}</span> times."

      scope.drawBarChart = (newVals, oldVals)->
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
              .on("mouseover", -> tooltip_div.transition().style("opacity", 1) )
              .on("mousemove", (d, i)->
                tooltip_div
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY) + "px")
                .html(scope.tooltipText(d))
              )
              .on("click", (d, i)-> scope.onClick({item: d}) )
              .on("mouseout", (()-> tooltip_div.transition().style("opacity", 1e-6)) )
              .classed("wordsBarItem", true)
              .attr("height", 30)
              .attr("width", 0)
              .attr("x", 10)
              .attr("y", ((d, i)-> i * 35))
              .transition()
                .duration(1000)
                .attr("width", ((d)-> d.count/(max/width)))

          canvas.selectAll(".wordsBarText")
            .data(newVals)
            .enter()
              .append("text")
              .on("mouseover", -> tooltip_div.transition().style("opacity", 1) )
              .on("mousemove", (d, i)->
                tooltip_div
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY) + "px")
                .html(scope.tooltipText(d))
              )
              .on("click", (d, i)-> scope.onClick({item: d}) )
              .on("mouseout", (()-> tooltip_div.transition().style("opacity", 1e-6)) )
              .attr("fill", "#eee")
              .classed("wordsBarText", true)
              .attr("y", ((d, i)-> i * 35 + 22))
              .attr("x", 15)
              .text((d)-> d.ngram)
              .transition()
                .duration(1000)
                .attr("fill", "#222")

          canvas.selectAll(".wordsBarCount")
            .data(newVals)
            .enter()
              .append("text")
              .on("mouseover", -> tooltip_div.transition().style("opacity", 1) )
              .on("mousemove", (d, i)->
                tooltip_div
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY) + "px")
                .html(scope.tooltipText(d))
              )
              .on("click", (d, i)-> scope.onClick({item: d}) )
              .on("mouseout", (()-> tooltip_div.transition().style("opacity", 1e-6)) )
              .attr("fill", "#eee")
              .attr("text-anchor", "end")
              .classed("wordsBarText", true)
              .attr("y", ((d, i)-> i * 35 + 22))
              .attr("x", (d)->
                normal = d.count/(max/width)
                if normal >= 200
                  normal
                else
                  9000
              )
              .text((d)-> d.count)
              .transition()
                .duration(1000)
                .attr("fill", "#222")


      scope.drawBarChart()
  ]