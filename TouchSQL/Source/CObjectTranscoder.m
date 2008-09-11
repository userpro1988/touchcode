//
//  CObjectTranscoder.m
//  ProjectV
//
//  Created by Jonathan Wight on 9/11/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//

#import "CObjectTranscoder.h"

#import "NSDate_SqlExtension.h"

#import <objc/runtime.h>

static const char* getPropertyType(objc_property_t property);

@implementation CObjectTranscoder

@synthesize targetObjectClass;
@synthesize propertyNameMappings;

- (id)initWithTargetObjectClass:(Class)inTargetObjectClass
{
if ((self = [super init]) != NULL)
	{
	self.targetObjectClass = inTargetObjectClass;
	self.propertyNameMappings = [NSDictionary dictionaryWithObjectsAndKeys:
		@"rowID", @"id",
		NULL];
	}
return(self);
}

- (void)dealloc
{
self.propertyNameMappings = NULL;
//
[super dealloc];
}

#pragma mark -

- (BOOL)updateObject:(id)inObject withPropertiesInDictionary:(NSDictionary *)inDictionary error:(NSError **)outError
{
Class theClass = [inObject class];
// TODO we really want to do all validation and fail before modifying the object.
for (NSString *theKey in inDictionary)
	{
	// TODO validate that keys are proper property names.
	
	if ([self.propertyNameMappings objectForKey:theKey])
		theKey = [self.propertyNameMappings objectForKey:theKey];
	
	id theValue = [inDictionary objectForKey:theKey];
	
	objc_property_t theProperty = class_getProperty(theClass, [theKey UTF8String]);
	if (theProperty == NULL)
		continue;
	
	const char *thePropertyAttributes = property_getAttributes(theProperty);
	BOOL theIsObjectFlag = NO;
	if (strncmp(thePropertyAttributes, "T@", 2) == 0)
		theIsObjectFlag = YES;
	const char *thePropertyType = getPropertyType(theProperty);
	if (theIsObjectFlag == NO)
		{
		switch (thePropertyType[0])
			{
			case 'i':
				{
				if ([theValue respondsToSelector:@selector(intValue)] == NO)
					return(NO);
				[inObject setValue:theValue forKey:theKey];	
				}
				break;
			}
		}
	else
		{
		char theBuffer[strlen(thePropertyType) + 1];
		strncpy(theBuffer, thePropertyType + 2, strlen(thePropertyType) - 3);
		theBuffer[strlen(thePropertyType) - 3] = '\0';
		theValue = [self transformObject:theValue toObjectOfClass:NSClassFromString([NSString stringWithUTF8String:theBuffer]) error:outError];
		}
		
	if (theValue)
		[inObject setValue:theValue forKey:theKey];
	}
return(YES);
}

#pragma mark -

- (id)transformObject:(id)inObject toObjectOfClass:(Class)inTargetClass error:(NSError **)outError
{
if ([inObject isKindOfClass:[NSString class]] && inTargetClass == [NSString class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSString class]] && inTargetClass == [NSURL class])
	{
	return([NSURL URLWithString:inObject]);
	}
else if ([inObject isKindOfClass:[NSDate class]] && inTargetClass == [NSDate class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSURL class]] && inTargetClass == [NSURL class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSURL class]] && inTargetClass == [NSString class])
	{
	return([inObject description]);
	}
else if ([inObject isKindOfClass:[NSString class]] && inTargetClass == [NSDate class])
	{
//	return([NSDate dateWithSqlString:inObject]);
	}
else if ([inObject isKindOfClass:[NSDate class]] && inTargetClass == [NSString class])
	{
	return([inObject sqlDateString]);
	}
return(NULL);
}

#pragma mark -

@end

static const char* getPropertyType(objc_property_t property) {
    // parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
    // character 'T' should really just use strsep for this, using a C99 variable sized array.
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            // return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
        }
    }
    return "@";
}