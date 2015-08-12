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
  scale:1,

  startSession: function(msg, env, cb) {
    var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
    var left = (SSHtmlViewer.left - SSHtmlViewer.scrollleft) * SSHtmlViewer.scale + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft;
    var width = SSHtmlViewer.width * SSHtmlViewer.scale;
    var height = SSHtmlViewer.height * SSHtmlViewer.scale;

    if (cb) {
      Cordova.exec(cb, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'startSession', [msg.base, msg, top, left, width, height, env]);
    } else {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'startSession', [msg.base, msg, top, left, width, height, env]);
    }
    var ele = document.body;
    ele.className = ele.className.trim() + ' transparent';
    ele.style.backgroundColor = 'rgba(0,0,0,0)';

    SSHtmlViewer.browserStart = true;

    setTimeout(function() {
      var div = document.createElement("div");
      div.className = 'modal-backdrop';
      div.setAttribute('id', 'shockRepaint');
      window.document.body.appendChild(div);
      setTimeout(function() {
        window.document.body.removeChild(div);
      }, 100);
      window.speedshare.send('web#transparent', {});
    }, 2000);
  },
  stopSession: function() {
    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'stopSession', []);
    var ele = document.body;
    ele.className = ele.className.replace(/ transparent/g,'');
    ele.style.backgroundColor = '';
  },
  updateView: function() {
    //var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
    //var left = (SSHtmlViewer.left - SSHtmlViewer.scrollleft) * SSHtmlViewer.scale + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft;
    var top = (SSHtmlViewer.top) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
    var left = (SSHtmlViewer.left) * SSHtmlViewer.scale + SSHtmlViewer.localscrollleft + SSHtmlViewer.canvasleft;
    var width = SSHtmlViewer.width * SSHtmlViewer.scale;
    var height = SSHtmlViewer.height * SSHtmlViewer.scale;

    Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateView', [top, left, width, height]);
  },
  updateHTML: function(msg) {
    if (msg.base) {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateHTML', [msg.base, msg]);
    } else {
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'updateDOM', [msg]);
    }
  },
  checkElement: function(x,y,cb) {
    Cordova.exec(cb, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'checkElement', [x,y]);
  },
  SSHTMLSuccess: function(data) {
    console.log('SSHTMLSuccess', data);
  },
  SSHTMLError: function(data) {
    console.log('SSHTMLError', data);
  },
  attachListeners: function(speedshare) {
    speedshare.on('remote#dom', function(type, data){
      //SSHtmlViewer.height = data.height;
      debugger;
      if (!SSHtmlViewer.browserStart) {
        var env = localStorage.envSync.replace('https://', '').replace('http://', '');
        window.SSHtmlViewer.startSession(data.html, env);
      } else {
        window.SSHtmlViewer.updateHTML(data.html);
      }
    });
    speedshare.on('canvas#position', function(type, data){
      SSHtmlViewer.localscrolltop = data.top;
      window.SSHtmlViewer.updateView();
    });
    speedshare.on('canvas#resize', function(type, data){
      console.log('canvas#resize', data);
      // the plus 64 is to account for the 20px iOS status bar and the 44px header above the video
      SSHtmlViewer.scale = data.scale;
      SSHtmlViewer.width = data.width;
      SSHtmlViewer.height = data.height;
      window.SSHtmlViewer.updateView();
    });
    speedshare.on('window#scrolling', function(type, data){
      SSHtmlViewer.scrolltop = data.y;
      //if (data.animate) {
        //var top = (SSHtmlViewer.top - SSHtmlViewer.scrolltop) * SSHtmlViewer.scale + SSHtmlViewer.localscrolltop + SSHtmlViewer.canvastop;
      Cordova.exec(SSHtmlViewer.SSHTMLSuccess, SSHtmlViewer.SSHTMLError, 'HtmlViewerPlugin', 'sendScroll', [SSHtmlViewer.scrolltop]);
      //} else {
        //SSHtmlViewer.scrolltop = data.y;
        //window.SSHtmlViewer.updateView();
      //}
    });
    window.speedshare.on('connect#stop', function(type, data){
      window.SSHtmlViewer.stopSession();
    });
  }
};