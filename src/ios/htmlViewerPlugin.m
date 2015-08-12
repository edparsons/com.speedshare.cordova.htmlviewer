//
//  SpeedsharePlugin.m
//
//  Copyright (c) 2015 Osix Corp. All rights reserved.
//  Please see the LICENSE included with this distribution for details.
//

#import "htmlViewerPlugin.h"

@implementation HtmlViewerPlugin{
    NSMutableDictionary *videoState;
    WKWebView *htmlview;
    CADisplayLink *displayLink;
    NSString *startHTML;
    NSString *env;
    //NSDictionary *pendingDomUpdate;
    NSMutableArray *pendingDomUpdates;
    bool loading;
}

#pragma mark -
#pragma mark Cordova Methods
-(void) pluginInitialize{
    videoState = [[NSMutableDictionary alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuspend:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume:) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self name:@"speedshare"];
    
    htmlview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:theConfiguration];
    
    env = @"sync-trial.speedshare.com";
    
    htmlview.navigationDelegate = self;
    
    loading = false;
    
    [self.webView.superview insertSubview:htmlview atIndex:0];
    self.webView.keyboardDisplayRequiresUserAction = false;
//    [self.webView.superview addSubview:htmlview];
 
    htmlview.hidden = YES;

    //displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick)];
    //displayLink.paused = YES;
    
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mirror" ofType:@"html"];
    startHTML = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
    pendingDomUpdates = [NSMutableArray array];
    
    self.webView.layer.zPosition = 4;
    htmlview.layer.zPosition = 1;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   loading = false;
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

-(void)startSession:(CDVInvokedUrlCommand*)command{
    int top = [[command.arguments objectAtIndex:2] intValue];
    int left = [[command.arguments objectAtIndex:3] intValue];
    int width = [[command.arguments objectAtIndex:4] intValue];
    int height = [[command.arguments objectAtIndex:5] intValue];
    env = [command.arguments objectAtIndex:6];
    
    htmlview.frame = CGRectMake(left, top, width, height);

    htmlview.hidden = NO;
    
    htmlview.backgroundColor = [UIColor whiteColor];
    
    htmlview.clearsContextBeforeDrawing = YES;
    htmlview.clipsToBounds = YES;
    htmlview.multipleTouchEnabled = NO;
    htmlview.opaque = YES;
    //htmlview.scalesPageToFit = NO;
    htmlview.userInteractionEnabled = YES;

    [self updateHTML:command];
}

-(void)stopSession:(CDVInvokedUrlCommand*)command{
    [htmlview loadHTMLString:startHTML baseURL:[NSURL URLWithString:@"https://"]];

    htmlview.hidden = YES;
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)updateView:(CDVInvokedUrlCommand*)command{
    int top = [[command.arguments objectAtIndex:0] intValue];
    int left = [[command.arguments objectAtIndex:1] intValue];
    int width = [[command.arguments objectAtIndex:2] intValue];
    int height = [[command.arguments objectAtIndex:3] intValue];
    
    NSLog(@"%d, %d, %d, %d", left, top, width, height);
    
    if (htmlview) {
        htmlview.frame = CGRectMake(left, top, width, height);
        [htmlview setNeedsDisplay];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)updateHTML:(CDVInvokedUrlCommand*)command {
    NSString* base = [command.arguments objectAtIndex:0];
    [pendingDomUpdates addObject:[command.arguments objectAtIndex:1]];

    NSURL *url;
    if ([base hasPrefix:@"http://"]) {
       url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/mirror.html", env]];
    } else {
       url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/mirror.html", env]];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [htmlview loadRequest:request];
    loading = true;

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)updateDOM:(CDVInvokedUrlCommand*)command {
    [pendingDomUpdates addObject:[command.arguments objectAtIndex:0]];
    if (!loading) {
        [self runDomUpdates];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
                    NSLog(@"updateDom evaluateJavaScript no result");
                }
            } else {
                NSLog(@"updateDom evaluateJavaScript error : %@", error.localizedDescription);
            }
        }];
        [pendingDomUpdates removeObjectAtIndex:0];
    }
}

- (void)bringToFront:(CDVInvokedUrlCommand*)command {
    [self.webView.superview bringSubviewToFront:htmlview];
}

- (void)sendToBack:(CDVInvokedUrlCommand*)command {
    [self.webView.superview sendSubviewToBack:htmlview];
}

- (void)checkElement:(CDVInvokedUrlCommand*)command {
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

- (void)sendScroll:(CDVInvokedUrlCommand*)command {
    int top = [[command.arguments objectAtIndex:0] intValue];

    [htmlview evaluateJavaScript:[NSString stringWithFormat:@"window.scrollTo(0, %d);", top] completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                NSLog(@"sendScroll evaluateJavaScript : %@", [NSString stringWithFormat:@"%@", result]);
            }
        } else {
            NSLog(@"sendScroll evaluateJavaScript error : %@", error.localizedDescription);
        }
    }];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end

