//
//  SpeedsharePlugin.m
//
//  Copyright (c) 2015 Osix Corp. All rights reserved.
//  Please see the LICENSE included with this distribution for details.
//

#import "htmlViewerPlugin.h"

@implementation HtmlViewerPlugin{
    NSMutableDictionary *videoState;
    UIWebView *htmlview;
    CADisplayLink *displayLink;
    NSString *startHTML;
    NSDictionary *pendingDomUpdate;
}

#pragma mark -
#pragma mark Cordova Methods
-(void) pluginInitialize{
    videoState = [[NSMutableDictionary alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuspend:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume:) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    htmlview = [[UIWebView alloc] init];
    
    htmlview.frame = CGRectMake(0, 0, 0, 0);
    
    [self.webView.superview insertSubview:htmlview atIndex:0];
//    [self.webView.superview addSubview:htmlview];
 
    htmlview.hidden = YES;

    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick)];
    displayLink.paused = YES;
    
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mirror" ofType:@"html"];
    startHTML = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
    pendingDomUpdate = nil;
    
    self.webView.layer.zPosition = 4;
    htmlview.layer.zPosition = 2;
}

- (void)onSuspend:(NSNotification *) notification {
}
- (void)onResume:(NSNotification *) notification {
}
- (void)animationTick {
    htmlview.frame = CGRectMake(htmlview.frame.origin.x, htmlview.frame.origin.y, htmlview.frame.size.width, htmlview.frame.size.height);
    displayLink.paused = YES;
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
    
    htmlview.frame = CGRectMake(left, top, width, height);

    htmlview.hidden = NO;
    
    htmlview.backgroundColor = [UIColor whiteColor];
    
    htmlview.clearsContextBeforeDrawing = YES;
    htmlview.clipsToBounds = YES;
    htmlview.multipleTouchEnabled = NO;
    htmlview.opaque = YES;
    htmlview.scalesPageToFit = NO;
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
    pendingDomUpdate = [command.arguments objectAtIndex:1];

    [htmlview loadHTMLString:startHTML baseURL:[NSURL URLWithString:@"https://"]];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)updateDOM:(CDVInvokedUrlCommand*)command {
    NSData* jsonData;
    NSString* jsonString;
    if (pendingDomUpdate != nil) {
        jsonData = [NSJSONSerialization dataWithJSONObject:pendingDomUpdate options:0 error:nil];
        jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        
        [htmlview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onMessage(%@)", jsonString]];
        
        pendingDomUpdate = nil;
    }
    NSString* domUpdate = [command.arguments objectAtIndex:0];
    
    jsonData = [NSJSONSerialization dataWithJSONObject:domUpdate options:0 error:nil];
    jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    [htmlview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onMessage(%@)", jsonString]];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)bringToFront:(CDVInvokedUrlCommand*)command {
    [self.webView.superview bringSubviewToFront:htmlview];
}

- (void)sendToBack:(CDVInvokedUrlCommand*)command {
    [self.webView.superview sendSubviewToBack:htmlview];
}

- (void)sendScroll:(CDVInvokedUrlCommand*)command {
    int top = [[command.arguments objectAtIndex:0] intValue];

    [htmlview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);", top]];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end

