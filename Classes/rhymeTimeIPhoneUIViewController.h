//
//  rhymeTimeIPhoneUIViewController.h
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 27/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellView.h"


@interface rhymeTimeIPhoneUIViewController : UIViewController {
	
	IBOutlet UITableView *searchResultTableView;
	NSArray *searchResult;
}

@property (nonatomic, retain) IBOutlet UITableView *searchResultTableView;
@property (nonatomic, retain) NSArray *searchResult;

@end

