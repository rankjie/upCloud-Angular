baseURL = 'http://localhost:3000'

LogApp = angular.module 'LogApp', ['ngCookies']

Controllers = {}

Controllers['FormController'] = ($scope, $http, $cookieStore)->
  
  $scope.checkEmail = ()->
    mail = $scope.email
    if /.*@(upai.com|huaban.com|upyun.com|yupoo.com|widget-inc.com)$/g.test(mail)
      $scope.emailWrong = false
      $http.post( baseURL+'/api/users/check', {email: $scope.email})
      .success (res)->
        if res.reg
          $scope.isReg = true
          $scope.action = 'Log in'
        else
          $scope.isReg = false
          $scope.action = 'Sign in'
    else
      $scope.emailError = "illegal email"
      $scope.emailWrong = true

  $scope.checkPWD = ()->
    if $scope.pwd isnt $scope.pwd_repeat
      $scope.pwdWrong = true
    else
      $scope.pwdWrong = false
      $scope.pwdError = 'password do not match'

  $scope.submit = ()->
    # reg
    if $scope.pwd_repeat?
      $http.post(baseURL+'/api/users', {
        email: $scope.email
        password: $scope.pwd
      }).success (res)->
        console.log 'reg suc' + res
        $cookieStore.put 'user_id', res.id
      .error (err)->
        console.log err
        alert err
    # log
    else
      $http.post(baseURL+'/api/session', {
        email: $scope.email
        password: $scope.pwd
      }).success (res)->
        console.log 'log suc' + res
        $cookieStore.put 'user_id', res.id
      .error (err)->
        console.log err
        alert err

LogApp.controller Controllers