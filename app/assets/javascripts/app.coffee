app = angular.module('MPApp',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
])

app.filter 'startFrom', ->
  (input, start) ->
    start = +start
    return input.slice start

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
      for i in [1..20]
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

  $scope.hoverIn = () ->
     $scope.hoverEdit = true

  $scope.hoverOut = () ->
     $scope.hoverEdit = false


app.controller 'UsersPageCtrl', ($scope, $http) ->
  
  $scope.users = []
  $scope.tableVisible = true
  $scope.profileVisible = false
  $scope.displayedUser
  $scope.editProfileVisible = false
  $scope.updatedUser

  $scope.init = (value) ->
    $scope.user_display = {}
    $scope.editProfileVisible = {}
    if $scope.users.length == $scope.listSize
      return
    else if $scope.users.length == 0
      $scope.listSize = 0
      $scope.getUserListSize()
      $scope.fetchNumber = 0
    $scope.getUsers(($scope.fetchNumber))
    $scope.currentPage = 0
    $scope.pagination(50)

  $scope.pagination = (ps) ->
    $http.post('/users/set_page_size', {
      'pageSize': ps
    })
    .success((value) ->
      $scope.pageSize = value[0]
      $scope.div = value[1]
      $scope.totalSize = value[2]
      )

  $scope.getUsers = (fn) ->

    $http.post('/users/get_users_ng', {
      'fetchNumber': fn
    })
    .success((receivedUsers) ->
      console.log receivedUsers
      for user in receivedUsers
        $scope.users.push user
        $scope.user_display[user.object.id] = false
        $scope.editProfileVisible[user.object.id] = false

      $scope.fetchNumber+=1
      console.log $scope.users.length
      console.log $scope.listSize

      if $scope.users.length < $scope.listSize
        $scope.getUsers($scope.fetchNumber)
      )

  $scope.getUserListSize = () ->
    $http.get('/users/get_users_list_ng')
    .success((listSize) ->
      $scope.listSize = listSize
      )

  $scope.showTable = (decision) ->
    $scope.tableVisible = decision
    if decision == true 
      $scope.showUser(false)
      $scope.editProfileVisible = false
     

  $scope.showUser = (user_id) ->
    # if userID == false
    #   $scope.profileVisible = false
    #   return
    # else
    #   for user in $scope.users
    #     if user.object.id == userID
    #       $scope.displayedUser = user
    #       $scope.showTable(false)
    #       $scope.editProfileVisible = false
    #       $scope.profileVisible = true
    #       return
    console.log $scope.user_display[user_id]
    $scope.user_display[user_id] = !$scope.user_display[user_id]
    $scope.editProfileVisible[user_id] = false

  $scope.hidePanel = (user_id) ->
    $scope.editProfileVisible[user_id] = !$scope.editProfileVisible[user_id]

  $scope.editUser = (user) ->
    # $scope.showUser(false)
    $scope.editProfileVisible[user.object.id] = !$scope.editProfileVisible[user.object.id]
    $scope.updatedUser = user
    console.log $scope.updatedUser.object.name

  $scope.redirectToRoles = (roleID) ->
    $http.post('/roles/update', {
      'id': roleID
    })
    .success(() ->
      )

  $scope.saveUser = (user) ->
    if $scope.updatedUser.password == $scope.confirm_password
      $http.post('/users/update', {
        'user': user
      })
      .success((response) ->
          console.log response
        )
      $scope.editProfileVisible[user.object.id] = !$scope.editProfileVisible[user.object.id]

  $scope.deleteUser = (user) ->
    
    $http.post('/users/delete_user_ng', {
      'id': user.object.id
    })
    .success((response) ->
      console.log response
      )
    index = $scope.users.indexOf(user);
    console.log index
    $scope.users.splice(index,1)

  $scope.gotoTop = () ->
    $("html, body").animate({ scrollTop: 0 }, 600)
    ''
    

# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

