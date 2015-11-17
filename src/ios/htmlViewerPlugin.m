//
//  SpeedsharePlugin.m
//
//  Copyright (c) 2015 Osix Corp. All rights reserved.
//  Please see the LICENSE included with this distribution for details.
//

#import "htmlViewerPlugin.h"
#import <Crashlytics/Crashlytics.h>

@implementation HtmlViewerPlugin{
    UIView *containerView;
    WKWebView *htmlview;
    CADisplayLink *displayLink;
    NSString *startHTML;
    NSString *env;
    //NSDictionary *pendingDomUpdate;
    NSMutableArray *pendingDomUpdates;
    bool loading;
    NSString *version;
    NSString *deployment;
    NSString *link;
    NSString *sessionId;
    NSString *clientId;
    NSString *syncServer;
    NSString *viewer;
}

#pragma mark -
#pragma mark Cordova Methods
-(void) pluginInitialize{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuspend:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume:) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self name:@"speedshare"];
    
    htmlview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:theConfiguration];
    
    env = @"sync-production.speedshare.com";
    version = @"";
    deployment = @"";
    link = @"";
    sessionId = @"";
    clientId = @"";
    syncServer = @"";
    viewer = @"";

    htmlview.navigationDelegate = self;
    
    loading = false;
    
    [self.webView.superview insertSubview:containerView atIndex:0];
    [containerView insertSubview:htmlview atIndex:0];

    self.webView.keyboardDisplayRequiresUserAction = false;
    self.webView.allowsInlineMediaPlayback = true;
//    [self.webView.superview addSubview:htmlview];
 
    htmlview.hidden = YES;
    containerView.hidden = YES;

    //displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick)];
    //displayLink.paused = YES;
    
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mirror" ofType:@"html"];
    startHTML = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
    pendingDomUpdates = [NSMutableArray array];
    
    self.webView.layer.zPosition = 4;
    containerView.layer.zPosition = 1;
    htmlview.layer.zPosition = 1;
    containerView.clipsToBounds = YES;
}

- (void)init:(CDVInvokedUrlCommand*)command{
// noop function to allow the initialize to be run on-demand
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   loading = false;
    [self runJavascript:@"if (typeof preloadProgress === 'function') { preloadProgress(); }" withTitle:@"preloadProgress"];
   [self runDomUpdates];
}

- (void)userContentController:(WKUserContentController *)userContentController
                            didReceiveScriptMessage:(WKScriptMessage *)message{
//    NSDictionary *sentData = (NSDictionary*)message.body;
//    long aCount = [sentData[@"count"] integerValue];
//    aCount++;
//    [_theWebView evaluateJavaScript:[NSString
//            stringWithFormat:@"storeAndShow(%ld)", aCount] completionHandler:nil];
}

- (void)onSuspend:(NSNotification *) notification {
}
- (void)onResume:(NSNotification *) notification {
}
- (void)animationTick {
    //htmlview.frame = CGRectMake(htmlview.frame.origin.x, htmlview.frame.origin.y, htmlview.frame.size.width, htmlview.frame.size.height);
    //displayLink.paused = YES;
}

#pragma mark -
#pragma mark Cordova JS - iOS bindings
#pragma mark Methods
/*** Methods
 ****/

