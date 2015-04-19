app = angular.module('MPApp',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
])

app.controller 'MainPageCtrl', ($scope) ->
  console.log "in MainPageCtrl"
  $scope.toDisplay = 0

app.controller 'SidebarCtrl', ($scope) ->
  console.log "in SidebarCtrl"

app.controller 'HeaderAndNavCtrl', ($scope) ->
  console.log "in HeaderAndNavCtrl"

app.controller 'TreeCtrl', ($scope, $http) ->
  console.log "in TreeCtrl"
  $scope.toDisplay = 0

  $scope.init = (value) ->
    console.log eval(value)


  $scope.get_children = () ->
    $http.post('/tree_display/get_children_node_ng', {
      "Msg": "hey"
      })
    .success((data) ->
      console.log data
      )

# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

