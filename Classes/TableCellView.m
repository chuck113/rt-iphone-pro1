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
@synthesize webView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)] autorelease];
		[webView setDelegate:self];
		//[webView setBackgroundColor:[UIColor blueColor]];
		[self addSubview:webView];
    }
    return self;
}

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

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	NSLog(@"web view did finish download, size is %f", webView.frame.size.height);
}

//-(UIWebView *)getWebView{
	

- (void)setLabelText:(NSString *)_text;{
	//NSLog(@"text is %@", _text);
	[webView loadHTMLString:_text baseURL:nil];
	[webView sizeToFit];
}



@end
