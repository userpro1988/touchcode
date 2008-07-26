//
//  BasicTests.m
//  TouchXML
//
//  Created by Jonathan Wight on 03/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BasicTests.h"

#import "CXMLDocument.h"
#import "CXMLElement.h"

@implementation BasicTests

- (void)test_basicXMLTest
{
NSError *theError = NULL;
CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithXMLString:@"<foo/>" options:0 error:&theError] autorelease];
STAssertNotNil(theXMLDocument, NULL);
STAssertNil(theError, NULL);
STAssertNotNil([theXMLDocument rootElement], NULL);
STAssertEquals([theXMLDocument rootElement], [theXMLDocument rootElement], NULL);
STAssertEqualObjects([[theXMLDocument rootElement] name], @"foo", NULL);
}

- (void)test_badXMLTest
{
NSError *theError = NULL;
CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithXMLString:@"This is invalid XML." options:0 error:&theError] autorelease];
STAssertNil(theXMLDocument, NULL);
STAssertNotNil(theError, NULL);
}

- (void)test_nodeNavigation
{
NSError *theError = NULL;
NSString *theXML = @"<root><node_1/><node_2/><node_3/></root>";
CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithXMLString:theXML options:0 error:&theError] autorelease];
STAssertNotNil(theXMLDocument, NULL);

STAssertTrue([[theXMLDocument rootElement] childCount] == 3, NULL);

NSArray *theArray = [theXMLDocument nodesForXPath:@"/root/*" error:&theError];
STAssertNotNil(theArray, NULL);
STAssertTrue([theArray count] == 3, NULL);
for (CXMLNode *theNode in theArray)
	{
	STAssertEquals([theNode index], [theArray indexOfObject:theNode], NULL);
	STAssertEquals((int)[theNode level], 2, NULL);
	}
	
STAssertEquals([[theXMLDocument rootElement] childAtIndex:0], [theArray objectAtIndex:0], NULL);
STAssertEquals([[theXMLDocument rootElement] childAtIndex:1], [theArray objectAtIndex:1], NULL);
STAssertEquals([[theXMLDocument rootElement] childAtIndex:2], [theArray objectAtIndex:2], NULL);

STAssertEqualObjects([[theArray objectAtIndex:0] name], @"node_1", NULL);
STAssertEqualObjects([[theArray objectAtIndex:1] name], @"node_2", NULL);
STAssertEqualObjects([[theArray objectAtIndex:2] name], @"node_3", NULL);

STAssertEquals([[theArray objectAtIndex:0] nextSibling], [theArray objectAtIndex:1], NULL);
STAssertEquals([[theArray objectAtIndex:1] nextSibling], [theArray objectAtIndex:2], NULL);
STAssertNil([[theArray objectAtIndex:2] nextSibling], NULL);

STAssertNil([[theArray objectAtIndex:0] previousSibling], NULL);
STAssertEquals([[theArray objectAtIndex:1] previousSibling], [theArray objectAtIndex:0], NULL);
STAssertEquals([[theArray objectAtIndex:2] previousSibling], [theArray objectAtIndex:1], NULL);
}

- (void)test_valid_and_invalid_Xpaths
{

}

- (void)test_attributes
{
NSError *theError = NULL;
NSString *theXML = @"<root><node_1/><node_2 attribute_1='value_1' /><node_3 attribute_1='value_1' attribute_2='value_2' /></root>";
CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithXMLString:theXML options:0 error:&theError] autorelease];
STAssertNotNil(theXMLDocument, NULL);

NSArray *theNodes = NULL;
CXMLElement *theElement = NULL;

theNodes = [[theXMLDocument rootElement] elementsForName:@"node_1"];
STAssertTrue([theNodes count] == 1, NULL);
theElement = [theNodes lastObject];
STAssertTrue([theElement isKindOfClass:[CXMLElement class]], NULL);
STAssertNotNil([theElement attributes], NULL);
STAssertTrue([[theElement attributes] count] == 0, NULL);

theNodes = [[theXMLDocument rootElement] elementsForName:@"node_2"];
STAssertTrue([theNodes count] == 1, NULL);
theElement = [theNodes lastObject];
STAssertTrue([theElement isKindOfClass:[CXMLElement class]], NULL);
STAssertNotNil([theElement attributes], NULL);
STAssertTrue([[theElement attributes] count] == 1, NULL);
STAssertEqualObjects([[theElement attributes] objectAtIndex:0], [theElement attributeForName:@"attribute_1"], NULL);
STAssertEqualObjects([[theElement attributeForName:@"attribute_1"] stringValue], @"value_1", NULL);

theNodes = [[theXMLDocument rootElement] elementsForName:@"node_3"];
STAssertTrue([theNodes count] == 1, NULL);
theElement = [theNodes lastObject];
STAssertTrue([theElement isKindOfClass:[CXMLElement class]], NULL);
STAssertNotNil([theElement attributes], NULL);
STAssertTrue([[theElement attributes] count] == 2, NULL);
STAssertEqualObjects([[theElement attributes] objectAtIndex:0], [theElement attributeForName:@"attribute_1"], NULL);
STAssertEqualObjects([[theElement attributes] objectAtIndex:1], [theElement attributeForName:@"attribute_2"], NULL);
STAssertEqualObjects([[theElement attributeForName:@"attribute_1"] stringValue], @"value_1", NULL);
STAssertEqualObjects([[theElement attributeForName:@"attribute_2"] stringValue], @"value_2", NULL);
}

- (void)test_brokenEntity
{
NSError *theError = NULL;
CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithXMLString:@"<foo>http://website.com?foo=1&bar=2</foo>" options:0 error:&theError] autorelease];
STAssertNil(theXMLDocument, NULL);
}

@end
