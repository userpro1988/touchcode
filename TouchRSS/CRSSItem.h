//
//  CRSSItem.h
//  TouchRSS
//
//  Created by Jonathan Wight on 9/8/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//

#import "CRSSObject.h"

@interface CRSSItem : CRSSObject {
	NSString *identifier;
	NSString *title;
	NSURL *link;
	NSString *description_;
	NSDate *publicationDate;
}

@property (readwrite, nonatomic, retain) NSString *identifier;
@property (readwrite, nonatomic, retain) NSString *title;
@property (readwrite, nonatomic, retain) NSURL *link;
@property (readwrite, nonatomic, retain) NSString *description_;
@property (readwrite, nonatomic, retain) NSDate *publicationDate;

@end
