//
//  MulleScionParser.m
//  MulleScionTemplates
//
//  Created by Nat! on 24.02.13.
//
//  Copyright (c) 2013 Nat! - Mulle kybernetiK
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//


#import "MulleScionParser.h"

#import "MulleScionParser+Parsing.h"
#import "MulleScionObjectModel+Parsing.h"
#import "MulleScionObjectModel+BlockExpansion.h"
#import "NSFileHandle+MulleOutputFileHandle.h"
#import "MulleScionObjectModel+TraceDescription.h"
#if ! TARGET_OS_IPHONE
# import <Foundation/NSDebug.h>
#endif

@implementation MulleScionParser

- (id) initWithData:(NSData *) data
           fileName:(NSString *) fileName
{
   NSParameterAssert( [data isKindOfClass:[NSData class]]);
   NSParameterAssert( [fileName isKindOfClass:[NSString class]] && [fileName length]);
   
   data_     = [data retain];
   fileName_ = [fileName copy];

   return( self);
}


- (void) dealloc
{
   [fileName_ release];
   [data_ release];
   
   [super dealloc];
}


+ (MulleScionParser *) parserWithContentsOfFile:(NSString *) path
{
   NSData            *data;
   MulleScionParser  *parser;
   
   data = [NSData dataWithContentsOfMappedFile:path];
   if( ! data)
   {
      [self autorelease];
      return( nil);
   }
   
   parser = [[[self alloc] initWithData:data
                               fileName:path] autorelease];
   return( parser);
}


#if DEBUG
- (id) autorelease
{
   return( [super autorelease]);
}
#endif


- (NSString *) fileName
{
   return( fileName_);
}


static void   _dump( MulleScionTemplate *self, NSString *path, NSString *blurb, SEL sel)
{
   NSFileHandle   *fout;
   char           *s;
   NSData         *nl;
   
   fout = [NSFileHandle mulleOutputFileHandleWithFilename:path];
   if( ! fout)
   {
      NSLog( @"couldn't create trace file \"%@\"", path);
      return;
   }

   nl = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
   if( blurb)
   {
      [fout writeData:[blurb dataUsingEncoding:NSUTF8StringEncoding]];
      [fout writeData:nl];
   }
   [fout writeData:[[self performSelector:sel] dataUsingEncoding:NSUTF8StringEncoding]];
   [fout writeData:nl];
}


static void   dump( MulleScionTemplate *self, char *env, NSString *blurb, SEL sel)
{
   NSAutoreleasePool   *pool;
   char                *s;
   NSString            *path;
   
   s = env ? getenv( env) : "-";
   if( ! s || ! *s)
      return;
   
   pool = [NSAutoreleasePool new];
   path = [NSString stringWithCString:s];
   _dump( self, path, blurb, sel);
   [pool release];
}


#define MULLE_SCION_DUMP_PRE_EXPAND     "MulleScionDumpPreBlockExpansion"
#define MULLE_SCION_DUMP_POST_EXPAND    "MulleScionDumpPostBlockExpansion"

// in debug mode always trace
#if DEBUG
# define MULLE_SCION_TRACE_PRE_EXPAND   NULL
# define MULLE_SCION_TRACE_POST_EXPAND  NULL
#else
# define MULLE_SCION_TRACE_PRE_EXPAND   "MulleScionTracePreBlockExpansion"
# define MULLE_SCION_TRACE_POST_EXPAND  "MulleScionTracePostBlockExpansion"
#endif


- (MulleScionTemplate *) template
{
   MulleScionTemplate      *template;
   NSMutableDictionary     *blockTable;
   NSAutoreleasePool        *pool;
   
   pool       = [NSAutoreleasePool new];
   blockTable = [NSMutableDictionary dictionary];
   template   = [self templateParsedWithBlockTable:blockTable];

   dump( template, MULLE_SCION_TRACE_PRE_EXPAND, @"BEFORE BLOCK EXPANSION:", @selector( traceDescription));
   dump( template, MULLE_SCION_DUMP_PRE_EXPAND,  @"BEFORE BLOCK EXPANSION:", @selector( templateDescription));
   
   [template expandBlocksUsingTable:blockTable];
   
   dump( template, MULLE_SCION_DUMP_POST_EXPAND, @"AFTER BLOCK EXPANSION:", @selector( traceDescription));
   dump( template, MULLE_SCION_DUMP_POST_EXPAND, @"AFTER BLOCK EXPANSION:", @selector( templateDescription));
   
   [template retain];
   [pool release];
   
   return( [template autorelease]);
}


- (MulleScionTemplate *) templateParsedWithBlockTable:(NSMutableDictionary *) blockTable
{
   NSMutableDictionary   *definitonsTable;
   NSMutableDictionary   *macroTable;
   MulleScionTemplate    *template;
   NSAutoreleasePool     *pool;
   
   pool            = [NSAutoreleasePool new];
   
   definitonsTable = [NSMutableDictionary dictionary];
   macroTable      = [NSMutableDictionary dictionary];
   template        = [[self templateParsedWithBlockTable:blockTable
                                         definitionTable:definitonsTable
                                              macroTable:macroTable
                                         dependencyTable:nil] retain];
   [pool release];
   return( [template autorelease]);
}


- (NSDictionary *) dependencyTable
{
   NSMutableDictionary   *dependencyTable;
   NSMutableDictionary   *definitonsTable;
   NSMutableDictionary   *macroTable;
   NSMutableDictionary   *blockTable;
   NSAutoreleasePool     *pool;
   
   dependencyTable = [NSMutableDictionary dictionary];
   
   pool = [NSAutoreleasePool new];
   
   definitonsTable = [NSMutableDictionary dictionary];
   macroTable      = [NSMutableDictionary dictionary];
   blockTable      = [NSMutableDictionary dictionary];

   [self templateParsedWithBlockTable:blockTable
                      definitionTable:definitonsTable
                           macroTable:macroTable
                      dependencyTable:dependencyTable];
   [pool release];
   
   return( dependencyTable);
}


- (void) parserErrorInFileName:(NSString *) fileName
                    lineNumber:(NSUInteger) lineNumber
                        reason:(NSString *) reason
{
   [NSException raise:NSInvalidArgumentException
               format:@"%@,%lu: %@", fileName ? fileName : @"template", (long) lineNumber, reason];
}

@end
