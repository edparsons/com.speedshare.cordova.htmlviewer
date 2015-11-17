window.SSHtmlViewer = {
  browserStart: false,
  left:0,
  top:0,
  height:525,
  width:375,
  scrolltop: 0,
  scrollleft: 0,
  localscrolltop: 0,
  localscrollleft: 0,
  canvasleft:0,
  canvastop:98,
  panleft:0,
  pantop:0,
  scale:1,
  internalScrollX: 0,
  internalScrollY: 0,
  internalScale: 1,
  viewer: true,
  madeTransparent: false,

  init: function(v) {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'init', []);
  },
  startSession: function(cb) {
    var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop + SSHtmlViewer.pantop;
    var left = (SSHtmlViewer.left - SSHtmlViewer.scrollleft) * SSHtmlViewer.scale + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft + SSHtmlViewer.panleft;
    var width = SSHtmlViewer.width * SSHtmlViewer.scale;
    var height = SSHtmlViewer.height * SSHtmlViewer.scale;
    var htmlWidth = SSHtmlViewer.width * SSHtmlViewer.scale;
    var htmlHeight = SSHtmlViewer.height * SSHtmlViewer.scale;

    SSHtmlViewer.runTransparentCode();
    SSHtmlViewer.browserStart = true;

    if (cb) {
      Cordova.exec(cb, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'startSession', [top, left, width, height, htmlWidth, htmlHeight]);
    } else {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'startSession', [top, left, width, height, htmlWidth, htmlHeight]);
    }
  },
  stopSession: function() {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'stopSession', []);
    SSHtmlViewer.browserStart = false;

    var ele = document.body;
    ele.className = ele.className.replace(/ transparent/g,'');
    ele.style.backgroundColor = '';
  },
  updateView: function() {
    if (SSHtmlViewer.browserStart) {
      //var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
      //var left = (SSHtmlViewer.left - SSHtmlViewer.scrollleft) * SSHtmlViewer.scale + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft;
      var top = SSHtmlViewer.top  + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop + SSHtmlViewer.pantop;
      var left = SSHtmlViewer.left + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft + SSHtmlViewer.panleft;
      var width = SSHtmlViewer.width;
      var height = SSHtmlViewer.height;
      var htmlWidth = SSHtmlViewer.width / SSHtmlViewer.scale;
      var htmlHeight = SSHtmlViewer.height / SSHtmlViewer.scale;

      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateView', [top, left, width, height, htmlWidth, htmlHeight]);
    }
  },
  updateInternalView: function() {
    if (SSHtmlViewer.browserStart) {
      //var scrollTop = (SSHtmlViewer.internalScrollY / SSHtmlViewer.internalScale ) - ((SSHtmlViewer.height/SSHtmlViewer.scale)-SSHtmlViewer.height)/2;
      //var scrollLeft = (SSHtmlViewer.internalScrollX / SSHtmlViewer.internalScale ) - ((SSHtmlViewer.width/SSHtmlViewer.scale)-SSHtmlViewer.width)/2/SSHtmlViewer.scale;

      //Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateInternalView', [SSHtmlViewer.internalScale]);
    }    
  },
  updateHTML: function(msg) {
    if (SSHtmlViewer.browserStart) {
      if (msg.base) {
        SSHtmlViewer.base = msg.base;
        Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateHTML', [msg.base, msg]);
      } else {
        Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateDOM', [msg]);
      }
    }
  },
  hideView: function() {
    if (SSHtmlViewer.browserStart) {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'hideView', []);
    }
  },
  showView: function() {
    if (SSHtmlViewer.browserStart) {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'showView', []);
    }
  },
  checkElement: function(x,y,cb) {
    if (SSHtmlViewer.browserStart) {
      Cordova.exec(cb, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'checkElement', [x,y]);
    }
  },
  startLoading: function(cb) {
    if (SSHtmlViewer.browserStart) {
      Cordova.exec(cb, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'startLoading', []);
    }
  },
  bringToFront: function() {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'bringToFront', []);
  },
  sendToBack: function() {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'bringToFront', []);
  },
  setRavenConfig: function(env, version, deployment, link, sessionId, clientId, syncServer, viewer) {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'ravenSetup', [env, version, deployment, link, sessionId, clientId, syncServer, JSON.stringify(viewer)]);
  },
  runTransparentCode: function() {
    var ele = document.body;
    ele.className = ele.className.trim() + ' transparent';
    ele.style.backgroundColor = 'transparent';

    window.speedshare.send('web#transparent', {});

    setTimeout(function() {
      var div = document.createElement("div");
      div.className = 'modal-backdrop';
      div.setAttribute('id', 'shockRepaint');
      window.document.body.appendChild(div);
      setTimeout(function() {
        window.document.body.removeChild(div);
      }, 100);
    }, 2000);
  },
  SSHTMLSuccess: function(data) {
    //console.log('SSHTMLSuccess', data);
  },
  SSHTMLError: function(data) {
    throw new Error('SSHtmlPlugin: '+JSON.stringify(data));
  },
  setup: function(env, syncServer, viewer, sessionId, clientId, link, v) {
    window.SSHtmlViewer.env = syncServer.replace('http://','').replace('https://','');
    window.SSHtmlViewer.setRavenConfig(window.SSHtmlViewer.env, window.SpeedshareAPI.version, env, link, sessionId, clientId, syncServer, viewer);
    window.SSHtmlViewer.viewer = v;
    if (!SSHtmlViewer.viewer) {
      window.SSHtmlViewer.startSession();
    }
  },
  fakeCrash: function() {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'fakeCrash', []);
  },
  setupCrashlytics: function(identifier) {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'setCrashlytics', [identifier]);
  },
  attachListeners: function(speedshare) {
    speedshare.on('remote#dom', function(type, data){
      //SSHtmlViewer.height = data.height;
      //debugger;
      if (!SSHtmlViewer.viewer) {
        window.SSHtmlViewer.updateHTML(data.html);
      }
    });

    speedshare.on('canvas#position', function(type, data){
      SSHtmlViewer.localscrolltop = data.top;
      if (!SSHtmlViewer.viewer && SSHtmlViewer.browserStart) {
        window.SSHtmlViewer.updateView();
      }
    });
    speedshare.on('tabs#loading', function(type, data){
      if (!SSHtmlViewer.viewer && SSHtmlViewer.browserStart) {
        window.SSHtmlViewer.startLoading();
      }
    });
    speedshare.on('remote#playVideo', function(type, data){
      window.SSHtmlViewer.hideView();
    });
    speedshare.on('remote#pauseVideo', function(type, data){
      window.SSHtmlViewer.showView();
    });
    speedshare.on('canvas#resize', function(type, data){
      if (!SSHtmlViewer.madeTransparent) {
        SSHtmlViewer.runTransparentCode();
        SSHtmlViewer.madeTransparent = true;
      }
      SSHtmlViewer.scale = data.initScale;
      if (!data.initScale) {
        SSHtmlViewer.scale = 1;
      }
      SSHtmlViewer.width = data.width;
      SSHtmlViewer.height = data.height;
      SSHtmlViewer.internalScrollX = data.internalScrollX;
      SSHtmlViewer.internalScrollY = data.internalScrollY;
      SSHtmlViewer.internalScale = data.scale;
      SSHtmlViewer.top = data.top;
      SSHtmlViewer.left = data.left;
      if (!SSHtmlViewer.browserStart && !SSHtmlViewer.viewer) {
        window.SSHtmlViewer.startSession();      
      }
      if (!SSHtmlViewer.viewer && SSHtmlViewer.browserStart) {
        window.SSHtmlViewer.updateView();
        window.SSHtmlViewer.updateInternalView();
      }
    });
    speedshare.on('window#scrolling', function(type, data){
      if (!SSHtmlViewer.viewer && SSHtmlViewer.browserStart) {
        SSHtmlViewer.scrolltop = data.y;
        SSHtmlViewer.scrollleft = data.x;
        //if (data.animate) {
          //var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
        Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'sendScroll', [SSHtmlViewer.scrollleft, SSHtmlViewer.scrolltop, SSHtmlViewer.internalScale]);
        //} else {
          //SSHtmlViewer.scrolltop = data.y;
          //window.SSHtmlViewer.updateView();
        //}        
      }
    });
    window.speedshare.on('connect#stop', function(type, data){
      window.SSHtmlViewer.stopSession();
      SSHtmlViewer.madeTransparent = false;
    });
  }
};