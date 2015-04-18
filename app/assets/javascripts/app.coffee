app = angular.module('MPApp',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
])

app.controller 'testCtrl', ($scope) ->
  console.log "in testCtrl"

app.controller 'SidebarCtrl', ($scope) ->
  $scope.$watch('fffffffffffff', (new_value, old_value) ->
    console.log("old_value: " + new_value)
    console.log("new_value: " + new_value)
    )

app.controller 'HeaderAndNavCtrl', ($scope) ->
  console.log "in HeaderAndNavCtrl"

app.run () ->
  console.log "RUN RUN RUN"

app.directive 'testdirective', () ->
  templateUrl: 'test.html'
  link: (scope, element, attr) -> 
    console.log "in directive"
    scope.name = 'Heyhey'

