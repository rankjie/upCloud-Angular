baseURL = 'http://localhost:3000'

tempURL = ""

indexURL = tempURL+'/'
homeURL = tempURL+'/home'
dashboardURL = tempURL+'/dashboard'
fileURL = tempURL+'/f'
testURL = tempURL+'/test'

upyunBaseDomain = 'b0.upaiyun.com'


upCloud = angular.module 'upCloud', ['ngCookies', 'ngRoute']

Controllers = {}
Directives  = {}




upCloud.config(['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.withCredentials = true;
])







                   ######  ######## ########  ##     ## ####  ######  ########                 
                  ##    ## ##       ##     ## ##     ##  ##  ##    ## ##                       
                  ##       ##       ##     ## ##     ##  ##  ##       ##                       
  ####### #######  ######  ######   ########  ##     ##  ##  ##       ######   ####### ####### 
                        ## ##       ##   ##    ##   ##   ##  ##       ##                       
                  ##    ## ##       ##    ##    ## ##    ##  ##    ## ##                       
                   ######  ######## ##     ##    ###    ####  ######  ########                 


upCloud.service 'myData', ()->
  class DataStore
    constructor: () ->
  myDataStore = new DataStore
  return myDataStore


                  ########  #### ########  ########  ######  ######## #### ##     ## ########                 
                  ##     ##  ##  ##     ## ##       ##    ##    ##     ##  ##     ## ##                       
                  ##     ##  ##  ##     ## ##       ##          ##     ##  ##     ## ##                       
  ####### ####### ##     ##  ##  ########  ######   ##          ##     ##  ##     ## ######   ####### ####### 
                  ##     ##  ##  ##   ##   ##       ##          ##     ##   ##   ##  ##                       
                  ##     ##  ##  ##    ##  ##       ##    ##    ##     ##    ## ##   ##                       
                  ########  #### ##     ## ########  ######     ##    ####    ###    ########                 

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



                   ######   #######  ##    ## ######## ########   #######  ##       ##       ######## ########                  
                  ##    ## ##     ## ###   ##    ##    ##     ## ##     ## ##       ##       ##       ##     ##                 
                  ##       ##     ## ####  ##    ##    ##     ## ##     ## ##       ##       ##       ##     ##                 
  ####### ####### ##       ##     ## ## ## ##    ##    ########  ##     ## ##       ##       ######   ########  ####### ####### 
                  ##       ##     ## ##  ####    ##    ##   ##   ##     ## ##       ##       ##       ##   ##                   
                  ##    ## ##     ## ##   ###    ##    ##    ##  ##     ## ##       ##       ##       ##    ##                  
                   ######   #######  ##    ##    ##    ##     ##  #######  ######## ######## ######## ##     ##                 

isPic = (file)->
  link = file.uri or file.link or file.name
  if link.toLowerCase().split('.').pop() in ['jpg', 'png', 'gif', 'bmp', 'raw', 'jpeg', 'webp', 'ppm', 'pgm', 'pbm', 'pnm', 'pfm', 'pam', 'tiff', 'exif']
    return true
  else 
    return false

# 检查是否登录（看返回的user_id
isLogin = ($http, myData)->
  deferred = Q.defer()
  # 先判断下myData里面有没有，有的话就直接返回了
  # console.log myData
  if myData.user_id?
    console.log 'already in myData'
    deferred.resolve true
  else
    console.log 'gonna check with server'
    $http.get(baseURL+'/api/users/current')
    .success (res)->
      console.log 'check login...'
      if res.user_id is 0
        delete(myData.user_id)
        deferred.resolve false
      else
        myData.user_id = res.user_id
        deferred.resolve true
    .error (err)->
      deferred.reject err
  return deferred.promise



Controllers['navController'] = ($scope, $http, $location, myData, $routeParams)->
  # 登出按钮
  $scope.logOut = ()->
    $http.delete(baseURL+'/api/session')
    .success (res)->
      delete(myData.user_id)
      $location.path(homeURL)

  $scope.isLogin = true

Controllers['FormController'] = ($scope, $http, $location, myData)->
  isLogin($http, myData)
  .then (logged_in)->
    if logged_in
      $location.path(dashboardURL+ '/' + myData.user_id + '/0')
      # window.location(dashboardURL+ '/' + myData.user_id + '/0')
      $scope.$apply()
  , (err)->
    console.log err
    alert 'server error...'

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
      .error (err)->
        console.log err
        alert 'server error on checking email'
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
    # 注册
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
    # 登录
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



  ########     ###     ######  ##     ## ########   #######     ###    ########  ########  
  ##     ##   ## ##   ##    ## ##     ## ##     ## ##     ##   ## ##   ##     ## ##     ## 
  ##     ##  ##   ##  ##       ##     ## ##     ## ##     ##  ##   ##  ##     ## ##     ## 
  ##     ## ##     ##  ######  ######### ########  ##     ## ##     ## ########  ##     ## 
  ##     ## #########       ## ##     ## ##     ## ##     ## ######### ##   ##   ##     ## 
  ##     ## ##     ## ##    ## ##     ## ##     ## ##     ## ##     ## ##    ##  ##     ## 
  ########  ##     ##  ######  ##     ## ########   #######  ##     ## ##     ## ########  