-(void)ravenSetup:(CDVInvokedUrlCommand*)command{
    if ([self checkArguments:command withTemplate:@[@"s",@"s",@"s",@"s",@"s",@"s",@"s",@"s"]]) {
        env = [command.arguments objectAtIndex:0];
        version = [command.arguments objectAtIndex:1];
        deployment = [command.arguments objectAtIndex:2];
        link = [command.arguments objectAtIndex:3];
        sessionId = [command.arguments objectAtIndex:4];
        clientId = [command.arguments objectAtIndex:5];
        syncServer = [command.arguments objectAtIndex:6];
        viewer = [command.arguments objectAtIndex:7];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/mirror.html?version=%@#deployment=%@&link=%@&sessionId=%@&clientId=%@&syncServer=%@&viewer=%@", env, version, deployment, link, sessionId, clientId, syncServer, viewer]];

        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [htmlview loadRequest:request];
        loading = true;

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)startSession:(CDVInvokedUrlCommand*)command{
    if ([self checkArguments:command withTemplate:@[@"n",@"n",@"n",@"n",@"n",@"n"]]) {
        int top = [[command.arguments objectAtIndex:0] intValue];
        int left = [[command.arguments objectAtIndex:1] intValue];
        int width = [[command.arguments objectAtIndex:2] intValue];
        int height = [[command.arguments objectAtIndex:3] intValue];
        int htmlWidth = [[command.arguments objectAtIndex:4] intValue];
        int htmlHeight = [[command.arguments objectAtIndex:5] intValue];
        
        containerView.frame = CGRectMake(left, top, width, height);
        htmlview.frame = CGRectMake(0, 0, htmlWidth, htmlHeight);

        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];

        containerView.hidden = NO;
        htmlview.hidden = NO;
        
        htmlview.backgroundColor = [UIColor whiteColor];
        
        htmlview.clearsContextBeforeDrawing = YES;
        htmlview.clipsToBounds = YES;
        htmlview.multipleTouchEnabled = NO;
        htmlview.opaque = YES;
        //htmlview.scalesPageToFit = NO;
        htmlview.userInteractionEnabled = NO;
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)stopSession:(CDVInvokedUrlCommand*)command{
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [htmlview loadRequest:request];
    loading = true;

    htmlview.hidden = YES;
    containerView.hidden = YES;

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)updateView:(CDVInvokedUrlCommand*)command{
    if ([self checkArguments:command withTemplate:@[@"n",@"n",@"n",@"n",@"n",@"n"]]) {
        int top = [[command.arguments objectAtIndex:0] intValue];
        int left = [[command.arguments objectAtIndex:1] intValue];
        int width = [[command.arguments objectAtIndex:2] intValue];
        int height = [[command.arguments objectAtIndex:3] intValue];
        int htmlWidth = [[command.arguments objectAtIndex:4] intValue];
        int htmlHeight = [[command.arguments objectAtIndex:5] intValue];
        
        if (htmlview) {
            containerView.frame = CGRectMake(left, top, width, height);
            htmlview.frame = CGRectMake(0, 0, htmlWidth, htmlHeight);
            [htmlview setNeedsDisplay];
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)updateInternalView:(CDVInvokedUrlCommand*)command {
    if ([self checkArguments:command withTemplate:@[@"n",@"n",@"n"]]) {
        int scrollX = [[command.arguments objectAtIndex:0] intValue];
        int scrollY = [[command.arguments objectAtIndex:1] intValue];
        float scale = [[command.arguments objectAtIndex:2] floatValue];

        if (!loading) {
            [self runJavascript:[NSString stringWithFormat:@"document.documentElement.style.webkitTransform = 'scale3d(%f, %f, 1) translate3d(%dpx, %dpx, 0px)';", scale, scale, scrollX, scrollY]  withTitle:@"setTransform"];
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


- (void)updateHTML:(CDVInvokedUrlCommand*)command {
    if ([self checkArguments:command withTemplate:@[@"s",@"o"]]) {
        NSString* base = [command.arguments objectAtIndex:0];
        [pendingDomUpdates removeAllObjects];
        [pendingDomUpdates addObject:[command.arguments objectAtIndex:1]];
        
        NSURL *url;
        if ([base hasPrefix:@"http://"]) {
           url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/mirror.html?version=%@#deployment=%@&link=%@&sessionId=%@&clientId=%@&syncServer=%@&viewer=%@", env, version, deployment, link, sessionId, clientId, syncServer, viewer]];
        } else {
           url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/mirror.html?version=%@#deployment=%@&link=%@&sessionId=%@&clientId=%@&syncServer=%@&viewer=%@", env, version, deployment, link, sessionId, clientId, syncServer, viewer]];
        }

        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [htmlview loadRequest:request];
        loading = true;

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)updateDOM:(CDVInvokedUrlCommand*)command {
    if ([self checkArguments:command withTemplate:@[@"o"]]) {
        [pendingDomUpdates addObject:[command.arguments objectAtIndex:0]];
        if (!loading) {
            [self runDomUpdates];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)runDomUpdates {
    NSData* jsonData;
    NSString* jsonString;

    while ([pendingDomUpdates count] > 0) {
        NSDictionary *domUpdate = [pendingDomUpdates objectAtIndex:0];
        jsonData = [NSJSONSerialization dataWithJSONObject:domUpdate options:0 error:nil];
        jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
        [htmlview evaluateJavaScript:[NSString stringWithFormat:@"onMessage(%@)", jsonString] completionHandler:^(id result, NSError *error) {
            if (error == nil) {
                if (result != nil) {
                    NSLog(@"updateDom evaluateJavaScript : %@", [NSString stringWithFormat:@"%@", result]);
                } else {
                    //NSLog(@"updateDom evaluateJavaScript no result");
                }
            } else {
                NSLog(@"updateDom evaluateJavaScript error : %@", error.localizedDescription);
            }
        }];
        [pendingDomUpdates removeObjectAtIndex:0];
    }
}

- (void)bringToFront:(CDVInvokedUrlCommand*)command {
    [self.webView.superview bringSubviewToFront:containerView];
}

- (void)sendToBack:(CDVInvokedUrlCommand*)command {
    [self.webView.superview sendSubviewToBack:containerView];
}

- (void)hideView:(CDVInvokedUrlCommand*)command {
    htmlview.hidden = YES;
    containerView.hidden = YES;
}

- (void)showView:(CDVInvokedUrlCommand*)command {
    htmlview.hidden = NO;
    containerView.hidden = NO;
}

- (void)checkElement:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 1) {

        int left = [[command.arguments objectAtIndex:0] intValue];
        int top = [[command.arguments objectAtIndex:1] intValue];

        [htmlview evaluateJavaScript:[NSString stringWithFormat:@"window.document.elementFromPoint(%d, %d).tagName;", left, top] completionHandler:^(id result, NSError *error) {
            if (error == nil) {
                if (result != nil) {
                    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                    [payload setObject:result forKey:@"elem"];
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    NSLog(@"evaluateJavaScript : %@", [NSString stringWithFormat:@"%@", result]);
                } else {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
            }
        }];
    }
}

- (void)startLoading:(CDVInvokedUrlCommand*)command {

    [self runJavascript:@"preloadProgress();" withTitle:@"startLoading"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendScroll:(CDVInvokedUrlCommand*)command {
    if ([self checkArguments:command withTemplate:@[@"n",@"n",@"n"]]) {
        int left = [[command.arguments objectAtIndex:0] intValue];
        int top = [[command.arguments objectAtIndex:1] intValue];
        float scale = [[command.arguments objectAtIndex:2] floatValue];

        [self runJavascript:[NSString stringWithFormat:@"_ss_setScroll(%d,%d,%f,%f)", left, top, left/scale, top/scale] withTitle:@"sendScroll"];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)runJavascript:(NSString *)javascript withTitle:(NSString *)title {
    [htmlview evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                NSLog(@"%@ evaluateJavaScript : %@", title, [NSString stringWithFormat:@"%@", result]);
            }
        } else {
            NSLog(@"%@ evaluateJavaScript error : %@", title, error.localizedDescription);
        }
    }];

}

-(bool)checkArguments:(CDVInvokedUrlCommand*)command withTemplate:(NSArray*)template {
    bool valid = true;
    if (command.arguments.count != template.count) {
        valid = false;
    } else {
        for (int i = 0; i < template.count; i++) {
            if ([[template objectAtIndex:i] isEqualToString:@"n"] && ![[command.arguments objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
                valid = false;
            }
            if ([[template objectAtIndex:i] isEqualToString:@"s"] && ![[command.arguments objectAtIndex:i] isKindOfClass:[NSString class]]) {
                valid = false;
            }
            if ([[template objectAtIndex:i] isEqualToString:@"b"] && ![[command.arguments objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
                valid = false;
            }
            if ([[template objectAtIndex:i] isEqualToString:@"o"] && ![[command.arguments objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
                valid = false;
            }
        }
    }
    if (!valid) {
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        [payload setObject:command.arguments forKey:@"arguments"];
        [payload setObject:command.methodName forKey:@"methodName"];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: payload];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    return valid;
}

- (void)fakeCrash:(CDVInvokedUrlCommand*)command {
    [[Crashlytics sharedInstance] crash];
}
-(void)setCrashlytics:(CDVInvokedUrlCommand*)command{
    [[Crashlytics sharedInstance] setUserIdentifier:[command.arguments objectAtIndex:0]];
}


@end

