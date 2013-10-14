// Generated by CoffeeScript 1.6.3
var Controllers, Directives, arr, baseURL, dashboardURL, fileURL, homeURL, indexURL, isLogin, isPic, tempURL, testURL, upCloud, upyunBaseDomain;

arr = window.location.href.split("/");

baseURL = arr[0] + '//' + arr[2];

tempURL = "";

indexURL = tempURL + '/';

homeURL = tempURL + '/home';

dashboardURL = tempURL + '/dashboard';

fileURL = tempURL + '/f';

testURL = tempURL + '/test';

upyunBaseDomain = 'b0.upaiyun.com';

upCloud = angular.module('upCloud', ['ngCookies', 'ngRoute']);

Controllers = {};

Directives = {};

upCloud.config([
  '$httpProvider', function($httpProvider) {
    return $httpProvider.defaults.withCredentials = true;
  }
]);

upCloud.service('myData', function() {
  var DataStore, myDataStore;
  DataStore = (function() {
    function DataStore() {}

    return DataStore;

  })();
  myDataStore = new DataStore;
  return myDataStore;
});

Directives['filelistBind'] = function($http) {
  return function(scope, elm, attrs) {
    return elm.bind("change", function(evt) {
      return scope.$apply(function() {
        return $http.post(baseURL + '/api/files', {
          dir_id: 0,
          file_name: evt.target.files[0].name,
          version_of: 5
        }).success(function(res) {
          scope.bucket = res.bucket;
          scope.form_policy = res.policy;
          scope.form_sign = res.sign;
          scope[attrs.name] = evt.target.files;
          readFile();
          console.log(scope[attrs.name]);
          return console.log(evt.target.files[0].name);
        });
      });
    });
  };
};

upCloud.directive(Directives);

isPic = function(file) {
  var link, _ref;
  link = file.uri || file.link || file.name;
  if ((_ref = link.toLowerCase().split('.').pop()) === 'jpg' || _ref === 'png' || _ref === 'gif' || _ref === 'bmp' || _ref === 'raw' || _ref === 'jpeg' || _ref === 'webp' || _ref === 'ppm' || _ref === 'pgm' || _ref === 'pbm' || _ref === 'pnm' || _ref === 'pfm' || _ref === 'pam' || _ref === 'tiff' || _ref === 'exif') {
    return true;
  } else {
    return false;
  }
};

isLogin = function($http, myData) {
  var deferred;
  deferred = Q.defer();
  if (myData.user_id != null) {
    deferred.resolve(true);
  } else {
    console.log('gonna check with server');
    $http.get(baseURL + '/api/users/current').success(function(res) {
      console.log('check login...');
      if (res.user_id === 0) {
        delete myData.user_id;
        return deferred.resolve(false);
      } else {
        myData.user_id = res.user_id;
        return deferred.resolve(true);
      }
    }).error(function(err) {
      return deferred.reject(err);
    });
  }
  return deferred.promise;
};

Controllers['navController'] = function($scope, $http, $location, myData, $routeParams) {
  $scope.logOut = function() {
    return $http["delete"](baseURL + '/api/session').success(function(res) {
      delete myData.user_id;
      return $location.path(homeURL);
    });
  };
  return $scope.isLogin = true;
};

