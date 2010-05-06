//
//  WebViewDelegate.h
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 04/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewDelegate : NSObject {
	UIWebView* webView;
	NSString* rawLines;
	BOOL loaded;
}

@property (nonatomic, retain) UIWebView* webView;
@property BOOL loaded;
@property (nonatomic, retain) NSString* rawLines;


- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (WebViewDelegate*)initWithWebView:(UIWebView *)webView;
- (CGFloat)height;


@end
