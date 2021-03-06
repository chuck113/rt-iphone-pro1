//
//  rhymeTimeIPhoneUIViewController.h
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 27/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellView.h"
#import "HtmlBuilder.h"

@interface rhymeTimeIPhoneUIViewController : UIViewController<SearchBarCallback> {
	
	IBOutlet UITableView *searchResultTableView;
	IBOutlet UISearchBar* searchBar;
	NSArray *searchResult;	
	NSArray *webViewDelegates;
	HtmlBuilder* htmlBuilder;	
	NSArray* cellCache;
}

@property (nonatomic, retain) IBOutlet UITableView *searchResultTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *searchResult;
@property (nonatomic, retain) NSArray *webViewDelegates;
@property (nonatomic, retain) HtmlBuilder *htmlBuilder;
@property (nonatomic, retain) NSArray *cellCache;

//-(void)setSearchBarText:(NSString *)text;

@end