Controllers['FormController'] = function($scope, $http, $location, myData) {
  isLogin($http, myData).then(function(logged_in) {
    if (logged_in) {
      $location.path(dashboardURL + '/' + myData.user_id + '/0');
      return $scope.$apply();
    }
  }, function(err) {
    console.log(err);
    return alert('server error...');
  });
  $scope.checkEmail = function() {
    var mail;
    mail = $scope.email;
    if (/.*@(upai.com|huaban.com|upyun.com|yupoo.com|widget-inc.com)$/g.test(mail)) {
      $scope.emailWrong = false;
      return $http.post(baseURL + '/api/users/check', {
        email: $scope.email
      }).success(function(res) {
        if (res.reg) {
          $scope.isReg = true;
          return $scope.action = 'Sign in';
        } else {
          $scope.isReg = false;
          return $scope.action = 'Sign up';
        }
      }).error(function(err) {
        console.log(err);
        return alert('server error on checking email');
      });
    } else {
      $scope.emailError = "illegal email";
      return $scope.emailWrong = true;
    }
  };
  $scope.checkPWD = function() {
    if ($scope.pwd !== $scope.pwd_repeat) {
      $scope.pwdWrong = true;
      return $scope.pwdError = 'password does not match';
    } else {
      return $scope.pwdWrong = false;
    }
  };
  return $scope.submit = function() {
    var goDashBoard;
    goDashBoard = function(user_id) {
      return $location.path(dashboardURL + '/' + user_id + '/0');
    };
    myData.user_email = $scope.email;
    if ($scope.pwd_repeat != null) {
      return $http.post(baseURL + '/api/users', {
        email: $scope.email,
        password: $scope.pwd
      }).success(function(res) {
        myData.user_id = res.id;
        return goDashBoard(res.id);
      }).error(function(err) {
        console.log(err);
        return alert(err);
      });
    } else {
      return $http.post(baseURL + '/api/session', {
        email: $scope.email,
        password: $scope.pwd
      }).success(function(res) {
        myData.user_id = res.id;
        return goDashBoard(res.id);
      }).error(function(err) {
        console.log(err);
        return alert(err);
      });
    }
  };
};

