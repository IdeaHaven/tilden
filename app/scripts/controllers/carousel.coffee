'use strict'

angular.module('appApp.controllers')
  .controller 'CarouselCtrl', ['$scope', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ]
    $scope.myInterval = 5000
    slides = $scope.slides = [];
    $scope.addSlide = ->
      newWidth = 200 + ((slides.length + (25 * slides.length)) % 150);
      slides.push
        image: 'http://placekitten.com/' + newWidth + '/200',
        text: 'my text'

    $scope.addSlide()
    $scope.addSlide()

  ]
