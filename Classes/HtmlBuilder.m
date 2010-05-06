//
//  HtmlBuilder.m
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 06/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HtmlBuilder.h"

@implementation HtmlBuilder

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


- (NSArray *)deSerializeArray:(NSString*)string{
	return [string componentsSeparatedByString:@"%%%"];
}

- (NSString *)buildHtml:(RhymePart*)rhymePart{
	// convet to constants: static NSString *const HTTP_METHOD_POST = @"POST";
	NSString* linesStyle = [NSString stringWithString:@"style=\"font-family:Helvetica;font-size:14px\""];
	NSString* lineOpenPara = [NSString stringWithFormat:@"<p %@>", linesStyle];
	NSString* artistStyle = [NSString stringWithString:@"style=\"text-align:right;font-family:Arial;font-size:12px;color:darkblue\""];
	NSString* artistOpenPara = [NSString stringWithFormat:@"<p %@>", artistStyle];
	
	//rhymePart.rhymeLines
	//rhymePart.rhymeParts
	NSString* title = rhymePart.song.title;
	//NSLog(@"title is %@", title);
	NSString* artist = rhymePart.song.album.artist.name;
	//NSLog(@"artist is %@", artist);
	
	NSString *artistAndTite = [NSString stringWithFormat:@"%@ - %@", [artist uppercaseString], title];
	
	NSArray *parts = [self deSerializeArray:[rhymePart rhymeParts]];
	NSArray *lines = [self deSerializeArray:[rhymePart rhymeLines]];
	
	//NSLog(@"lines are %@", [self buildLines:lines]);
	
	
	NSMutableString* ms = [[NSMutableString alloc] initWithString:@"<html><head><title>/title></head><body>"];
	NSString* line = [self buildLines:lines];
	
	NSString* linesWithFormatting = [self applyFormatToRhymeParts:line parts:parts prefix:@"<b>" suffix:@"</b>"];
	//NSLog(@"linesWithFormatting: %@", linesWithFormatting);
	[ms appendString: [NSString stringWithFormat:@"%@%@</p>", lineOpenPara, linesWithFormatting]];
	[ms appendString: [NSString stringWithFormat:@"%@%@</p>", artistOpenPara, artistAndTite]];
	[ms appendString:@"</body></html>"];
	NSString *result =  [[NSString alloc] initWithString:ms];
	[ms dealloc];
	return result;
}



@end
