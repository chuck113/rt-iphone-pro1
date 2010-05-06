//
//  WebViewDelegate.m
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 04/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewDelegate.h"


@implementation WebViewDelegate
@synthesize webView, loaded, rawLines;


- (void)dealloc {
	// set webView delegate to nill before deallocation webView
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewCalled{
	[webView sizeToFit];
	self.loaded = TRUE;
	NSLog(@"BOOL = %@\n", (self.loaded ? @"YES" : @"NO"));
	NSLog ( @"Client height: %@", [webView stringByEvaluatingJavaScriptFromString: @"document.body.clientHeight"] );
	NSLog(@"WebViewDelegate, size is %f", webView.frame.size.height);
}

- (CGFloat)height{
	NSLog ( @"CALLING HEIGHT");
	return (CGFloat)webView.frame.size.height;
}

- (WebViewDelegate*)init{
	self.loaded = FALSE;	
	return self;
}

- (WebViewDelegate*)initWithWebViewAndLines:(UIWebView *)webViewParent lines:(NSString *)lines{
	self.loaded = FALSE;
	self.webView = webViewParent;
	self.rawLines = lines;
	NSLog(@"initWithWebView BOOL = %@\n", (self.loaded ? @"YES" : @"NO"));

	return self;
}

@end
