//
//  rhymeTimeIPhoneUIViewController.m
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 27/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "rhymeTimeIPhoneUIViewController.h"
#import "rhymeTimeIPhoneUIAppDelegate.h"
#import "WebViewDelegate.h"
#import "TableCellView.h"
#import "RhymePart.h"
#import "Song.h"
#import "Album.h"
#import "Artist.h"
#import "math.h"

@interface rhymeTimeIPhoneUIViewController()

- (NSArray*)findRhymes:(NSString *)toFind;
- (CGFloat)heightOfString:(NSString *)string;

@end


@implementation rhymeTimeIPhoneUIViewController

@synthesize searchResultTableView;
@synthesize searchResult;
@synthesize webViewDelegates;
@synthesize htmlBuilder;

//- (NSArray*)makeResultWebViews:(NSArray*)searchResults{
//	
//	NSMutableArray* result = [[NSMutableArray alloc] init];
//	
//	for(RhymePart* part in searchResults){
//		UIWebView* webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)] autorelease];
//		WebViewDelegate *webViewDelegate = [[WebViewDelegate alloc] initWithWebViewAndLines:webView lines:part.rhymeLines];
//		[webView setDelegate:webViewDelegate];
//		NSString* html = [self buildHtml:part];
//		NSLog(@"setting html to %@", html);
//		[webView loadHTMLString:html baseURL:nil];
//		[result addObject:webViewDelegate];
//	}
//	NSLog(@"makeResultWebViews built %i results", result.count);
//	//[result dealloc];
//	return [NSArray arrayWithArray:result];
//	
//}

- (void)reloadTableData{
	NSLog(@"Reloading data...");
	[self.searchResultTableView reloadData];
}

- (void)blockUntilWebViewsAreLoaded:(NSArray*)delegates{
	[self performSelector:@selector(reloadTableData) withObject:nil afterDelay:1.0];
    
	//BOOL allDone = FALSE;
//	
//	while(!allDone){
//		[NSThread sleepForTimeInterval:1.0];
//		BOOL allComplete = TRUE;
//		for(WebViewDelegate* del in delegates){
//			NSLog(@"is done: %@", del.loaded);
//			if(!del.loaded){
//				allComplete = FALSE;
//				break;
//			}
//		}
//		
//		if(allComplete){
//			allDone = TRUE;
//		}
//	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"search button pressed");
	
	// Make the keyboard go away.
	[searchBar resignFirstResponder];
	
	self.searchResult = [self findRhymes:searchBar.text];
	
	//self.webViewDelegates = [self makeResultWebViews:self.searchResult];
	//[self blockUntilWebViewsAreLoaded:self.webViewDelegates];
	// Tell the UITableView to reload its data.
	
	[self reloadTableData];
}

/**
 *	returns an array of rhymeParts
 */
- (NSArray*)findRhymes:(NSString *)toFind{
	NSLog(@"Finding rhymes for word: %@", toFind);
	rhymeTimeIPhoneUIAppDelegate *appDelegate = (rhymeTimeIPhoneUIAppDelegate*)[[UIApplication sharedApplication] delegate]; 
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RhymePart"  
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word contains[cd] %@", toFind];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word like[cd] %@", toFind];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

	[fetchRequest release];
	
	NSLog(@"found rhymes: %i", items.count);
	
	if (![managedObjectContext save:&error]) {
        NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        return [NSArray init];
    }
	
	
	double resultsToShowDouble = fmin(10.0, [[[NSNumber alloc] initWithInt:items.count] doubleValue]);
	NSLog(@"will show %f results", resultsToShowDouble);

	int resultsToShow = [[[NSNumber alloc] initWithDouble:resultsToShowDouble] intValue];
	NSLog(@"will show %i results", resultsToShow);
	
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	
	for(int i = 0; i < resultsToShow; i++){
		[resultArray addObject:[items objectAtIndex:i]];
	}
	
	//RhymePart * found = (RhymePart *)[items objectAtIndex:0];
	
	NSLog(@"result array has %i entreis", resultArray.count);
	
	return [[NSArray alloc] initWithArray:resultArray];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.htmlBuilder = [HtmlBuilder alloc];
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.searchResult count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSLog(@"called heightForRowAtIndexPath, returend %f", [[self.webViewDelegates objectAtIndex:indexPath.row] height]); 
	//return [[self.webViewDelegates objectAtIndex:indexPath.row] height];
	RhymePart* rhymePart = (RhymePart*)[self.searchResult objectAtIndex:indexPath.row];
	return [self heightOfString:rhymePart.rhymeLines];
	//return 1.0f;
}

- (CGFloat)heightOfString:(NSString *)string{
	struct CGSize size;
	size = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(300.0, 300.0) lineBreakMode:UILineBreakModeCharacterWrap];
	return size.height +50.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"RTIdentifier";
	RhymePart* rhymePart = (RhymePart*)[searchResult objectAtIndex:indexPath.row];
	CGFloat height = [self heightOfString:rhymePart.rhymeLines];
	NSLog(@"getting cell for %i for lines %@", indexPath.row, rhymePart.rhymeLines);

	TableCellView *cell = (TableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//if(cell == nil) {
		cell = [[[TableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier height:height] autorelease];
	NSLog(@"built cell");
	//}

	
	NSString* html = [htmlBuilder buildHtml:rhymePart];
		
	[cell setLabelText:html];
	
	//NSLog(@"setting cell %i to %@", indexPath.row, html);
	
	return cell;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
