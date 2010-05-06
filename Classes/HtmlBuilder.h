//
//  HtmlBuilder.h
//  rhymeTimeIPhoneUI
//
//  Created by Charles on 06/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RhymePart.h"
#import "Song.h"
#import "Album.h"
#import "Artist.h"

@interface HtmlBuilder : NSObject {

}

- (NSString*)buildHtml:(RhymePart*)rhymePart;

@end
