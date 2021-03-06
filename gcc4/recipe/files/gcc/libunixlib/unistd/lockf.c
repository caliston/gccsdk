/*
 * File taken from glibc.
 * Following changes were made:
 *  - SCL poison added.
 *  - Added lockf64
 */
#ifdef __TARGET_SCL__
#  error "SCL build should not use (L)GPL code."
#endif

/* Copyright (C) 1994 Free Software Foundation, Inc.
This file is part of the GNU C Library.

The GNU C Library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

The GNU C Library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with the GNU C Library; see the file COPYING.LIB.  If
not, write to the Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA.  */

#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

/* lockf is a simplified interface to fcntl's locking facilities.  */

int
lockf (int fd, int cmd, off_t len)
{
  struct flock fl;

  switch (cmd)
    {
    case F_TEST:
      /* Test the lock: return 0 if FD is unlocked or locked by this process;
	 return -1, set errno to EACCES, if another process holds the lock.  */
      if (fcntl (fd, F_GETLK, &fl) < 0)
	return -1;
      if (fl.l_type == F_UNLCK || fl.l_pid == getpid ())
	return 0;
      return __set_errno (EACCES);

    case F_ULOCK:
      fl.l_type = F_UNLCK;
      cmd = F_SETLK;
      break;
    case F_LOCK:
      fl.l_type = F_WRLCK;
      cmd = F_SETLKW;
      break;
    case F_TLOCK:
      fl.l_type = F_WRLCK;
      cmd = F_SETLK;
      break;

    default:
      return __set_errno (EINVAL);
    }

  /* lockf is always relative to the current file position.  */
  fl.l_whence = SEEK_CUR;
  fl.l_start = 0;

  fl.l_len = len;

  return fcntl (fd, cmd, &fl);
}
#if __UNIXLIB_LFS64_SUPPORT
#  error "64-bit LFS support missing."
#else
int
lockf64 (int fd, int cmd, __off64_t len)
{
  if (len >= (__off_t)-1)
    return __set_errno (EOVERFLOW);
  return lockf (fd, cmd, (__off_t)len);
}
#endif
