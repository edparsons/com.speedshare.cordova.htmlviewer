//
//  SpeedsharePlugin.h
//
//  Copyright (c) 2015 Osix Corp. All rights reserved.
//  Please see the LICENSE included with this distribution for details.
//

#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>

@interface HtmlViewerPlugin : CDVPlugin <WKNavigationDelegate, WKScriptMessageHandler>


- (void)startSession:(CDVInvokedUrlCommand*)command;
- (void)stopSession:(CDVInvokedUrlCommand*)command;
- (void)updateView:(CDVInvokedUrlCommand*)command;
- (void)updateDOM:(CDVInvokedUrlCommand*)command;
- (void)updateHTML:(CDVInvokedUrlCommand*)command;
- (void)updateInternalView:(CDVInvokedUrlCommand*)command;
- (void)bringToFront:(CDVInvokedUrlCommand*)command;
- (void)sendToBack:(CDVInvokedUrlCommand*)command;
- (void)sendScroll:(CDVInvokedUrlCommand*)command;
- (void)checkElement:(CDVInvokedUrlCommand*)command;
- (void)startLoading:(CDVInvokedUrlCommand*)command;

@end
