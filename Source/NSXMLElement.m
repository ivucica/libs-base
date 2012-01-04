/* Implementation for NSXMLElement for GNUStep
   Copyright (C) 2008 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Created: September 2008

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
*/

#import "common.h"

#import "NSXMLPrivate.h"

@implementation NSXMLElement

- (void) dealloc
{
  [_attributes release];
  [_namespaces release];
  [_children release];
  [super dealloc];
}

- (id) initWithName: (NSString*)name
{
  return [self initWithName: name URI: nil];
}

- (id) initWithName: (NSString*)name URI: (NSString*)URI
{
  if ((self = [super initWithKind:NSXMLElementKind]) != nil)
    {
      ASSIGN(_name, name);
      _attributes = [[NSMutableDictionary alloc] initWithCapacity: 10];
      _namespaces = [[NSMutableArray alloc] initWithCapacity: 10];
      _children = [[NSMutableArray alloc] initWithCapacity: 10];
      _URI = nil;
    }
  return self;
}

- (id) initWithName: (NSString*)name stringValue: (NSString*)string
{
  if([self initWithName: name URI: nil] != nil)
    {
      [self setObjectValue: string];
    }
  return nil;
}

- (id) initWithXMLString: (NSString*)string error: (NSError**)error
{
  [self notImplemented: _cmd];
  return nil;
}

- (NSArray*) elementsForName: (NSString*)name
{
  [self notImplemented: _cmd];
  return nil;
}

- (NSArray*) elementsForLocalName: (NSString*)localName URI: (NSString*)URI
{
  [self notImplemented: _cmd];
  return nil;
}

- (void) addAttribute: (NSXMLNode*)attribute
{
  [_attributes setObject: attribute
		  forKey: [attribute name]];
}

- (void) removeAttributeForName: (NSString*)name
{
  [_attributes removeObjectForKey: name];
}

- (void) setAttributes: (NSArray*)attributes
{
  NSEnumerator	*enumerator = [attributes objectEnumerator];
  NSXMLNode	*attribute;

  while ((attribute = [enumerator nextObject]) != nil)
    {
      [self addAttribute: attribute];
    }
}

- (void) setAttributesAsDictionary: (NSDictionary*)attributes
{
  ASSIGN(_attributes, [attributes mutableCopy]);
}

- (NSArray*) attributes
{
  return [_attributes allValues];
}

- (NSXMLNode*) attributeForName: (NSString*)name
{
  return [_attributes objectForKey: name];
}

- (NSXMLNode*) attributeForLocalName: (NSString*)localName
                                  URI: (NSString*)URI
{
  [self notImplemented: _cmd];
  return nil;
}

- (void) addNamespace: (NSXMLNode*)aNamespace
{
  [self notImplemented: _cmd];
}

- (void) removeNamespaceForPrefix: (NSString*)name
{
  [self notImplemented: _cmd];
}

- (void) setNamespaces: (NSArray*)namespaces
{
  [self notImplemented: _cmd];
}

- (NSArray*) namespaces
{
  if (_namespaces == nil)
    {
      [self notImplemented: _cmd];
    }
  return _namespaces;
}

- (NSXMLNode*) namespaceForPrefix: (NSString*)name
{
  [self notImplemented: _cmd];
  return nil;
}

- (NSXMLNode*) resolveNamespaceForName: (NSString*)name
{
  [self notImplemented: _cmd];
  return nil;
}

- (NSString*) resolvePrefixForNamespaceURI: (NSString*)namespaceURI
{
  [self notImplemented: _cmd];
  return nil;
}

- (void) insertChild: (NSXMLNode*)child atIndex: (NSUInteger)index
{
  [self notImplemented: _cmd];
}

- (void) insertChildren: (NSArray*)children atIndex: (NSUInteger)index
{
  NSEnumerator	*enumerator = [children objectEnumerator];
  NSXMLNode	*child;
  
  while ((child = [enumerator nextObject]) != nil)
    {
      [self insertChild: child atIndex: index++];
    }
}

- (void) removeChildAtIndex: (NSUInteger)index
{
  [_children removeObjectAtIndex: index];
}

- (void) setChildren: (NSArray*)children
{
  ASSIGN(_children, [children mutableCopy]);
  _childrenHaveMutated = YES;
}
 
- (void) addChild: (NSXMLNode*)child
{
  [_children addObject: child];
  _childrenHaveMutated = YES;
}
 
- (void) replaceChildAtIndex: (NSUInteger)index withNode: (NSXMLNode*)node
{
  [self removeChildAtIndex: index];
  [self insertChild: node atIndex: index];
}

- (void) normalizeAdjacentTextNodesPreservingCDATA: (BOOL)preserve
{
  [self notImplemented: _cmd];
}

- (NSString *) XMLStringWithOptions: (NSUInteger)options
{
  NSMutableString *result = [NSMutableString string];
  NSEnumerator *en = nil;
  id object = nil;

  // XML Element open tag...
  [result appendString: [NSString stringWithFormat: @"<%@",[self name]]];

  // get the attributes...
  en = [[self attributes] objectEnumerator];
  while((object = [en nextObject]) != nil)
    {
      [result appendString: @" "];
      [result appendString: [object XMLStringWithOptions: options]];
    }
  // close the brackets...
  [result appendString: @">"];

  [result appendString: [self stringValue]]; // need to escape entities...

  // Iterate over the children...
  en = [[self children] objectEnumerator];
  while((object = [en nextObject]) != nil)
    {
      [result appendString: @" "];
      [result appendString: [object XMLStringWithOptions: options]];
    }
  
  // Close the entire tag...
  [result appendString: [NSString stringWithFormat: @"</%@>",[self name]]];

  // return 
  return result;
}

@end

