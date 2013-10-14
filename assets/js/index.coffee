# baseURL = 'http://localhost:3000'
# baseURL = location.protocol + "//" + location.hostname + (location.p ":" + location.port) + "/"
arr = window.location.href.split("/")
baseURL = arr[0] + '//' + arr[2]


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
    getContent('normal')
    .then (content)->
      scope.$apply ->
        scope.current_dir_content = content
    , (err)->
      console.log err
      alert err.message

  # 获取回收站内容，暂时就直接替换掉当前页面的文件内容了
  # 需要重写
  getTrashedContent = ()->
    getContent('trashed')
    .then (content)->
      scope.$apply ->
        scope.current_dir_content = content
    , (err)->
      console.log err
      alert err.message

  getGroupList = () ->
    console.log 'get group'
    $http.get(baseURL+'/api/users/'+myData.user_id+'/groups')
    .success (res)->
      # console.log res
      myData.id2group = {}
      for group in res.groups
        myData.id2group[group.id] = group
      myData.id2group[$routeParams.group_id].liclass = 'active' if $routeParams.group_id
      scope.groups = res.groups

  getContent = (type)->
    setIcon = (file)->
      fileExtension = file.name.toLowerCase().split('.').pop()
      # 默认的文件
      file.previewPic = "/assets/pic/genericdoc.png"
      # 图片的
      file.previewPic = "http://#{file.bucket}.#{upyunBaseDomain}#{file.uri}_mid" if fileExtension in ['jpg', 'png', 'gif', 'bmp', 'raw', 'jpeg', 'webp', 'ppm', 'pgm', 'pbm', 'pnm', 'pfm', 'pam', 'tiff', 'exif']
      # 文本文件的
      file.previewPic = "/assets/pic/textfile.png" if fileExtension in ['txt', 'pdf', 'rtf', 'rtfd', 'doc', 'docx']
      # 音频的
      file.previewPic = "/assets/pic/music.png" if fileExtension in ['mp3', 'ogg', 'm4a', 'aac', 'wmv', 'wma', 'wav']
      # 影视的
      file.previewPic = "/assets/pic/video.png" if fileExtension in ['mp4', 'mkv', 'rmvb', 'avi', 'mov', 'mpg', 'mpeg', 'flv', '3gp', 'asf', 'f4v', 'm4v']
      # 字体的
      file.previewPic = "/assets/pic/font.png" if fileExtension in ['eot', 'svg', 'ttf', 'woff', 'otf']
      # 还没收到又拍云通知的
      file.previewPic = "/assets/pic/fileuploading.png" if file.status is 'uploading'


    console.log 'get '+type+' content!'
    deferred = Q.defer()
    # 获取用户文件
    if not $routeParams.group_id?
      api_point = baseURL+'/api/users/'+$routeParams.user_id+'/files/' + type + '?dir_id='+$routeParams.dir_id
    else
      api_point = baseURL+'/api/groups/'+$routeParams.group_id+'/files/' + type + '?dir_id='+$routeParams.dir_id
    # console.log api_point
    $http.get(api_point)
    .success (res)->
      content = []
      for dir in res.dirs
        dir.previewPic = "/assets/pic/dir.png"
        dir.created_at = getTime(dir.created_at)
        dir.updated_at = getTime(dir.updated_at)
        if type is 'normal'
          content.push dir if dir.status isnt 'trashed'
        else
          content.push dir

      for file in res.files
        # if isPic(file)
        #   file.previewPic = "http://#{file.bucket}.#{upyunBaseDomain}#{file.uri}_mid" if file.status is 'uploaded'
        #   file.previewPic = "/assets/pic/"
        # else
        #   file.previewPic = "/assets/pic/file.png"
        setIcon(file)
        file.created_at = getTime(file.created_at)
        file.updated_at = getTime(file.updated_at)
        if type is 'normal' 
          content.push file if file.status isnt 'trashed'
        else
          content.push file

      deferred.resolve content
    .error (err)->
      deferred.reject err

    return deferred.promise


  scope.switcher = {}
  scope.switcher.inbin = false

  scope.switcherClick = ()->
    # 现在在显示回收站内容的话，就重新加载目录内容
    if scope.switcher.inbin
      scope.switcher.inbin = false
      getCurrentDirContent()
    else
      scope.switcher.inbin = true
      getTrashedContent()


    ########  ########     ###     ######        ####       ########  ########   #######  ########  
    ##     ## ##     ##   ## ##   ##    ##      ##  ##      ##     ## ##     ## ##     ## ##     ## 
    ##     ## ##     ##  ##   ##  ##             ####       ##     ## ##     ## ##     ## ##     ## 
    ##     ## ########  ##     ## ##   ####     ####        ##     ## ########  ##     ## ########  
    ##     ## ##   ##   ######### ##    ##     ##  ## ##    ##     ## ##   ##   ##     ## ##        
    ##     ## ##    ##  ##     ## ##    ##     ##   ##      ##     ## ##    ##  ##     ## ##        
    ########  ##     ## ##     ##  ######       ####  ##    ########  ##     ##  #######  ##        
    # 可参考资料: http://www.webappers.com/2011/09/28/drag-drop-file-upload-with-html5-javascript/

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
    console.log "drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer))
    # console.log myData
    evt.stopPropagation()
    evt.preventDefault()
    files = evt.dataTransfer.files
    scope.dropClass = ""
    if files.length > 0
      # scope.$apply ->
      if not scope.files? or scope.files.length is 0
        console.log 'no file was uploading~'
        autoUpload = true
        scope.files = []
      else 
        console.log 'okay... just insert into the list'
        autoUpload = false

      for file in files
        scope.files.push file

      $('#uploadButton').click() if autoUpload







          #### ######## ######## ##     ##    ########  ########   #######  ########  
           ##     ##    ##       ###   ###    ##     ## ##     ## ##     ## ##     ## 
           ##     ##    ##       #### ####    ##     ## ##     ## ##     ## ##     ## 
           ##     ##    ######   ## ### ##    ##     ## ########  ##     ## ########  
           ##     ##    ##       ##     ##    ##     ## ##   ##   ##     ## ##        
           ##     ##    ##       ##     ##    ##     ## ##    ##  ##     ## ##        
          ####    ##    ######## ##     ##    ########  ##     ##  #######  ##        
  
  # 会发多次请求，需要debug


  changeParentDir = (item, new_parent_dir_id)->
    deferred = Q.defer()
    # 如果是群组，那就要改group_parent_directory_id
    # 非群组，就该parent_directory_id
    if $routeParams.group_id
      put_data = 
        new_group_parent_dir_id: new_parent_dir_id
    else
      # 非群组的
      put_data = 
        new_parent_dir_id: new_parent_dir_id
    api_point = baseURL+'/api/'+item.item_type+'s/'+item.item_id
    $http.put(api_point, put_data)
    .success (result)->
      deferred.resolve result
    .error (err)->
      deferred.reject err
    return deferred.promise

  testDrop = (evt, ui)->
    console.log '!!!!!!!!!!droped !!!!!!!!!!!!!!!!'
    evt.originalEvent.stopPropagation()
    evt.originalEvent.preventDefault()

    dropped  = evt.target

    dragged_item = JSON.parse(evt.originalEvent.dataTransfer.getData('text'))

    # 父子关系：  div > a(data!)   > IMG
    #                 SMALL
    # 如果丢到了IMG上，那就要上层的
    # small上，就上层的子层...
    # div上，子曾
    switch dropped.tagName 
      when 'IMG'   then dropped_item = dropped.parentNode.dataset
      when 'A'     then dropped_item = dropped.dataset
      when 'SMALL' then dropped_item = dropped.parentNode.children[1].dataset
      when 'DIV'   then dropped_item = dropped.children[1].dataset
    
    # console.log dropped_item.item_id
    # console.log dropped_item.item_type


    # 如果拽过来的和丢下去的不是同一个文件，并且别丢的是个文件夹
    # 那就触发修改文件/文件夹上层目录的操作
    # 暂时先不增加创建版本的功能，只做移动目录
    # 还可以增加： 拖到上进目录、拖到根目录、拖到回收站的功能，drag触发的时候更改回收站按钮的文字，显示拖到根目录和上级目录的区域
    if dropped_item.item_id isnt dragged_item.item_id and dropped_item.item_type is 'dir'
      changeParentDir(dragged_item, dropped_item.item_id)
      .then (result)->
        console.log result
        if scope.switcher.inbin then getTrashedContent() else getCurrentDirContent()
      , (err)->
        console.log err
        alert err.message


  testOver = (evt)->
    evt.originalEvent.stopPropagation()
    evt.originalEvent.preventDefault()
    console.log 'over!!!!'

  itemDrag = (evt)->
    theItem = $(this).children()[1]
    iteminfo = 
      item_id: theItem.dataset.item_id
      item_type: theItem.dataset.item_type
    evt.originalEvent.dataTransfer.setData('text', JSON.stringify(iteminfo))

  itemDragEnd = (evt)->
    console.log 'end!'

  droppableItem = $(".item")

  # console.log droppableItem


  droppableItem.live('dragover', testOver)
  droppableItem.live('drop', testDrop)
  droppableItem.live('dragstart', itemDrag)
  droppableItem.live('dragend', itemDragEnd)


  # # 丢在某文件or文件夹上的时候
  # itemDrop = (evt) ->
  #   if @type is 'file' then console.log @version_of else console.log @dir_id
  #   console.log "drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer))
  #   # console.log myData
  #   console.log 'drop'
  #   evt.stopPropagation()
  #   evt.preventDefault()
  #   console.log 'yooooo~~~~'
  #   scope.$apply ->
  #     scope.dropText = "Drop files here"
  #     scope.dropClass = ""
  #   files = evt.dataTransfer.files
  #   console.log 'fine = ='
  #   if files.length > 0
  #     console.log 'apply!!!!'
  #     scope.$apply ->
  #       # 如果当前已经有文件在队列里
  #       if scope.files.length > 0
  #         scope.files = scope.files
  #       else
  #         # 没有的话，就初始化队列
  #         scope.files = []
  #       # 一个个加到队列里
  #       for file in files
  #         scope.files.push file

  #     # 如果现在没有在上传文件（通过上传文件的计数来判断），那就触发上传按钮
  #     if not myData.upload_count? or myData.upload_count > 0
  #       console.log 'no file was uploading~'
  #       # $('#uploadButton').click()
  #     else
  #       console.log 'okay... just insert into the list'


  # 每次有文件传完了就会出发load事件
  # 在事件里再重新触发上传操作，实现队列
  # 当前队列位置可以存在myData里面
  
    ##     ## ########  ##        #######     ###    ########  
    ##     ## ##     ## ##       ##     ##   ## ##   ##     ## 
    ##     ## ##     ## ##       ##     ##  ##   ##  ##     ## 
    ##     ## ########  ##       ##     ## ##     ## ##     ## 
    ##     ## ##        ##       ##     ## ######### ##     ## 
    ##     ## ##        ##       ##     ## ##     ## ##     ## 
     #######  ##        ########  #######  ##     ## ########  


  dropbox = document.getElementById("dropbox")
  
  
  dropbox.addEventListener "dragenter", dragEnterLeave, false
  dropbox.addEventListener "dragleave", dragEnterLeave, false
  dropbox.addEventListener "dragover", dragOver, false
  dropbox.addEventListener "drop", boxDrop, false

    # item.addEventListener "dragenter", dragEnterLeave, false
    # item.addEventListener "dragleave", dragEnterLeave, false
  
  

  scope.setFiles = (element) ->
    scope.$apply (scope) ->
      console.log "files:", element.files
      scope.files ?= []
      for file in element.files
        scope.files.push file
      # i = 0
      # while i < element.files.length
      #   scope.files.push element.files[i]
      #   i++
      scope.progressVisible = false


  uploadFile = ()->
    # 永远上传队列顶部的文件
    nextFile = scope.files[0]
    console.log 'uploading '+nextFile.name
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
        # console.log res
        fd = new FormData()
        scope.currentUploadingFile = nextFile.name
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
    console.log "File: "+scope.files[0].name+' is uploaded.'
    console.log evt.target.response
    # 把队列顶部的文件去掉，因为它已经传完了
    scope.files.splice(0, 1)
    # 要是当前文件队列计数大于0
    if scope.files.length > 0
      uploadFile()
    else
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
        scope.progress = "unable to compute progress"

  uploadFailed = (evt) ->
    alert "An error occured while uploading the file."

  uploadCanceled = (evt) ->
    scope.$apply ->
      scope.progressVisible = false
    alert "The upload has been canceled by the user or the browser dropped the connection."



     ######  ########  ########    ###    ######## ######## 
    ##    ## ##     ## ##         ## ##      ##    ##       
    ##       ##     ## ##        ##   ##     ##    ##       
    ##       ########  ######   ##     ##    ##    ######   
    ##       ##   ##   ##       #########    ##    ##       
    ##    ## ##    ##  ##       ##     ##    ##    ##       
     ######  ##     ## ######## ##     ##    ##    ######## 

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
    if confirm('You can NOT delete group for now, you sure?')
      console.log 'gonna create a group'
      name = scope.new_group_name
      scope.new_group_name = ''
      $http.post(baseURL+'/api/groups', {name: name})
      .success (res)->
        getGroupList()
      .error (err)->
        console.log err
    scope.new_group_name = ''

  # trash文件or文件夹
  scope.deleteItem = (item, action)->
    console.log action
    api_point = "#{baseURL}/api/#{item.type}s/#{item.id}/#{action}"
    # console.log api_point
    $http.delete(api_point)
    .success (res)->
      console.log res
      # 因为有缓存，所以如果刚一进入目录就删的话，这里删完了重新获取也依然会获取到老的数据
      # 可以加个timedout？或者怎样＝ ＝？
      if scope.switcher.inbin then getTrashedContent() else getCurrentDirContent()
      $('#DeleteItemModal').foundation('reveal', 'close')
    .error (err)->
      console.log err
      if scope.switcher.inbin then getTrashedContent() else getCurrentDirContent()
      $('#DeleteItemModal').foundation('reveal', 'close')

  scope.recoverItem = (item)->
    # 直接edit status？ good
    api_point = "#{baseURL}/api/#{item.type}s/#{item.id}"
    $http.put(api_point, {new_status: 'uploaded'})
    .success (result)->
      console.log result
      getTrashedContent()
      $('#DeleteItemModal').foundation('reveal', 'close')
    .error (err)->
      console.log err
      alert err.message


  scope.showDeleteItemModal = (item)->
    scope.itemInfo = item
    $('#DeleteItemModal').foundation('reveal', 'open')
    

  # 修改文件/文件夹
  scope.editItem = (item)->
    new_name = prompt('new name')
    if new_name isnt '' and new_name?
      api_point = "#{baseURL}/api/#{item.type}s/#{item.id}"
      $http.put(api_point, {new_name: new_name})
      .success (result)->
        console.log result
        console.log scope.switcher.inbin
        if scope.switcher.inbin then getTrashedContent() else getCurrentDirContent()
      .error (err)->
        console.log err

  # 获取群组信息
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
    $('#GroupModal').foundation('reveal', 'open')
    getGroupInfo(group)

  scope.changeGroupName = (group)->
    new_name = prompt('new name', group.name)
    group_api_point = baseURL+'/api/groups/'+group.id
    $http.put(group_api_point, {new_name: new_name})
    .success (result)->
      console.log result
      getGroupList()
      group.name = new_name
    .error (err)->
      console.log err

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
        deferred.reject err
      return deferred.promise
    goChange = (ar)->
      console.log 'gochange!'
      console.log ar
      deferred = Q.defer()
      group_api_point = baseURL+'/api/groups/'+group.id

      $http.put(group_api_point, ar)
      .success (result)->
        console.log 'gochange done!'
        deferred.resolve result
      .error (err)->
        deferred.reject err
      return deferred.promise

    errorHandler = (err)->
      if err.message?
        alert err.message
      else
        alert 'perhaps the server occurred an error. Please report it with log, THX.'
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
          errorHandler err
      , (err)->
        console.log err
        errorHandler err
    else 
      ar[action] = email
      goChange(ar)
      .then (result)->
        getGroupInfo(group)
      , (err)->
        console.log err
        errorHandler err


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
  updateFileModal = (file)->
    scope.fileInfo = file
    scope.fileInfo.shareInfo = if file.private then 'Click to Share!' else 'Make It Private!'
    scope.fileInfo.shareLink = baseURL+'/f/'+file.id

  scope.showShareFileModal = (file)->
    updateFileModal(file)
    $('#ShareFileModal').foundation('reveal', 'open')

  scope.changeFilePrivate = (file)->
    scope.fileChanging = true
    api_point = "#{baseURL}/api/files/#{file.id}"
    $http.put(api_point, {new_private: !file.private})
    .success (result)->
      console.log result
      file.private = !file.private
      updateFileModal(file)
      scope.fileChanging = false
      # $('.fileLink').
    .error (err)->
      console.log err
      updateFileModal(file)
      scope.fileChanging = false





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