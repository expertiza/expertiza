app = angular.module('MPApp',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
])

app.controller 'testCtrl', ($scope) ->
  console.log "chojfdajfaj"
  $scope.name = "Hey"

