/*
 * AsAsm an assembler for ARM
 * Copyright (c) 2011-2014 GCCSDK Developers
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 */

#ifndef common_header_included
#define common_header_included

#include <stdlib.h>
#if defined(HAVE_STRNDUP) || defined(HAVE_STRDUP)
# include <string.h>
#endif
#if defined(HAVE_STRNCASECMP)
# include <strings.h>
#endif

#ifndef HAVE_STRNDUP
char *strndup (const char *str, size_t len);
#endif

#ifndef HAVE_STRDUP
char *strdup (const char *str);
#endif

#ifndef HAVE_STRNCASECMP
int strncasecmp(const char *str1, const char *str2, size_t n);
#endif

#endif