Controllers['DashBoardController'] = ($scope, $http, $location, myData, $routeParams)->

  # 检查是否登录（看返回的user_id）
  # 没登录的跳转到首页，登录的跳转到自己的页面
  isLogin($http, myData)
  .then (logged_in)->
    if logged_in
      # 如果有user_id就说明是在用户文件页面，所以要跳转到用户本身的页面
      # 没有user_id就说明是在请求小组的文件，就不用检查了
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

  # 获取当前目录内容
  getCurrentDirContent = ()->
    console.log 'get content!'
    # 获取用户文件
    if not $routeParams.group_id?
      api_point = baseURL+'/api/users/'+$routeParams.user_id+'/files?dir_id='+$routeParams.dir_id
    else
      api_point = baseURL+'/api/groups/'+$routeParams.group_id+'/files?dir_id='+$routeParams.dir_id
    $http.get(api_point)
    .success (res)->
      console.log res
      scope.current_dir_content = []
      # 回收站内容
      scope.current_dir_content_trashed = []
      for dir in res.dirs
        dir.previewPic = "/assets/pic/dir.png"
        dir.created_at = getTime(dir.created_at)
        dir.updated_at = getTime(dir.updated_at)

        if dir.status is 'trashed'
          scope.current_dir_content_trashed.push dir
        else
          scope.current_dir_content.push dir

      for file in res.files
        if isPic(file)
          file.previewPic = "http://#{file.bucket}.#{upyunBaseDomain}#{file.uri}_mid" 
        else
          file.previewPic = "/assets/pic/file.png"
        file.created_at = getTime(file.created_at)
        file.updated_at = getTime(file.updated_at)

        if file.status is 'trashed'
          console.log 'a trashed file:'+file
          scope.current_dir_content_trashed.push file
        else
          scope.current_dir_content.push file
    .error (err)->
      console.log err
      alert 'server down?'
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


  #============== DRAG & DROP =============
  # 参考: http://www.webappers.com/2011/09/28/drag-drop-file-upload-with-html5-javascript/
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

  # 丢在dropbox框框里的时候
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
    console.log scope.files

  # 丢在某文件or文件夹上的时候
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



  # 每次有文件传完了就会出发load事件
  # 在事件里再重新触发上传操作，实现队列
  # 当前队列位置可以存在myData里面
  
  #============== DRAG & DROP =============

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
    # 初始化，一开始从0开始
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
        scope.currentUploadingFile = scope.files[myData.upload_count].name
        fd.append "file", file
        fd.append 'policy', res.policy
        fd.append 'signature', res.sign
        xhr.open "POST", "http://v0.api.upyun.com/"+res.bucket
        scope.progressVisible = true
        xhr.send fd
      .error (err)->
        console.log err)(nextFile)


  scope.uploadFile = uploadFile
    # # 只能一个个文件上传＝_=
    # for file in scope.files
    #   console.log $routeParams.dir_id ? 0
    #   console.log file.name
    #   # 请求上传用的key
    #   ((file)->
    #     $http.post(baseURL+'/api/files', {
    #       dir_id: $routeParams.dir_id ? 0
    #       file_name: file.name
    #     }).success (res)->
    #       xhr = new XMLHttpRequest()
    #       xhr.upload.addEventListener "progress", uploadProgress, false
    #       xhr.addEventListener "load", uploadComplete, false
    #       xhr.addEventListener "error", uploadFailed, false
    #       xhr.addEventListener "abort", uploadCanceled, false
    #       console.log res
    #       fd = new FormData()
    #       fd.append "file", file
    #       fd.append 'policy', res.policy
    #       fd.append 'signature', res.sign
    #       xhr.open "POST", "http://v0.api.upyun.com/"+res.bucket
    #       scope.progressVisible = true
    #       xhr.send fd
    #     .error (err)->
    #       console.log err)(file)
      
  uploadComplete = (evt) ->
    console.log "File: "+scope.files[myData.upload_count].name+' is uploaded.'
    console.log evt.target.response
    # 计数加一
    myData.upload_count += 1
    # 要是当前计数还没达到队列长度，就再上传
    # = --> 不传
    # < --> 不传
    # > ---> 传！
    if scope.files.length > myData.upload_count
      uploadFile()
    else
      delete(myData.upload_count)
      scope.progressVisible = false
      scope.files = []
      # 延迟一会儿再抓取新的文件数据
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


  # 创建文件夹
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

  # 创建群组
  scope.createGroup = ()->
    console.log 'gonna create a group'
    name = scope.new_group_name
    scope.new_group_name = ''
    $http.post(baseURL+'/api/groups', {name: name})
    .success (res)->
      getGroupList()
    .error (err)->
      console.log err

  # 删除文件or文件夹
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


  getGroupInfo = (group)->
    api_point = baseURL + '/api/groups/'+group.id+'/members'
    scope.groupInfo.name = group.name
    scope.groupInfo.id   = group.id
    $http.get(api_point)
    .success (result)->
      console.log result
      admins = []
      users  = []
      owner = ''
      for member in result.members
        switch member.type
          when 'user' then users.push member
          when 'admin' then admins.push member
          when 'owner' then owner = member
      scope.groupInfo.users = users
      scope.groupInfo.admins = admins
      scope.groupInfo.owner = owner
    .error (err)->
      console.log err
      scope.groupInfo.admins = scope.groupInfo.users = [{email:'Error...'}]

  scope.showGroupModal = (group)->
    scope.groupInfo = {}
    scope.groupInfo.users = scope.groupInfo.admin = [{email:'Loading...'}]
    scope.groupInfo.owner = {email:'Loading...'}
    $('#GroupModal').closeOnBackgroundClick = false
    $('#GroupModal').foundation('reveal', 'open')
    getGroupInfo(group)
    
      
  scope.editGroup = (group)->
    
  scope.deleteGroup = (group)->

  # 删除用户
  scope.deleteGroupUser = (group, user_id)->
    return changeMember(group, user_id, 'del_user')

  # 删除管理员，即，将管理员降级为普通成员
  scope.deleteGroupAdmin = (group, user_id)->
    return changeMember(group, user_id, 'del_admin')

  # 增加用户/降级.成员权限（）
  scope.addGroupUser = (group, email)->
    return changeMember(group, email, 'add_user')

  # 增加管理员/升级.成员权限（如果用户已经是普通成员，就会自动提升为管理员；当然也可以将非当前群组成员直接设为管理员）
  scope.addGroupAdmin = (group, email)->
    return changeMember(group, email, 'add_admin')


  changeMember = (group, email, action)->
    getID = (email)->
      deferred = Q.defer()
      user_api_point = baseURL+'/api/users/getid'+'?email='+email
      $http.get(user_api_point)
      .success (result)->
        deferred.resolve result.id
      , (err)->
        console.log err
        alert 'server error...'
      return deferred.promise
    goChange = (ar)->
      console.log 'go change!'
      console.log ar
      deferred = Q.defer()
      group_api_point = baseURL+'/api/groups/'+group.id

      $http.put(group_api_point, ar)
      .success (result)->
        console.log 'done!'
        deferred.resolve result
      .error (err)->
        deferred.reject err
        console.log err
        alert 'server error...'
      return deferred.promise

    # group_api_point = baseURL+'/api/groups/'+group.id
    # user_api_point = baseURL+'/api/users/getid'+'?email='+email
    ar = {}
    # email参数不是数字的话就要获取id
    if isNaN(email)
      console.log 'have to get id...'
      getID(email)
      .then (id)->
        console.log id
        ar[action] = id
        console.log ar
        goChange(ar)
        .then (result)->
          getGroupInfo(group)
        , (err)->
          console.log err
          alert 'server error...'
    else 
      ar[action] = email
      goChange(ar)
      .then (result)->
        getGroupInfo(group)
      , (err)->
        console.log err
        alert 'server error...'


    # $http.get(user_api_point)
    # .success (result)->
    #   console.log result
    #   ar = {}
    #   ar[action] = result.id
    #   $http.put(group_api_point, ar)
    #   .success (result)->
    #     console.log 'done!'
    #     getGroupInfo(group)
    #   .error (err)->
    #     console.log err
    #     alert 'server error...'
    # .error (err)->
    #   console.log err
    #   alert 'server error...'




  scope.showEditUserModal = (user)->
    scope.userInfo = user
    $('#UserEditModal').foundation('reveal', 'open')


  ######## #### ##       ######## 
  ##        ##  ##       ##       
  ##        ##  ##       ##       
  ######    ##  ##       ######   
  ##        ##  ##       ##       
  ##        ##  ##       ##       
  ##       #### ######## ######## 



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

  ########   #######  ##     ## ######## ######## 
  ##     ## ##     ## ##     ##    ##    ##       
  ##     ## ##     ## ##     ##    ##    ##       
  ########  ##     ## ##     ##    ##    ######   
  ##   ##   ##     ## ##     ##    ##    ##       
  ##    ##  ##     ## ##     ##    ##    ##       
  ##     ##  #######   #######     ##    ######## 

upCloud.config ($routeProvider, $locationProvider)->
  $locationProvider.html5Mode true
  $routeProvider
  .when indexURL,
    redirectTo: tempURL+'/home'

  .when homeURL,
    templateUrl: tempURL+'/home.partial'

  # 先检查是否登录（看返回的user_id）
  # 没登录的跳转到首页，登录的跳转到自己的页面
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




  ######## ##    ## ########  
  ##       ###   ## ##     ## 
  ##       ####  ## ##     ## 
  ######   ## ## ## ##     ## 
  ##       ##  #### ##     ## 
  ##       ##   ### ##     ## 
  ######## ##    ## ########  

