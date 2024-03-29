#encoding: utf-8

baseURL = 'http://localhost:3000'

tempURL = "/a/Build"

indexURL = tempURL+'/'
homeURL = tempURL+'/home'
dashboardURL = tempURL+'/dashboard'
fileURL = tempURL+'/f'
testURL = tempURL+'/test'

upyunBaseDomain = 'b0.upaiyun.com'


upCloud = angular.module 'upCloud', ['ngCookies', 'ngRoute']

Controllers = {}
Directives  = {}


upCloud.service 'myData', ()->
  class DataStore
    constructor: () ->
  myDataStore = new DataStore
  return myDataStore


Directives['filelistBind'] = ($http)->
  (scope, elm, attrs) ->
    elm.bind "change", (evt) ->
      scope.$apply ->
        $http.post(baseURL+'/api/files', {
          dir_id: 0
          file_name: evt.target.files[0].name
          version_of: 5
        }).success (res)->
          scope.bucket = res.bucket
          scope.form_policy = res.policy
          scope.form_sign   = res.sign
          scope[attrs.name] = evt.target.files
          readFile()
          console.log scope[attrs.name]
          console.log evt.target.files[0].name


upCloud.directive Directives


isPic = (file)->
  link = file.uri or file.link or file.name
  if link.toLowerCase().split('.').pop() in ['jpg', 'png', 'gif', 'bmp', 'raw', 'jpeg', 'webp', 'ppm', 'pgm', 'pbm', 'pnm', 'pfm', 'pam', 'tiff', 'exif']
    return true
  else 
    return false

isLogin = ($http, myData)->
  deferred = Q.defer()
  $http.get(baseURL+'/api/users/current')
  .success (res)->
    if res.user_id is 0
      delete(myData.user_id)
      deferred.resolve false
    else
      myData.user_id = res.user_id
      deferred.resolve true
  .error (err)->
    deferred.reject err
  return deferred.promise



Controllers['navController'] = ($scope, $http, $location, myData)->

  $scope.logOut = ()->
    $http.delete(baseURL+'/api/session')
    .success (res)->
      delete(myData.user_id)
      $location.path(homeURL)
  $scope.isLogin = true if myData.user_id?


Controllers['FormController'] = ($scope, $http, $location, myData)->
  isLogin($http, myData)
  .then (logged_in)->
    if logged_in
      $location.path(dashboardURL+ '/' + myData.user_id + '/0')
      # window.location(dashboardURL+ '/' + myData.user_id + '/0')
      $scope.$apply()
  , (err)->
    console.log err

  $scope.checkEmail = ()->
    mail = $scope.email
    if /.*@(upai.com|huaban.com|upyun.com|yupoo.com|widget-inc.com)$/g.test(mail)
      $scope.emailWrong = false
      $http.post( baseURL+'/api/users/check', {email: $scope.email})
      .success (res)->
        if res.reg
          $scope.isReg = true
          $scope.action = 'Sign in'
        else
          $scope.isReg = false
          $scope.action = 'Sign up'
    else
      $scope.emailError = "illegal email"
      $scope.emailWrong = true

  $scope.checkPWD = ()->
    if $scope.pwd isnt $scope.pwd_repeat
      $scope.pwdWrong = true
      $scope.pwdError = 'password does not match'
    else
      $scope.pwdWrong = false
      

  $scope.submit = ()->
    goDashBoard = (user_id)->
      $location.path(dashboardURL+ '/' + user_id + '/0' )
    myData.user_email = $scope.email

    if $scope.pwd_repeat?
      $http.post(baseURL+'/api/users', {
        email: $scope.email
        password: $scope.pwd
      }).success (res)->
        myData.user_id = res.id
        goDashBoard res.id
      .error (err)->
        console.log err
        alert err

    else
      $http.post(baseURL+'/api/session', {
        email: $scope.email
        password: $scope.pwd
      }).success (res)->
        myData.user_id = res.id
        goDashBoard res.id
      .error (err)->
        console.log err
        alert err


