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

- (NSString *)buildHtml;
- (NSArray*)findRhymes:(NSString *)toFind;

@end


@implementation rhymeTimeIPhoneUIViewController

@synthesize searchResultTableView;
@synthesize searchResult;


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"search button pressed");
	
	// Make the keyboard go away.
	[searchBar resignFirstResponder];
	
	self.searchResult = [self findRhymes:searchBar.text];
	
	// Tell the UITableView to reload its data.
	[self.searchResultTableView reloadData];
}

- (NSArray *)deSerializeArray:(NSString*)string{
	return [string componentsSeparatedByString:@"%%%"];
}

//-(NSArray *)deSerializeResult:(NSArray *)items{
//	NSMutableArray *buffer = [[NSMutableArray alloc] initWithCapacity:items.count];
//	
//	for (int i = 0; i<items.count;i++) {
//		buffer[i] = [self deSerializeArray:items[i]];
//	}
//	
//	return [[NSArray alloc] initWithArray:buffer];
//}

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
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word contains[cd] %@", toFind];
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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.searchResult count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSLog(@"called heightForRowAtIndexPath, returend 300"); 
	return 120;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"RTIdentifier";
	
	TableCellView *cell = (TableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSLog(@"Creating new cell");
	if(cell == nil) {
		cell = [[[TableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	RhymePart* rhymePart = (RhymePart*)[searchResult objectAtIndex:indexPath.row];
	
	NSString* html = [self buildHtml:rhymePart];
		
	[cell setLabelText:html];
	
	NSLog(@"setting cell %i to %@", indexPath.row, html);
	
	return cell;
}

- (NSString *)buildLines:(NSArray *)lines{
	NSMutableString* ms = [[NSMutableString alloc] initWithString:@""];
	
	for(int i = 0; i < lines.count-1; i++){
		[ms appendString:[lines objectAtIndex:i]];
		[ms appendString:@" / "];
	}
	[ms appendString:[lines objectAtIndex:(lines.count -1)]];
	return [[NSString alloc] initWithString:ms];
}

- (NSString *)removePunctuation:(NSString *)line{
	return [line stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
}

- (NSString *)applyFormatToRhymeParts:(NSString *)lines parts:(NSArray *)parts prefix:(NSString  *)prefix suffix:(NSString *)suffix{
	NSSet* partSet = [[NSSet alloc] initWithArray:parts];
	NSArray* words = [lines componentsSeparatedByString:@" "];
	NSMutableArray* wordBuffer = [[NSMutableArray alloc] init];
	
	for(int i=0; i<words.count; i++){
		NSString* word = [words objectAtIndex:i];
		if([partSet containsObject:[self removePunctuation:[word uppercaseString]]]){
			[wordBuffer addObject:[NSString stringWithFormat:@"%@%@%@ ", prefix, word, suffix]];
		}else{
			[wordBuffer addObject:[NSString stringWithFormat:@"%@ ", word]]; //TODO remove trailing space
		}
	}
		
	NSMutableString* stringBuffer = [[NSMutableString alloc] init];
	for(NSString* word in wordBuffer){
		[stringBuffer appendString:word];
	}
		
	[wordBuffer dealloc];
	return [NSString stringWithString:stringBuffer];
}

- (NSString *)testHtml{
	NSMutableString* ms = [[NSMutableString alloc] initWithString:@"<html><head><title>/title></head><body>"];
	[ms appendString:@"<p>I pour a hieneken <b>brew</b> to my dececed <b>crew</b> in memory lane</p>"];
	[ms appendString:@"<p>NAS - Memory Lane</p>"];
	return [[NSString alloc] initWithString:ms];
}


- (NSString *)buildHtml:(RhymePart*)rhymePart{
	// convet to constants: static NSString *const HTTP_METHOD_POST = @"POST";
	NSString* linesStyle = [NSString stringWithString:@"style=\"font-family:Helvetica\""];
	NSString* lineOpenPara = [NSString stringWithFormat:@"<p %@>", linesStyle];
	NSString* artistStyle = [NSString stringWithString:@"style=\"text-align:right;font-family:Arial;font-size:12px;color:darkblue\""];
	NSString* artistOpenPara = [NSString stringWithFormat:@"<p %@>", artistStyle];
	
	//rhymePart.rhymeLines
	//rhymePart.rhymeParts
	NSString* title = rhymePart.song.title;
	NSLog(@"title is %@", title);
	NSString* artist = rhymePart.song.album.artist.name;
	NSLog(@"artist is %@", artist);

	NSString *artistAndTite = [NSString stringWithFormat:@"%@ - %@", [artist uppercaseString], title];
	
	NSArray *parts = [self deSerializeArray:[rhymePart rhymeParts]];
	NSArray *lines = [self deSerializeArray:[rhymePart rhymeLines]];

	NSLog(@"lines are %@", [self buildLines:lines]);

	
	NSMutableString* ms = [[NSMutableString alloc] initWithString:@"<html><head><title>/title></head><body>"];
	NSString* line = [self buildLines:lines];
	
	NSString* linesWithFormatting = [self applyFormatToRhymeParts:line parts:parts prefix:@"<b>" suffix:@"</b>"];
	NSLog(@"linesWithFormatting: %@", linesWithFormatting);
	[ms appendString: [NSString stringWithFormat:@"%@%@</p>", lineOpenPara, linesWithFormatting]];
	[ms appendString: [NSString stringWithFormat:@"%@%@</p>", artistOpenPara, artistAndTite]];
	[ms appendString:@"</body></html>"];
	NSString *result =  [[NSString alloc] initWithString:ms];
	[ms dealloc];
	return result;
}

//#define MAINLABEL_TAG 1
//#define SECONDLABEL_TAG 2
//
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//	static NSString *CellIdentifier = @"ImageOnRightCell";
//	
//    UILabel *mainLabel, *secondLabel;
//
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    
//		mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, 15.0)] autorelease];
//        mainLabel.tag = MAINLABEL_TAG;
//        mainLabel.font = [UIFont systemFontOfSize:14.0];
//        mainLabel.textAlignment = UITextAlignmentRight;
//        mainLabel.textColor = [UIColor blackColor];
//        mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//        [cell.contentView addSubview:mainLabel];
//		
//        secondLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 220.0, 25.0)] autorelease];
//        secondLabel.tag = SECONDLABEL_TAG;
//        secondLabel.font = [UIFont systemFontOfSize:12.0];
//        secondLabel.textAlignment = UITextAlignmentRight;
//        secondLabel.textColor = [UIColor darkGrayColor];
//        secondLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//        [cell.contentView addSubview:secondLabel];
//	}
//	
//	//NSDictionary *aDict = [self.list objectAtIndex:indexPath.row];
//    mainLabel.text = @"here is some rap words that go on / for a bit, hope if fits well";//[aDict objectForKey:@"mainTitleKey"];
//    secondLabel.text = @"from an artist - song title";//[aDict objectForKey:@"secondaryTitleKey"];
//    
//	// Configure the cell.
//	//cell.textLabel.text = [self.drinks objectAtIndex:indexPath.row];
//
//    return cell;
//}



/*
 // Override to support row selection in the table view.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 // Navigation logic may go here -- for example, create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController animated:YES];
 // [anotherViewController release];
 }
 */


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


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