Controllers['DashBoardController'] = function($scope, $http, $location, myData, $routeParams) {
  var boxDrop, changeMember, changeParentDir, dragEnterLeave, dragOver, dropbox, droppableButton, droppableItem, getContent, getCurrentDirContent, getGroupInfo, getGroupList, getParentDirID, getTime, getTrashedContent, itemDrag, itemDragEnd, scope, testDrop, testOver, trashButton, trashOrRecover, updateFileModal, uploadCanceled, uploadComplete, uploadFailed, uploadFile, uploadProgress;
  isLogin($http, myData).then(function(logged_in) {
    if (logged_in) {
      if (($routeParams.user_id != null) && myData.user_id.toString() !== $routeParams.user_id.toString()) {
        console.log('redirect to your own dashboard... ');
        $location.path(dashboardURL + '/' + myData.user_id + '/0');
        $scope.$apply();
      }
      getCurrentDirContent();
      return getGroupList();
    } else {
      console.log('please log in first');
      $location.path(homeURL);
      return $scope.$apply();
    }
  }, function(err) {
    return console.log(err);
  });
  scope = $scope;
  scope.inRootDir = Number($routeParams.dir_id) === 0 ? true : false;
  getParentDirID = function(dir_id) {
    var api_point, deferred;
    deferred = Q.defer();
    api_point = baseURL + '/api/dirs/' + dir_id + '/parent';
    $http.get(api_point).success(function(parentDir) {
      return deferred.resolve($routeParams.group_id != null ? parentDir.group_parent_directory_id : parentDir.parent_directory_id);
    }).error(function(err) {
      return deferred.reject(err);
    });
    return deferred.promise;
  };
  if (Number($routeParams.dir_id) === 0) {
    scope.current_parent_dir_id = 0;
  } else {
    getParentDirID($routeParams.dir_id).then(function(dir_id) {
      console.log(dir_id);
      return scope.current_parent_dir_id = dir_id;
    }, function(err) {
      console.log(err);
      return scope.current_parent_dir_id = $routeParams.dir_id;
    });
  }
  getTime = function(raw_date) {
    var d;
    d = new Date(raw_date);
    return d.getFullYear() + " " + ('0' + (d.getMonth() + 1)).slice(-2) + "-" + ('0' + d.getDate()).slice(-2) + ' ' + d.getHours() + ':' + ('0' + d.getMinutes()).slice(-2) + ':' + ('0' + d.getSeconds()).slice(-2);
  };
  getCurrentDirContent = function() {
    return getContent('normal').then(function(content) {
      return scope.$apply(function() {
        return scope.current_dir_content = content;
      });
    }, function(err) {
      console.log(err);
      return alert(err.message);
    });
  };
  getTrashedContent = function() {
    return getContent('trashed').then(function(content) {
      return scope.$apply(function() {
        return scope.current_dir_content = content;
      });
    }, function(err) {
      console.log(err);
      return alert(err.message);
    });
  };
  getGroupList = function() {
    console.log('get group');
    return $http.get(baseURL + '/api/users/' + myData.user_id + '/groups').success(function(res) {
      var group, _i, _len, _ref;
      myData.id2group = {};
      _ref = res.groups;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        group = _ref[_i];
        myData.id2group[group.id] = group;
      }
      if ($routeParams.group_id) {
        myData.id2group[$routeParams.group_id].liclass = 'active';
      }
      return scope.groups = res.groups;
    });
  };
  getContent = function(type) {
    var api_point, deferred, setIcon;
    setIcon = function(file) {
      var fileExtension;
      fileExtension = file.name.toLowerCase().split('.').pop();
      file.previewPic = "/assets/pic/genericdoc.png";
      if (fileExtension === 'jpg' || fileExtension === 'png' || fileExtension === 'gif' || fileExtension === 'bmp' || fileExtension === 'raw' || fileExtension === 'jpeg' || fileExtension === 'webp' || fileExtension === 'ppm' || fileExtension === 'pgm' || fileExtension === 'pbm' || fileExtension === 'pnm' || fileExtension === 'pfm' || fileExtension === 'pam' || fileExtension === 'tiff' || fileExtension === 'exif') {
        file.previewPic = "http://" + file.bucket + "." + upyunBaseDomain + file.uri + "_mid";
      }
      if (fileExtension === 'txt' || fileExtension === 'pdf' || fileExtension === 'rtf' || fileExtension === 'rtfd' || fileExtension === 'doc' || fileExtension === 'docx') {
        file.previewPic = "/assets/pic/textfile.png";
      }
      if (fileExtension === 'mp3' || fileExtension === 'ogg' || fileExtension === 'm4a' || fileExtension === 'aac' || fileExtension === 'wmv' || fileExtension === 'wma' || fileExtension === 'wav') {
        file.previewPic = "/assets/pic/music.png";
      }
      if (fileExtension === 'mp4' || fileExtension === 'mkv' || fileExtension === 'rmvb' || fileExtension === 'avi' || fileExtension === 'mov' || fileExtension === 'mpg' || fileExtension === 'mpeg' || fileExtension === 'flv' || fileExtension === '3gp' || fileExtension === 'asf' || fileExtension === 'f4v' || fileExtension === 'm4v') {
        file.previewPic = "/assets/pic/video.png";
      }
      if (fileExtension === 'eot' || fileExtension === 'svg' || fileExtension === 'ttf' || fileExtension === 'woff' || fileExtension === 'otf') {
        file.previewPic = "/assets/pic/font.png";
      }
      if (file.status === 'uploading') {
        return file.previewPic = "/assets/pic/fileuploading.png";
      }
    };
    console.log('get ' + type + ' content!');
    deferred = Q.defer();
    if ($routeParams.group_id == null) {
      api_point = baseURL + '/api/users/' + $routeParams.user_id + '/files/' + type + '?dir_id=' + $routeParams.dir_id;
    } else {
      api_point = baseURL + '/api/groups/' + $routeParams.group_id + '/files/' + type + '?dir_id=' + $routeParams.dir_id;
    }
    $http.get(api_point).success(function(res) {
      var content, dir, file, _i, _j, _len, _len1, _ref, _ref1;
      content = [];
      _ref = res.dirs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dir = _ref[_i];
        dir.previewPic = "/assets/pic/dir.png";
        dir.created_at = getTime(dir.created_at);
        dir.updated_at = getTime(dir.updated_at);
        if (type === 'normal') {
          if (dir.status !== 'trashed') {
            content.push(dir);
          }
        } else {
          content.push(dir);
        }
      }
      _ref1 = res.files;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        file = _ref1[_j];
        setIcon(file);
        file.created_at = getTime(file.created_at);
        file.updated_at = getTime(file.updated_at);
        if (type === 'normal') {
          if (file.status !== 'trashed') {
            content.push(file);
          }
        } else {
          content.push(file);
        }
      }
      return deferred.resolve(content);
    }).error(function(err) {
      return deferred.reject(err);
    });
    return deferred.promise;
  };
  scope.switcher = {};
  scope.switcher.inbin = false;
  scope.switcherClick = function() {
    if (scope.switcher.inbin) {
      scope.switcher.inbin = false;
      return getCurrentDirContent();
    } else {
      scope.switcher.inbin = true;
      return getTrashedContent();
    }
  };
  dragEnterLeave = function(evt) {
    console.log('leave');
    evt.stopPropagation();
    evt.preventDefault();
    return scope.$apply(function() {
      scope.dropText = "Drop files here";
      return scope.dropClass = "";
    });
  };
  dragOver = function(evt) {
    var clazz, ok;
    evt.stopPropagation();
    evt.preventDefault();
    clazz = "not-available";
    ok = evt.dataTransfer && evt.dataTransfer.types && evt.dataTransfer.types.indexOf("Files") >= 0;
    return scope.$apply(function() {
      scope.dropText = (ok ? "Drop files here" : "Only files are allowed!");
      return scope.dropClass = (ok ? "over" : "not-available");
    });
  };
  boxDrop = function(evt) {
    var autoUpload, file, files, _i, _len;
    console.log("drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer)));
    evt.stopPropagation();
    evt.preventDefault();
    files = evt.dataTransfer.files;
    scope.dropClass = "";
    if (files.length > 0) {
      if ((scope.files == null) || scope.files.length === 0) {
        console.log('no file was uploading~');
        autoUpload = true;
        scope.files = [];
      } else {
        console.log('okay... just insert into the list');
        autoUpload = false;
      }
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        scope.files.push(file);
      }
      if (autoUpload) {
        return $('#uploadButton').click();
      }
    }
  };
  changeParentDir = function(item, new_parent_dir_id) {
    var api_point, deferred, put_data;
    deferred = Q.defer();
    if ($routeParams.group_id) {
      put_data = {
        new_group_parent_dir_id: new_parent_dir_id
      };
    } else {
      put_data = {
        new_parent_dir_id: new_parent_dir_id
      };
    }
    api_point = baseURL + '/api/' + item.item_type + 's/' + item.item_id;
    $http.put(api_point, put_data).success(function(result) {
      return deferred.resolve(result);
    }).error(function(err) {
      return deferred.reject(err);
    });
    return deferred.promise;
  };
  testDrop = function(evt) {
    var dragged_item, dropped, dropped_item;
    evt.originalEvent.stopPropagation();
    evt.originalEvent.preventDefault();
    dropped = evt.target;
    dragged_item = JSON.parse(evt.originalEvent.dataTransfer.getData('text'));
    switch (dropped.tagName) {
      case 'IMG':
        dropped_item = dropped.parentNode.dataset;
        break;
      case 'A':
        dropped_item = dropped.dataset;
        break;
      case 'SMALL':
        dropped_item = dropped.parentNode.children[1].dataset;
        break;
      case 'DIV':
        dropped_item = dropped.children[1].dataset;
    }
    if (dropped_item.item_id !== dragged_item.item_id && dropped_item.item_type === 'dir') {
      console.log(dragged_item);
      console.log(dropped_item);
      return changeParentDir(dragged_item, dropped_item.item_id).then(function(result) {
        console.log(result);
        if (scope.switcher.inbin) {
          return getTrashedContent();
        } else {
          return getCurrentDirContent();
        }
      }, function(err) {
        console.log(err);
        return alert(err.message);
      });
    }
  };
  testOver = function(evt) {
    evt.originalEvent.stopPropagation();
    return evt.originalEvent.preventDefault();
  };
  itemDrag = function(evt) {
    var iteminfo, theItem;
    theItem = $(this).children()[1];
    iteminfo = {
      item_id: theItem.dataset.item_id,
      item_type: theItem.dataset.item_type
    };
    evt.originalEvent.dataTransfer.setData('text', JSON.stringify(iteminfo));
    return console.log('start');
  };
  itemDragEnd = function(evt) {
    return console.log('end!');
  };
  trashOrRecover = function(evt) {
    var action, button, item;
    evt.originalEvent.stopPropagation();
    evt.originalEvent.preventDefault();
    item = JSON.parse(evt.originalEvent.dataTransfer.getData('text'));
    button = evt.target.dataset;
    action = button.action;
    if (action === 'recover') {
      console.log('gonna recover it');
      return scope.recoverItem(item.item_type, item.item_id);
    } else if (action === 'trash') {
      console.log('gonna trash it');
      return scope.deleteItem(item.item_type, item.item_id, 'trash');
    }
  };
  droppableItem = $(".item");
  droppableButton = $(".droppableButton");
  trashButton = $(".trashButton");
  console.log(droppableButton);
  droppableItem.live('dragover', testOver);
  droppableItem.live('drop', testDrop);
  droppableItem.live('dragstart', itemDrag);
  droppableItem.live('dragend', itemDragEnd);
  droppableButton.live('dragover', testOver);
  droppableButton.live('drop', testDrop);
  trashButton.live('dragover', testOver);
  trashButton.live('drop', trashOrRecover);
  dropbox = document.getElementById("dropbox");
  dropbox.addEventListener("dragenter", dragEnterLeave, false);
  dropbox.addEventListener("dragleave", dragEnterLeave, false);
  dropbox.addEventListener("dragover", dragOver, false);
  dropbox.addEventListener("drop", boxDrop, false);
  scope.setFiles = function(element) {
    return scope.$apply(function(scope) {
      var file, _i, _len, _ref;
      console.log("files:", element.files);
      if (scope.files == null) {
        scope.files = [];
      }
      _ref = element.files;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        scope.files.push(file);
      }
      return scope.progressVisible = false;
    });
  };
  uploadFile = function() {
    var nextFile;
    nextFile = scope.files[0];
    console.log('uploading ' + nextFile.name);
    return (function(file) {
      var post_data;
      post_data = {
        file_name: file.name
      };
      if ($routeParams.group_id) {
        post_data.group_id = $routeParams.group_id;
        post_data.group_parent_directory_id = $routeParams.dir_id;
      } else {
        post_data.parent_directory_id = $routeParams.dir_id;
      }
      return $http.post(baseURL + '/api/files', post_data).success(function(res) {
        var fd, xhr;
        xhr = new XMLHttpRequest();
        xhr.upload.addEventListener("progress", uploadProgress, false);
        xhr.addEventListener("load", uploadComplete, false);
        xhr.addEventListener("error", uploadFailed, false);
        xhr.addEventListener("abort", uploadCanceled, false);
        fd = new FormData();
        scope.currentUploadingFile = nextFile.name;
        fd.append("file", file);
        fd.append('policy', res.policy);
        fd.append('signature', res.sign);
        xhr.open("POST", "http://v0.api.upyun.com/" + res.bucket);
        scope.progressVisible = true;
        return xhr.send(fd);
      }).error(function(err) {
        return console.log(err);
      });
    })(nextFile);
  };
  scope.uploadFile = uploadFile;
  uploadComplete = function(evt) {
    var delay;
    console.log("File: " + scope.files[0].name + ' is uploaded.');
    console.log(evt.target.response);
    scope.files.splice(0, 1);
    if (scope.files.length > 0) {
      return uploadFile();
    } else {
      scope.progressVisible = false;
      scope.files = [];
      delay = 2 * 1000;
      return setTimeout(function() {
        return getCurrentDirContent();
      }, delay);
    }
  };
  uploadProgress = function(evt) {
    return scope.$apply(function() {
      if (evt.lengthComputable) {
        return scope.progress = Math.round(evt.loaded * 100 / evt.total);
      } else {
        return scope.progress = "unable to compute progress";
      }
    });
  };
  uploadFailed = function(evt) {
    return alert("An error occured while uploading the file.");
  };
  uploadCanceled = function(evt) {
    scope.$apply(function() {
      return scope.progressVisible = false;
    });
    return alert("The upload has been canceled by the user or the browser dropped the connection.");
  };
  scope.createDir = function() {
    var dir_id, name, post_data;
    console.log('gonna create dir');
    dir_id = $routeParams.dir_id || 0;
    name = $scope.new_dir_name;
    $scope.new_dir_name = '';
    post_data = {
      name: name
    };
    if ($routeParams.group_id) {
      post_data.group_parent_directory_id = dir_id;
      post_data.group_id = $routeParams.group_id;
    } else {
      post_data.parent_directory_id = dir_id;
    }
    console.log(post_data);
    return $http.post(baseURL + '/api/dirs', post_data).success(function(res) {
      return getCurrentDirContent();
    });
  };
  scope.createGroup = function() {
    var name;
    if (confirm('You can NOT delete group for now, you sure?')) {
      console.log('gonna create a group');
      name = scope.new_group_name;
      scope.new_group_name = '';
      $http.post(baseURL + '/api/groups', {
        name: name
      }).success(function(res) {
        return getGroupList();
      }).error(function(err) {
        return console.log(err);
      });
    }
    return scope.new_group_name = '';
  };
  scope.deleteItem = function(item_type, item_id, action) {
    var api_point;
    console.log(action);
    api_point = "" + baseURL + "/api/" + item_type + "s/" + item_id + "/" + action;
    return $http["delete"](api_point).success(function(res) {
      console.log(res);
      if (scope.switcher.inbin) {
        getTrashedContent();
      } else {
        getCurrentDirContent();
      }
      return $('#DeleteItemModal').foundation('reveal', 'close');
    }).error(function(err) {
      console.log(err);
      if (scope.switcher.inbin) {
        getTrashedContent();
      } else {
        getCurrentDirContent();
      }
      return $('#DeleteItemModal').foundation('reveal', 'close');
    });
  };
  scope.recoverItem = function(item_type, item_id) {
    var api_point;
    api_point = "" + baseURL + "/api/" + item_type + "s/" + item_id;
    return $http.put(api_point, {
      new_status: 'uploaded'
    }).success(function(result) {
      console.log(result);
      getTrashedContent();
      return $('#DeleteItemModal').foundation('reveal', 'close');
    }).error(function(err) {
      console.log(err);
      return alert(err.message);
    });
  };
  scope.showDeleteItemModal = function(item) {
    scope.itemInfo = item;
    return $('#DeleteItemModal').foundation('reveal', 'open');
  };
  scope.editItem = function(item) {
    var api_point;
    api_point = "" + baseURL + "/api/" + item.type + "s/" + item.id;
    return $http.put(api_point, {
      new_name: new_name
    }).success(function(result) {
      console.log(result);
      console.log(scope.switcher.inbin);
      if (scope.switcher.inbin) {
        return getTrashedContent();
      } else {
        return getCurrentDirContent();
      }
    }).error(function(err) {
      return console.log(err);
    });
  };
  getGroupInfo = function(group) {
    var api_point;
    api_point = baseURL + '/api/groups/' + group.id + '/members';
    scope.groupInfo.name = group.name;
    scope.groupInfo.id = group.id;
    return $http.get(api_point).success(function(result) {
      var admins, member, owner, users, _i, _len, _ref;
      console.log(result);
      admins = [];
      users = [];
      owner = '';
      _ref = result.members;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        member = _ref[_i];
        switch (member.type) {
          case 'user':
            users.push(member);
            break;
          case 'admin':
            admins.push(member);
            break;
          case 'owner':
            owner = member;
        }
      }
      scope.groupInfo.users = users;
      scope.groupInfo.admins = admins;
      return scope.groupInfo.owner = owner;
    }).error(function(err) {
      console.log(err);
      return scope.groupInfo.admins = scope.groupInfo.users = [
        {
          email: 'Error...'
        }
      ];
    });
  };
  scope.showGroupModal = function(group) {
    scope.groupInfo = {};
    scope.groupInfo.users = scope.groupInfo.admin = [
      {
        email: 'Loading...'
      }
    ];
    scope.groupInfo.owner = {
      email: 'Loading...'
    };
    $('#GroupModal').foundation('reveal', 'open');
    return getGroupInfo(group);
  };
  scope.changeGroupName = function(group) {
    var group_api_point, new_name;
    new_name = prompt('new name', group.name);
    group_api_point = baseURL + '/api/groups/' + group.id;
    return $http.put(group_api_point, {
      new_name: new_name
    }).success(function(result) {
      console.log(result);
      getGroupList();
      return group.name = new_name;
    }).error(function(err) {
      return console.log(err);
    });
  };
  scope.editGroup = function(group) {};
  scope.deleteGroup = function(group) {};
  scope.deleteGroupUser = function(group, user_id) {
    return changeMember(group, user_id, 'del_user');
  };
  scope.deleteGroupAdmin = function(group, user_id) {
    return changeMember(group, user_id, 'del_admin');
  };
  scope.addGroupUser = function(group, email) {
    return changeMember(group, email, 'add_user');
  };
  scope.addGroupAdmin = function(group, email) {
    return changeMember(group, email, 'add_admin');
  };
  changeMember = function(group, email, action) {
    var ar, errorHandler, getID, goChange;
    getID = function(email) {
      var deferred, user_api_point;
      deferred = Q.defer();
      user_api_point = baseURL + '/api/users/getid' + '?email=' + email;
      $http.get(user_api_point).success(function(result) {
        return deferred.resolve(result.id);
      }, function(err) {
        return deferred.reject(err);
      });
      return deferred.promise;
    };
    goChange = function(ar) {
      var deferred, group_api_point;
      console.log('gochange!');
      console.log(ar);
      deferred = Q.defer();
      group_api_point = baseURL + '/api/groups/' + group.id;
      $http.put(group_api_point, ar).success(function(result) {
        console.log('gochange done!');
        return deferred.resolve(result);
      }).error(function(err) {
        return deferred.reject(err);
      });
      return deferred.promise;
    };
    errorHandler = function(err) {
      if (err.message != null) {
        return alert(err.message);
      } else {
        return alert('perhaps the server occurred an error. Please report it with log, THX.');
      }
    };
    ar = {};
    if (isNaN(email)) {
      console.log('have to get id...');
      return getID(email).then(function(id) {
        console.log(id);
        ar[action] = id;
        console.log(ar);
        return goChange(ar).then(function(result) {
          return getGroupInfo(group);
        }, function(err) {
          console.log(err);
          return errorHandler(err);
        });
      }, function(err) {
        console.log(err);
        return errorHandler(err);
      });
    } else {
      ar[action] = email;
      return goChange(ar).then(function(result) {
        return getGroupInfo(group);
      }, function(err) {
        console.log(err);
        return errorHandler(err);
      });
    }
  };
  updateFileModal = function(file) {
    scope.fileInfo = file;
    scope.fileInfo.shareInfo = file["private"] ? 'Click to Share!' : 'Make It Private!';
    return scope.fileInfo.shareLink = baseURL + '/f/' + file.id;
  };
  scope.showShareFileModal = function(file) {
    updateFileModal(file);
    return $('#ShareFileModal').foundation('reveal', 'open');
  };
  scope.changeFilePrivate = function(file) {
    var api_point;
    scope.fileChanging = true;
    api_point = "" + baseURL + "/api/files/" + file.id;
    return $http.put(api_point, {
      new_private: !file["private"]
    }).success(function(result) {
      console.log(result);
      file["private"] = !file["private"];
      updateFileModal(file);
      return scope.fileChanging = false;
    }).error(function(err) {
      console.log(err);
      updateFileModal(file);
      return scope.fileChanging = false;
    });
  };
  scope.showEditItemModal = function(item) {
    var nameArray;
    scope.itemEdit = item;
    nameArray = item.name.split('.');
    scope.itemEdit.extension = nameArray.pop();
    scope.itemEdit.foreName = item.type === 'file' ? nameArray.join('') : item.name;
    return $('#EditItemModal').foundation('reveal', 'open');
  };
  return scope.showEditUserModal = function(user) {
    scope.userInfo = user;
    return $('#UserEditModal').foundation('reveal', 'open');
  };
};

