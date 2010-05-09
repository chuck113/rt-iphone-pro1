//
//  TableCellView.h
//  play2-list-prototype
//
//  Created by Charles on 18/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellView : UITableViewCell {
	UILabel *cellText;
	//IBOutlet UILabel *lines;
	//IBOutlet UILabel *artist;
	//IBOutlet UILabel *title;

	NSString *rawText;
	UIWebView *webView;
}

@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) NSString* rawText;

- (void)setLabelText:(NSString *)_text;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)height;
//- (void)setLinesText:(NSString *)_lines;
//- (void)setArtistText:(NSString *)_artist;
//- (void)setTitleText:(NSString *)_title;


@end
