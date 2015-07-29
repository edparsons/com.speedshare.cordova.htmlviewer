//
//  SpeedsharePlugin.h
//
//  Copyright (c) 2015 Osix Corp. All rights reserved.
//  Please see the LICENSE included with this distribution for details.
//

#import <Cordova/CDVPlugin.h>

@interface HtmlViewerPlugin : CDVPlugin


- (void)startSession:(CDVInvokedUrlCommand*)command;
- (void)stopSession:(CDVInvokedUrlCommand*)command;
- (void)updateView:(CDVInvokedUrlCommand*)command;
- (void)updateDOM:(CDVInvokedUrlCommand*)command;
- (void)updateHTML:(CDVInvokedUrlCommand*)command;
- (void)bringToFront:(CDVInvokedUrlCommand*)command;
- (void)sendToBack:(CDVInvokedUrlCommand*)command;
- (void)sendScroll:(CDVInvokedUrlCommand*)command;

@end
