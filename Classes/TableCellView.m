//
//  TableCellView.m
//  play2-list-prototype
//
//  Created by Charles on 18/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableCellView.h"


@implementation TableCellView

//@synthesize lines, artist, title;
@synthesize webView, rawText;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)height{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
		[webView setDelegate:self];
		[self addSubview:webView];
    }
    return self;
}

//- (UIWebView*) getWebView{
//	return self.webView;
//}
//
//
//- (void) setWebView:(UIWebView*)webViewToUse{
//	self.webView = webViewToUse;
//}

//		mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, 15.0)] autorelease];
//        mainLabel.tag = MAINLABEL_TAG;
//        mainLabel.font = [UIFont systemFontOfSize:14.0];
//        mainLabel.textAlignment = UITextAlignmentRight;
//        mainLabel.textColor = [UIColor blackColor];
//        mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//        [cell.contentView addSubview:mainLabel];


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	// set webView delegate to nill before deallocation webView
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)theView{
	NSLog(@"web view did finish download, size is %f for %@", theView.frame.size.height, rawText);
	[self heightOfString:rawText];
	//NSLog(@"raw text size is %f", [self heightOfString:rawText]);
	NSLog(@"lines Client height: %@", [theView stringByEvaluatingJavaScriptFromString: @"document.getElementById('lines').clientHeight"] );
	NSLog(@"lines Client height: %@", [theView stringByEvaluatingJavaScriptFromString: @"document.getElementById('title').clientHeight"] );
}

// TODO needs refinement
- (CGFloat)heightOfString:(NSString *)string{
	NSString* stringWithPadding = [NSString stringWithFormat:@"%@%@", string, @""];
	struct CGSize size;
	size = [stringWithPadding sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14] constrainedToSize:CGSizeMake(320.0, 320.0) lineBreakMode:UILineBreakModeCharacterWrap];
	NSLog(@"heightOfString %f for %@", size.height, string); 
	return size.height;
}

//-(UIWebView *)getWebView{
	

- (void)setLabelText:(NSString *)_text;{
	//struct CGSize size;
	//size = [_text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(300.0, 300.0) lineBreakMode:UILineBreakModeCharacterWrap];
	//NSLog(@"called heightForRowAtIndexPath, returend %f", (size.height +50.0f)); 
	//NSLog(@"text is %@", _text);
	//[webView setFrame:CGRectMake(0, 0, 320, (size.height +50.0f))];
	[webView loadHTMLString:_text baseURL:nil];
	[webView sizeToFit];
}



@end
