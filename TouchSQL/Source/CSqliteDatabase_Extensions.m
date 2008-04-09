//
//  CSqliteDatabase_Extensions.m
//  DBTest
//
//  Created by Jonathan Wight on Tue Apr 27 2004.
//  Copyright (c) 2004 Toxic Software. All rights reserved.
//

#import "CSqliteDatabase_Extensions.h"

@implementation CSqliteDatabase (CSqliteDatabase_Extensions)

// TODO -- most of these methods can be heavily optimised and more error checking added (search for NULL)

- (NSUInteger)countRowsInTable:(NSString *)inTableName error:(NSError **)outError
{
id theEnumerator = [self enumeratorForExpression:[NSString stringWithFormat:@"select count(*) from %@;", inTableName] error:outError];
NSArray *theObjects = [theEnumerator allObjects];
// TODO make sure only 1 object is returned.
NSArray *theValues = [[theObjects lastObject] allValues];
// TODO make sure only 1 object is returned.
NSString *theString = [theValues lastObject];
return([theString intValue]);
}

- (NSDictionary *)rowForExpression:(NSString *)inExpression error:(NSError **)outError
{
NSArray *theRows = [self rowsForExpression:inExpression error:outError];
if ([theRows count] > 0)
	return([theRows objectAtIndex:0]);
else
	return(NULL);
}

- (NSArray *)valuesForExpression:(NSString *)inExpression error:(NSError **)outError
{
NSDictionary *theRow = [self rowForExpression:inExpression error:outError];
return([theRow allValues]);
}

- (NSString *)valueForExpression:(NSString *)inExpression error:(NSError **)outError
{
NSArray *theValues = [self valuesForExpression:inExpression error:outError];
// TODO -- check only 1 object is returned?
return([theValues lastObject]);
}

- (BOOL)objectExistsOfType:(NSString *)inType name:(NSString *)inTableName temporary:(BOOL)inTemporary
{
NSString *theSQL = [NSString stringWithFormat:@"select count(*) from %@ where TYPE = '%@' and NAME = '%@'", inTemporary == YES ? @"SQLITE_TEMP_MASTER" : @"SQLITE_MASTER", inType, inTableName];
NSString *theValue = [self valueForExpression:theSQL error:NULL];
return([theValue intValue] == 1);
}

- (BOOL)tableExists:(NSString *)inTableName
{
return([self objectExistsOfType:@"table" name:inTableName temporary:NO]);
}

- (BOOL)temporaryTableExists:(NSString *)inTableName
{
return([self objectExistsOfType:@"table" name:inTableName temporary:YES]);
}

+ (NSDateFormatter *)dbDateFormatter
{
NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
[dateFormatter setGeneratesCalendarDates:NO];

return dateFormatter;
}

@end