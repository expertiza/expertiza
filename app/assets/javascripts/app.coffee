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
  $scope.display = {}
  $scope.display["Assignments"] = false
  $scope.display["Courses"] = false
  $scope.display["Questionnaires"] = false
  $scope.allData = {}

  $scope.showCellContent = (name, directory) ->
    key = name + "|" + directory
    $scope.cellCentent = $scope.allData[key]
    console.log $scope.cellCentent
    $scope.subtable = 'hey'
    $scope.display[key] = !$scope.display[key]
    $scope.cellDisplay = $scope.display[key]

  $scope.fetchCellContent = (nodeType, node) ->
    console.log nodeType
    console.log node
    $scope.newParams = {}
    $scope.newParams["sortvar"] = $scope.angularParams["sortvar"]
    $scope.newParams["sortorder"] = $scope.angularParams["sortorder"]
    $scope.newParams["search"] = $scope.angularParams["search"]
    $scope.newParams["show"] = $scope.angularParams["show"]
    $scope.newParams["user_id"] = $scope.angularParams["user_id"]
    key = node.name + "|" + node.directory
    $scope.newParams["key"] = key
    # console.log key
    if nodeType == 'Assignments'
      $scope.newParams["nodeType"] = 'AssignmentNode'
    else if nodeType == 'Courses'
      $scope.newParams["nodeType"] = 'CourseNode'
    else if nodeType == 'Questionnaires'
      $scope.newParams["nodeType"] = 'FolderNode'
    else
      $scope.newParams["nodeType"] = nodeType

    $scope.newParams["child_nodes"] = node.nodeinfo
    $http.post('/tree_display/get_children_node_2_ng', {
      "angularParams": $scope.newParams
      })
    .success((data) ->
      if data.length > 0
        for newNode in data
          if not $scope.allData[newNode.key]
            $scope.allData[newNode.key] = []
          $scope.allData[newNode.key].push newNode
          $scope.fetchCellContent(newNode.type, newNode)

      )


  $scope.init = (value) ->
    $scope.angularParams = JSON.parse(value)
    $http.post('/tree_display/get_children_node_ng', {
      "angularParams": $scope.angularParams
      })
    .success((data) ->
      $scope.tableContent = data
      console.log data
      for nodeType, outerNode of $scope.tableContent
        # outerNode is the Assignments/Courses/Questionnaires
        for node in outerNode
          $scope.fetchCellContent(nodeType, node)
      )

  $scope.show_children = (type) ->
    $scope.display[type] = !$scope.display[type]


app.controller 'UsersPageCtrl', ($scope, $http) ->
  $http.get('/users/get_users_ng')
        .success((data) ->
          console.log data
          $scope.name = data
          )

# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

