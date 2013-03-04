//
//  MulleScionObjectModel+NSCoding.m
//  MulleScionTemplates
//
//  Created by Nat! on 25.02.13.
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


#import "MulleScionObjectModel+NSCoding.h"


@implementation MulleScionObject ( NSCoding)

+ (void) load
{
   [self setVersion:1848];
}


//
// use NSCoding to make a copy, so I don't have to write all those
// copy routines
//
- (id) copyWithZone:(NSZone *) zone
{
   NSData             *data;
   NSAutoreleasePool  *pool;
   id                 copy;
   
   pool = [NSAutoreleasePool new];
   data = [NSArchiver archivedDataWithRootObject:self];
   copy = [[NSUnarchiver unarchiveObjectWithData:data] retain];
   [pool release];
   
   return( copy);
}
    
    
- (id) initWithCoder:(NSCoder *) decoder
{
   unsigned long  lineNumber;
   id             next;
   
   [decoder decodeValuesOfObjCTypes:"L@", &lineNumber, &next];

   self = [self initWithLineNumber:lineNumber];
   assert( self);

   self->next_ = next;
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   unsigned long  lineNumber;

   lineNumber = lineNumber_;
   [encoder encodeValuesOfObjCTypes:"L@", &lineNumber, &next_];
}

@end


@implementation MulleScionValueObject ( NSCoding)

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@", &value_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@", &value_];
}

@end


@implementation MulleScionVariableAssignment ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@", &expression_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@", &expression_];
}

@end


@implementation MulleScionFunction ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@", &arguments_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@", &arguments_];
}

@end


@implementation MulleScionMethod ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   NSString  *methodName;
   
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@@", &arguments_, &methodName];
   action_ = NSSelectorFromString( methodName);
   [methodName release];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   NSString  *methodName;

   [super encodeWithCoder:encoder];
   methodName = NSStringFromSelector( action_);
   [encoder encodeValuesOfObjCTypes:"@@", &arguments_, &methodName];
}

@end


@implementation MulleScionBinaryOperatorExpression  ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@", &right_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@", &right_];
}

@end


@implementation MulleScionComparison  ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   unsigned char   code;

   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"C", &code];
   comparison_ = code;
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   unsigned char   code;
   
   [super encodeWithCoder:encoder];
   code = comparison_;
   [encoder encodeValuesOfObjCTypes:"C", &code];
}

@end


@implementation MulleScionConditional ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@@", &middle_, &right_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@@", &middle_, &right_];
}

@end


@implementation MulleScionSet ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@@", &identifier_, &expression_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@@", &identifier_, &expression_];
}

@end


@implementation MulleScionExpressionCommand ( NSCoding)

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@", &expression_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@", &expression_];
}

@end


@implementation MulleScionBlock ( NSCoding)

- (id) initWithCoder:(NSCoder *) decoder
{
   self = [super initWithCoder:decoder];
   assert( self);
   
   [decoder decodeValuesOfObjCTypes:"@@", &identifier_, &fileName_];
   return( self);
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   [super encodeWithCoder:encoder];
   [encoder encodeValuesOfObjCTypes:"@@", &identifier_, &fileName_];
}

@end


#ifdef DEBUG
@implementation MulleScionMacro ( NSCoding )

- (id) initWithCoder:(NSCoder *) decoder
{
   abort();
}


- (void) encodeWithCoder:(NSCoder *) encoder
{
   abort();
}
@end
#endif
