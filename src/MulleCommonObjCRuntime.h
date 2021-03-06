//
//  MulleCommonObjCRuntime.h
//  MulleScion
//
//  Created by Nat! on 16.05.2014
//
//  Copyright (c) 2014 Nat! - Mulle kybernetiK
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

//
// allow sparing use of ARC notation in otherwise beautiful ObjC code :)
//
#ifndef __OBJC2__ // __has_feature( objc-arc), clangism
# ifndef __bridge
#  define __bridge
# endif
# ifndef __unsafe_unretained
#  define __unsafe_unretained
# endif
#endif


#ifdef __MULLE_OBJC__

static inline Class   MulleGetClass( id self)
{
   return( self ? (Class) _mulle_objc_object_get_isa( self) : Nil);
}

#else
# ifdef __LP64__

# import <objc/runtime.h>

static inline Class   MulleGetClass( id self)
{
   return( object_getClass( self));
}

# else

# import <objc/objc.h>

static inline Class   MulleGetClass( id self)
{
   return( self ? ((__bridge struct objc_object *) self)->isa : Nil);
}
# endif
#endif
