//
//  rhymeTimeIPhoneUIViewController.m
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 27/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "rhymeTimeIPhoneUIViewController.h"
#import "rhymeTimeIPhoneUIAppDelegate.h"
#import "TableCellView.h"
#import "RhymePart.h"
#import "Song.h"
#import "Album.h"
#import "Artist.h"
#import "math.h"

@interface rhymeTimeIPhoneUIViewController()

- (NSArray*)findRhymes:(NSString *)toFind;
- (CGFloat)heightOfString:(NSString *)string;
-(NSArray *)buildResultsArray:(NSArray *)items maxResults:(double)maxResults;
-(NSArray *)buildResultCells:(NSArray *)results;

@end


@protocol SearchBarCallback;
@implementation rhymeTimeIPhoneUIViewController

@synthesize searchResultTableView;
@synthesize searchBar;
@synthesize searchResult;
@synthesize webViewDelegates;
@synthesize htmlBuilder;

@synthesize cellCache;


- (void)reloadTableData{
	NSLog(@"Reloading data...");
	[self.searchResultTableView reloadData];
}

- (void)blockUntilWebViewsAreLoaded:(NSArray*)delegates{
	[self performSelector:@selector(reloadTableData) withObject:nil afterDelay:1.0];
}

-(void)setSearchBarText:(NSString *)text{
	[searchBar setText:text];
	
	self.searchResult = [self findRhymes:text];
	self.cellCache = [self buildResultCells:self.searchResult];
	
	// Tell the UITableView to reload its data.	
	[self reloadTableData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarRef {
	NSLog(@"search button pressed");
	
	// Make the keyboard go away.
	[searchBarRef resignFirstResponder];
	
	self.searchResult = [self findRhymes:searchBarRef.text];
	self.cellCache = [self buildResultCells:self.searchResult];

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
	
	return [self buildResultsArray:items maxResults:20.0];
}

-(NSArray *)buildResultsArray:(NSArray *)items maxResults:(double)maxResults{
	double resultsToShowDouble = fmin(maxResults, [[[NSNumber alloc] initWithInt:items.count] doubleValue]);
	NSLog(@"will show %f results", resultsToShowDouble);
	
	int resultsToShow = [[[NSNumber alloc] initWithDouble:resultsToShowDouble] intValue];
	NSLog(@"will show %i results", resultsToShow);
	
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	NSMutableSet* lines = [NSMutableSet set];
	
	for(int i = 0; (i < [items count]) && ([resultArray count] < resultsToShow); i++){
		RhymePart* part = (RhymePart*)[items objectAtIndex:i];
		if(![lines containsObject:part.rhymeLines]){
			[lines addObject:part.rhymeLines];
			[resultArray addObject:[items objectAtIndex:i]];
		}
	}
		
	NSLog(@"result array has %i entreis", resultArray.count);
	
	NSArray* result = [NSArray arrayWithArray:resultArray];
	[resultArray dealloc];
	return result;
}

-(NSArray *)buildResultCells:(NSArray *)results{
	NSMutableArray* cellBuffer = [NSMutableArray array];
	for(RhymePart* part in results){
		//TODO do we need to pass height in here?
		CGFloat height = [self heightOfString:part.rhymeLines];
		TableCellView* cell = [[[TableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NEVER" height:height] autorelease];
		NSString* html = [htmlBuilder buildHtml:part];
		[cell setLabelText:html];
		cell.delegate = self;
		[cellBuffer addObject:cell];
	}
	
	return[NSArray arrayWithArray:cellBuffer];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"selected row %i", indexPath.row);

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	//return [[self.webViewDelegates objectAtIndex:indexPath.row] height];
	RhymePart* rhymePart = (RhymePart*)[self.searchResult objectAtIndex:indexPath.row];
	NSLog(@"called heightForRowAtIndexPath, returend %f", [self heightOfString:rhymePart.rhymeLines]); 

	return [self heightOfString:rhymePart.rhymeLines];
}

// TODO needs refinement
- (CGFloat)heightOfString:(NSString *)string{
	struct CGSize size;
	size = [string sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14] constrainedToSize:CGSizeMake(320.0, 320.0) lineBreakMode:UILineBreakModeCharacterWrap];
	NSLog(@"heightOfString %f for %@", size.height, string); 
	return size.height +15.0f + 15.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cellCache objectAtIndex:indexPath.row];
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
