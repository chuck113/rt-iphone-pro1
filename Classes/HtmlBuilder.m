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

//FIXME does not apply formatting to rhymes such as 'me' that rhyme with B.I.G - needs to break down words
- (NSString *)applyFormatToRhymeParts:(NSString *)lines parts:(NSArray *)parts partLinks:(NSArray *)partLinks prefix:(NSString  *)prefix suffix:(NSString *)suffix{
	NSSet* partSet = [NSSet setWithArray:parts];
	NSSet* partLinkSet = [NSSet setWithArray:partLinks];
	NSArray* words = [lines componentsSeparatedByString:@" "];
	NSMutableArray* wordBuffer = [[NSMutableArray alloc] init];
	
	for(int i=0; i<words.count; i++){
		NSString* word = [words objectAtIndex:i];
		NSString* decoratedWord = [NSString stringWithString:word];
		NSString* upperCaseCleanedWord = [self removePunctuation:[word uppercaseString]];
		NSString* cleanedWord = [self removePunctuation:word];

		if([partLinkSet containsObject:upperCaseCleanedWord]){
			decoratedWord = [NSString stringWithFormat:@"<a href=rhymetime://local/lookup/%@>%@</a>", cleanedWord, word];
		}
		
		if([partSet containsObject:upperCaseCleanedWord]){
			decoratedWord = [NSString stringWithFormat:@"%@%@%@", prefix, decoratedWord, suffix];
		}
		
		[wordBuffer addObject:[NSString stringWithFormat:@"%@ ", decoratedWord]];
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
	NSString* lineOpenPara = [NSString stringWithFormat:@"<div id=\"lines\" %@>", linesStyle];
	NSString* artistStyle = [NSString stringWithString:@"style=\"text-align:right;font-family:Arial;font-size:12px;color:darkblue\""];
	NSString* artistOpenPara = [NSString stringWithFormat:@"<div id=\"title\" %@>", artistStyle];

	NSString* title = rhymePart.song.title;
	NSString* artist = rhymePart.song.album.artist.name;
	
	NSString *artistAndTite = [NSString stringWithFormat:@"%@ - %@", [artist uppercaseString], title];
	
	NSArray *parts = [self deSerializeArray:[rhymePart rhymeParts]];
	NSArray *lines = [self deSerializeArray:[rhymePart rhymeLines]];
	NSArray *partLinks = [NSArray arrayWithObject:@"ME"];
	
	NSMutableString* ms = [[NSMutableString alloc] initWithString:@"<html><head><title>/title></head><body>"];
	NSString* line = [self buildLines:lines];
	
	NSString* linesWithFormatting = [self applyFormatToRhymeParts:line parts:parts partLinks:partLinks prefix:@"<b>" suffix:@"</b>"];

	[ms appendString: [NSString stringWithFormat:@"%@%@</div>", lineOpenPara, linesWithFormatting]];
	[ms appendString: [NSString stringWithFormat:@"%@%@</div>", artistOpenPara, artistAndTite]];
	[ms appendString:@"</body></html>"];
	NSString *result =  [[NSString alloc] initWithString:ms];
	[ms dealloc];
	return result;
}



@end
