//
//  CDVCookieMaster.m
//
//
//  Created by Kristian Hristov on 12/16/14.
//
//

#import "CDVCookieMaster.h"


@implementation CDVCookieMaster
    
    - (void)getCookieValue:(CDVInvokedUrlCommand*)command
    {
        CDVPluginResult* pluginResult = nil;
        NSString* urlString = [command.arguments objectAtIndex:0];
        
        if (urlString != nil) {
            NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlString]];
            NSMutableArray *allCookies = [[NSMutableArray alloc] init];
            [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSHTTPCookie *cookie = obj;
                
                NSDictionary *cookieDictionary = [NSDictionary dictionaryWithObjectsAndKeys:cookie.name, @"key", cookie.value, @"value", nil];
                [allCookies addObject:cookieDictionary];
                
            }];
            if ([allCookies count] > 0) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:allCookies];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No cookie found"];
            }
            
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL was null"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    - (void)setCookieValue:(CDVInvokedUrlCommand*)command
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        CDVPluginResult* pluginResult = nil;
        NSString* urlString = [command.arguments objectAtIndex:0];
        NSString* cookieName = [command.arguments objectAtIndex:1];
        NSString* cookieValue = [command.arguments objectAtIndex:2];
        
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
        [cookieProperties setObject:cookieValue forKey:NSHTTPCookieValue];
        [cookieProperties setObject:urlString forKey:NSHTTPCookieOriginURL];
        [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        
        NSArray* cookies = [NSArray arrayWithObjects:cookie, nil];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
- (void)clearCookies:(CDVInvokedUrlCommand*)command
    {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    @end