Controllers['FileController'] = function($http, $scope, $routeParams, myData) {
  var file_id;
  console.log(fileURL + '/:file_id');
  file_id = $routeParams.file_id;
  console.log(baseURL + '/api/files/' + file_id + '/link');
  return $http.get(baseURL + '/api/files/' + file_id + '/link').success(function(file) {
    $scope.file_link = file.link;
    $scope.file_name = file.name;
    if (isPic(file)) {
      $scope.isPic = true;
    }
    return console.log(file);
  }).error(function(err) {
    $scope.file_name = err.message;
    return console.log(err);
  });
};

upCloud.controller(Controllers);

upCloud.config(function($routeProvider, $locationProvider) {
  $locationProvider.html5Mode(true);
  return $routeProvider.when(indexURL, {
    redirectTo: tempURL + '/home'
  }).when(homeURL, {
    templateUrl: tempURL + '/home.partial'
  }).when(dashboardURL + '/:user_id/:dir_id', {
    templateUrl: tempURL + '/dashboard.partial'
  }).when(dashboardURL + '/group/:group_id/:dir_id', {
    templateUrl: tempURL + '/dashboard.partial'
  }).when(fileURL + '/:file_id', {
    templateUrl: tempURL + '/file.partial'
  }).when(testURL, {
    templateUrl: tempURL + '/test.partial'
  }).otherwise({
    redirectTo: tempURL + '/home'
  });
});
