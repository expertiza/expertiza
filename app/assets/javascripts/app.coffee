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
  
  $scope.users = []
  $scope.tableVisible = true
  $scope.profileVisible = false
  $scope.displayedUser
  $scope.editProfileVisible = false
  $scope.updatedUser

  $scope.init = () ->
    if $scope.users.length == $scope.listSize
      return
    else if $scope.users.length == 0
      $scope.listSize = 0
      $scope.getUserListSize()
      $scope.fetchNumber = 0
    $scope.getUsers(($scope.fetchNumber))


  $scope.getUsers = (fn) ->
    $http.post('/users/get_users_ng', {
      'fetchNumber': fn
    })
    .success((receivedUsers) ->
      for user in receivedUsers
        $scope.users.push(user)
      
      $scope.fetchNumber+=1

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
     

  $scope.showUser = (userID) ->
    if userID == false
      $scope.profileVisible = false
      return
    else
      for user in $scope.users
        if user.object.id == userID
          $scope.displayedUser = user
          $scope.showTable(false)
          $scope.editProfileVisible = false
          $scope.profileVisible = true
          return

  $scope.editUser = () ->
    $scope.showUser(false)
    $scope.editProfileVisible = true
    $scope.updatedUser = $scope.displayedUser
    console.log $scope.updatedUser.object.name

  $scope.redirectToRoles = (roleID) ->
    $http.post('/roles/update', {
      'id': roleID
    })
    .success(() ->
      )

  $scope.saveUser = () ->

    $scope.displayedUser = $scope.updatedUser
    for user in $scope.users
      if $scope.displayedUser.object.id == user.object.id
        console.log "new user saved"
        $http.post('/users/update', {
          'user': user
        })
        .success((response) ->
            console.log response
          )
        user = $scope.displayedUser
        $scope.showUser($scope.displayedUser.object.id)
        break
    

# app.directive 'testdirective', () ->
#   templateUrl: 'test.html'
#   link: (scope, element, attr) -> 
#     console.log "in directive"
#     scope.name = 'Heyhey'

