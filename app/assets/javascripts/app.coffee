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

app.controller 'TreeCtrl', ($scope, $http, $location) ->
  console.log "in TreeCtrl"
  $scope.display = {}
  $scope.allData = {}

  $scope.predicate = ''

  $scope.showCellContent = (name, directory) ->
    key = name + "|" + directory
    if !$scope.display[key] || !$scope.cellContent
      $scope.cellContent = $scope.allData[key]
      console.log $scope.cellContent
    else
      $scope.cellContent = ''
    $scope.display[key] = !$scope.display[key]

  $scope.fetchCellContent = (nodeType, node) ->
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
          $scope.display[newNode.key] = false
          $scope.allData[newNode.key].push newNode
          $scope.fetchCellContent(newNode.type, newNode)

      )

  $scope.getMoreContent = (type, mode) ->
    if mode == 1
      for i in [1..10]
        if not $scope.tableContent[type][$scope.lastLoadNum[type]]
          break
        $scope.displayTableContent[type].push $scope.tableContent[type][$scope.lastLoadNum[type]]
        $scope.lastLoadNum[type] += 1
    else
      while true
        if not $scope.tableContent[type][$scope.lastLoadNum[type]]
          break
        $scope.displayTableContent[type].push $scope.tableContent[type][$scope.lastLoadNum[type]]
        $scope.lastLoadNum[type] += 1

  $scope.init = (value) ->
    $scope.angularParams = JSON.parse(value)
    $http.post('/tree_display/get_children_node_ng', {
      "angularParams": $scope.angularParams
      })
    .success((data) ->
      $scope.tableContent = {}
      $scope.displayTableContent = {}
      $scope.lastLoadNum = {}
      $scope.typeList = []
      console.log data
      for nodeType, outerNode of data
        $scope.tableContent[nodeType] = []
        $scope.lastLoadNum[nodeType] = 0
        $scope.displayTableContent[nodeType] = []
        $scope.typeList.push nodeType
        # outerNode is the Assignments/Courses/Questionnaires
        for node in outerNode
          $scope.tableContent[nodeType].push node
          $scope.fetchCellContent(nodeType, node)
        $scope.getMoreContent(nodeType, 1)
      )

  $scope.gotoTop = () ->
    $("html, body").animate({ scrollTop: 0 }, 600)
    ''

  $scope.initTable = () ->
    $scope.searchText = ''


app.controller 'UsersPageCtrl', ($scope, $http) ->
  $scope.init = (value) ->
    $scope.users = JSON.parse(value)
    console.log $scope.users

# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

