/* Define stack_t.  Linux version.
   Copyright (C) 1998-2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#ifndef __stack_t_defined
#define __stack_t_defined 1

#define __need_size_t
#include <stddef.h>

#ifndef	_BITS_TYPES_H
#include <bits/types.h>
#endif

/* Structure describing a signal stack.  */
typedef struct
  {
    void *ss_sp;
    __int32_t ss_flags;
    size_t ss_size;
  } stack_t;

#endif
