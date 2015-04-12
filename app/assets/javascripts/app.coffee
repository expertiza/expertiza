app = angular.module('MPApp',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
])

app.controller 'testCtrl', ($scope) ->
  console.log "in controller"

app.run () ->
  console.log "RUN RUN RUN"

app.directive 'testdirective', () ->
  templateUrl: 'test.html'
  link: (scope, element, attr) -> 
    console.log "in directive"
    scope.name = 'Heyhey'

