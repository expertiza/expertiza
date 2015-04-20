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
    console.log $scope.allData
    key = name + "|" + directory
    $scope.cellCentent = $scope.allData[key]
    console.log $scope.cellCentent

  $scope.fetchCellContent = () ->
    for nodeType, outerNode of $scope.tableContent
      # outerNode is the Assignments/Courses/Questionnaires
      for node in outerNode
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
        if nodeType == 'Courses'
          $scope.newParams["nodeType"] = 'CourseNode'
        if nodeType == 'Questionnaires'
          $scope.newParams["nodeType"] = 'FolderNode'
        # console.log "1. "
        # console.log node.nodeinfo
        # console.log "2. "
        # console.log $scope.newParams["child_nodes"]
        $scope.newParams["child_nodes"] = node.nodeinfo
        # console.log "3. "
        # console.log $scope.newParams["child_nodes"]
        # console.log "4. "
        $http.post('/tree_display/get_children_node_2_ng', {
          "angularParams": $scope.newParams
          })
        .success((data) ->
          if data.length > 0
            console.log data
            for newNode in data
              if not $scope.allData[newNode.key]
                $scope.allData[newNode.key] = []
              # console.log $scope.allData[newNode.key]
              $scope.allData[newNode.key].push newNode
              # console.log $scope.allData[newNode.key]
          )


  $scope.init = (value) ->
    $scope.angularParams = JSON.parse(value)
    $http.post('/tree_display/get_children_node_ng', {
      "angularParams": $scope.angularParams
      })
    .success((data) ->
      $scope.tableContent = data
      console.log data
      $scope.fetchCellContent()
      )

  $scope.show_children = (type) ->
    $scope.display[type] = !$scope.display[type]


# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