Controllers['DashBoardController'] = ($scope, $http, $location, myData, $routeParams)->


  isLogin($http, myData)
  .then (logged_in)->
    console.log logged_in
    if logged_in
      if $routeParams.user_id? and myData.user_id.toString() isnt $routeParams.user_id.toString()
        console.log 'redirect to your own dashboard... '
        $location.path(dashboardURL+ '/' + myData.user_id + '/0')
        $scope.$apply()
      $scope.current_url_without_dir_id = dashboardURL + '/' + myData.user_id
      getCurrentDirContent()
      getGroupList()
    else
      console.log 'please log in first'
      $location.path(homeURL)
      $scope.$apply()
  , (err)->
    console.log err



  scope = $scope


  getTime = (raw_date)->
    d = new Date(raw_date)
    return d.getFullYear() + " " + ('0' + (d.getMonth() + 1)).slice(-2) + "-" + ('0' + d.getDate()).slice(-2) + ' ' + d.getHours() + ':' +  ('0'+d.getMinutes()).slice(-2) + ':' + ('0'+d.getSeconds()).slice(-2)

  getCurrentDirContent = ()->
    console.log 'get content!'

    if not $routeParams.group_id?
      api_point = baseURL+'/api/users/'+$routeParams.user_id+'/files?dir_id='+$routeParams.dir_id
    else
      api_point = baseURL+'/api/groups/'+$routeParams.group_id+'/files?dir_id='+$routeParams.dir_id
    $http.get(api_point)
    .success (res)->
      console.log 'asdasdads'
      console.log res
      for dir in res.dirs
        dir.previewPic = "/a/Build/assets/pic/dir.png"
        dir.created_at = getTime(dir.created_at)
        dir.updated_at = getTime(dir.updated_at)

      scope.current_dir_content = res.dirs
      for file in res.files
        if isPic(file)
          file.previewPic = "http://#{file.bucket}.#{upyunBaseDomain}#{file.uri}_mid" 
        else
          file.previewPic = "/a/Build/assets/pic/file.png"
        file.created_at = getTime(file.created_at)
        file.updated_at = getTime(file.updated_at)
        scope.current_dir_content.push file

  getGroupList = () ->
    console.log 'get group'
    $http.get(baseURL+'/api/users/'+myData.user_id+'/groups')
    .success (res)->
      console.log res
      myData.id2group = {}
      for group in res.groups
        myData.id2group[group.id] = group
      myData.id2group[$routeParams.group_id].liclass = 'active' if $routeParams.group_id
      scope.groups = res.groups



  dragEnterLeave = (evt) ->
    # console.log myData
    console.log 'leave'
    evt.stopPropagation()
    evt.preventDefault()
    scope.$apply ->
      scope.dropText = "Drop files here"
      scope.dropClass = ""

  dragOver = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    clazz = "not-available"
    ok = evt.dataTransfer and evt.dataTransfer.types and evt.dataTransfer.types.indexOf("Files") >= 0
    scope.$apply ->
      scope.dropText = (if ok then "Drop files here" else "Only files are allowed!")
      scope.dropClass = (if ok then "over" else "not-available")


  boxDrop = (evt) ->
    console.log @id
    console.log "drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer))
    # console.log myData
    console.log 'drop'
    evt.stopPropagation()
    evt.preventDefault()
    scope.$apply ->
      scope.dropText = "Drop files here"
      scope.dropClass = ""
    files = evt.dataTransfer.files
    if files.length > 0
      scope.$apply ->
        scope.files ?= []
        i = 0
        while i < files.length
          scope.files.push files[i]
          i++
  

  itemDrop = (evt) ->
    if @type is 'file' then console.log @version_of else console.log @dir_id
    console.log "drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer))
    # console.log myData
    console.log 'drop'
    evt.stopPropagation()
    evt.preventDefault()
    scope.$apply ->
      scope.dropText = "Drop files here"
      scope.dropClass = ""
    files = evt.dataTransfer.files
    if files.length > 0
      scope.$apply ->
        scope.files = []
        i = 0
        while i < files.length
          scope.files.push files[i]
          i++


  dropbox = document.getElementById("dropbox")
  dropItems = document.getElementsByClassName('dropItems')
  # console.log dropItems

  scope.dropText = "Drop files here"
  dropbox.addEventListener "dragenter", dragEnterLeave, false
  dropbox.addEventListener "dragleave", dragEnterLeave, false
  dropbox.addEventListener "dragover", dragOver, false
  dropbox.addEventListener "drop", boxDrop, false

  for item in dropItems
    item.addEventListener "dragenter", dragEnterLeave, false
    item.addEventListener "dragleave", dragEnterLeave, false
    item.addEventListener "dragover", dragOver, false
    item.addEventListener 'drop', itemDrop, false
  

  scope.setFiles = (element) ->
    scope.$apply (scope) ->
      console.log "files:", element.files
      scope.files = []
      i = 0

      while i < element.files.length
        scope.files.push element.files[i]
        i++
      scope.progressVisible = false


  uploadFile = ()->
    myData.upload_count = myData.upload_count or 0

    nextFile = scope.files[myData.upload_count]

    ((file)->
      post_data = 
        file_name: file.name
      if $routeParams.group_id
        post_data.group_id = $routeParams.group_id
        post_data.group_parent_directory_id = $routeParams.dir_id
      else
        post_data.parent_directory_id = $routeParams.dir_id

      $http.post(baseURL+'/api/files', post_data)
      .success (res)->
        xhr = new XMLHttpRequest()
        xhr.upload.addEventListener "progress", uploadProgress, false
        xhr.addEventListener "load", uploadComplete, false
        xhr.addEventListener "error", uploadFailed, false
        xhr.addEventListener "abort", uploadCanceled, false
        console.log res
        fd = new FormData()
        fd.append "file", file
        fd.append 'policy', res.policy
        fd.append 'signature', res.sign
        xhr.open "POST", "http://v0.api.upyun.com/"+res.bucket
        scope.progressVisible = true
        xhr.send fd
      .error (err)->
        console.log err)(nextFile)


  scope.uploadFile = uploadFile

      
  uploadComplete = (evt) ->
    console.log "File: "+scope.files[myData.upload_count].name+' upload done'
    console.log evt.target.response
    myData.upload_count += 1
    if scope.files.length > myData.upload_count
      uploadFile()
    else
      delete(myData.upload_count)
      delay = 2*1000
      setTimeout ()->
        getCurrentDirContent()
      , delay
      

    # scope.current_dir_content.push 


  # Turn the FileList object into an Array
  uploadProgress = (evt) ->
    scope.$apply ->
      if evt.lengthComputable
        scope.progress = Math.round(evt.loaded * 100 / evt.total)
      else
        scope.progress = "unable to compute"

  uploadFailed = (evt) ->
    alert "There was an error attempting to upload the file."

  uploadCanceled = (evt) ->
    scope.$apply ->
      scope.progressVisible = false
    alert "The upload has been canceled by the user or the browser dropped the connection."


  scope.createDir = ()->
    console.log 'gonna create dir'
    dir_id = $routeParams.dir_id or 0
    name   = $scope.new_dir_name
    $scope.new_dir_name = ''
    
    post_data = 
      name: name

    if $routeParams.group_id
      post_data.group_parent_directory_id = dir_id
      post_data.group_id = $routeParams.group_id
    else
      post_data.parent_directory_id = dir_id

    console.log post_data

    $http.post(baseURL+'/api/dirs', post_data)
    .success (res)->
      getCurrentDirContent()

  scope.createGroup = ()->
    console.log 'gonna create a group'
    name = scope.new_group_name
    scope.new_group_name = ''
    $http.post(baseURL+'/api/groups', {name: name})
    .success (res)->
      getGroupList()
    .error (err)->
      console.log err

  scope.deleteItem = (item)->
    api_point = "#{baseURL}/api/#{item.type}s/#{item.id}"
    if confirm('sure?')
      $http.delete(api_point)
      .success (res)->
        console.log res
        getCurrentDirContent()
      .error (err)->
        console.log err

  scope.editItem = (item)->
    new_name = prompt('new name')
    if new_name isnt '' and new_name?
      api_point = "#{baseURL}/api/#{item.type}s/#{item.id}"
      $http.put(api_point, {new_name: new_name})
      .success (result)->
        console.log result
        getCurrentDirContent()
      .error (err)->
        console.log err
    else
      alert 'good.'


Controllers['FileController'] = ($http, $scope, $routeParams, myData)->
  console.log fileURL+'/:file_id'
  file_id = $routeParams.file_id
  console.log baseURL+'/api/files/'+file_id+'/link'
  $http.get(baseURL+'/api/files/'+file_id+'/link')
  .success (file)->
    $scope.file_link = file.link
    $scope.file_name = file.name
    $scope.isPic = true if isPic(file)
    console.log file
  .error (err)->
    $scope.file_name = err.message
    console.log err

upCloud.controller Controllers



upCloud.config ($routeProvider, $locationProvider)->
  $locationProvider.html5Mode true
  $routeProvider
  .when indexURL,
    redirectTo: tempURL+'/home'

  .when homeURL,
    templateUrl: tempURL+'/home.partial'

  .when dashboardURL+'/:user_id/:dir_id' ,
    templateUrl: tempURL+'/dashboard.partial'

  .when dashboardURL+'/group/:group_id/:dir_id',
    templateUrl: tempURL+'/dashboard.partial'

  .when fileURL+'/:file_id',
    templateUrl: tempURL+'/file.partial'

  .when testURL,
    templateUrl: tempURL+'/test.partial'

  .otherwise 
    redirectTo: tempURL+'/home'
