/* Map or unmap memory.
   Copyright (c) 1996, 1997, 2005 UnixLib Developers.  */

/* Definitions for BSD-style memory management.  Generic/4.4 BSD version.  */
/* sys/mman.c: Written by Peter Burwood, 1 November 1996, June 1997  */

/* Add support for mapping to files.
   Start with /dev/zero - needs support in unix/dev.c, unix/open.c & elsewhere.
   Then read support for real files (what happens when file is changed, need to
   remap the memory ?).
   Then support for writes - need to synchronise with buffered data
*/

#include <sys/mman.h>
#include <unixlib/os.h>
#include <sys/types.h>
#include <swis.h>
#include <unistd.h>
#include <unixlib/unix.h>
#include <string.h>
#include <errno.h>
#include <pthread.h>


/* could store the number and the next pointer at the beginning or end of the
   mmap'ed area. The end is better for alignment purposes - so also need length
   maybe not a good idea, since len request is likely to be a multiple of 1024.

   Since will only allow a fixed maximum number of mmap'ed regions, declare an
   array.  Requests are likely to be a power of 2 when called from malloc which	   will request an integral number of pages. It will already have allocated a
   word for its length field, so if we stored extra information ourselves we
   would need an extra page. If malloc was called with a request for an
   integral number of pages then we would waste two pages. */
typedef struct mmap_info {
  caddr_t   addr;
  int	    number;
  size_t    len;
  int	    prot;
} mmap_info;

#define IMMAP { 0, -1, 0, 0 }
#define MAX_MMAPS 8
static mmap_info mmaps[MAX_MMAPS] = {
  IMMAP, IMMAP, IMMAP, IMMAP, IMMAP, IMMAP, IMMAP, IMMAP
};

#define page_align(len) (((len) + __ul_pagesize - 1) & ~(__ul_pagesize - 1));

extern void __mmap_page_copy (caddr_t dst, caddr_t src, int len);

/* Free all mmapped memory.  This is called from __dynamic_area_exit.
   At that point, the thread system is not running.  */
void
__munmap_all (void)
{
  int i;

  for (i = 0; i < MAX_MMAPS; i++)
    {
      if (mmaps[i].number != -1)
	munmap (mmaps[i].addr, 0);
    }
}

/* Map addresses starting near ADDR and extending for LEN bytes.  from
   OFFSET into the file FD describes according to PROT and FLAGS.  If ADDR
   is nonzero, it is the desired mapping address.  If the MAP_FIXED bit is
   set in FLAGS, the mapping will be at ADDR exactly (which must be
   page-aligned); otherwise the system chooses a convenient nearby address.
   The return value is the actual mapping address chosen or (caddr_t) -1
   for errors (in which case `errno' is set).  A successful `mmap' call
   deallocates any previous mapping for the affected region.  */

caddr_t
mmap (caddr_t addr, size_t len, int prot, int flags, int fd, off_t offset)
{
  int regs[10];
  int i;

  PTHREAD_UNSAFE

  /* We don't support mmap on files yet.  */
  if (fd != -1)
    return (caddr_t) __set_errno (ENOSYS);

  /* Non-zero offset only makes sense for mmap onto files.  */
  if (offset != 0)
    return (caddr_t) __set_errno (EINVAL);

  /* We don't support MAP_FIXED.  */
  if (flags & MAP_FIXED)
    return (caddr_t) __set_errno (((size_t)addr & (__ul_pagesize - 1)) != 0
				  ? EINVAL : ENOSYS);

  /* We don't support MAP_COPY.  */
  if (flags & MAP_COPY)
    return (caddr_t) __set_errno (ENOSYS);

  /* We only support mmap when dynamic areas are enabled.  */
  if (__dynamic_num == -1)
    return (caddr_t) __set_errno (ENOSYS);

  /* We only support PROT_READ or PROT_WRITE.  */
  if (((prot & PROT_EXEC) == PROT_EXEC)
      || ((prot & (PROT_READ | PROT_WRITE)) == 0))
    return (caddr_t) __set_errno (ENOSYS);

  /* We don't support MAP_PRIVATE. However, we will just use MAP_SHARED instead
     rather than changing all the user code calling us. */

  /* find spare mmap_info index */
  for (i = 0; i < MAX_MMAPS; i++)
    {
      if (mmaps[i].number == -1)
	break;
    }

  /* Maximum number of mmap sections reached.  */
  if (i == MAX_MMAPS)
    return (caddr_t) __set_errno (ENOMEM);

  len = page_align (len);
  /* Create the dynamic area.  */
  regs[0] = 0;
  regs[1] = -1;
  regs[2] = len;
  regs[3] = -1;
  if (prot & PROT_READ)
    {
      if (prot & PROT_WRITE)
	regs[4] = 0x80;
      else
	regs[4] = 0x81;
    }
  else
    regs[4] = 0x82;

  /* We allocate triple the requested memory as the virtual limit to help
     with mremap which is used by realloc.  */
  regs[5] = regs[2] * 3;
  regs[6] = 0;
  regs[7] = 0;
  /* The DA name could be the same name used in sys/syslib.s so Virtualise
     can be enabled/disabled for the area. Using the name with 'X' appended
     is useful though to separate the areas from the more general purpose
     heap.  */
  {
    char namebuf[128];

#ifdef __ELF__
    /* With ELF/GCC, we can use the weak symbol directly.  */
    if (__dynamic_da_name)
      regs[8] = (int) __dynamic_da_name;
#else
    /* With AOF, we have to indirectly access the weak symbol.  */
    if (___dynamic_da_name)
      regs[8] = (int) *___dynamic_da_name;
#endif
    else
      {
        regs[8] = (int)get_program_name (__u->argv[0], namebuf,
					 sizeof(namebuf) - sizeof(" MMap"));
        strcat (namebuf, " MMap");
      }

    if (__os_swi (OS_DynamicArea, regs))
      return (caddr_t) __set_errno (ENOMEM);
  }

  mmaps[i].number = regs[1];
  mmaps[i].addr   = (caddr_t)regs[3];
  mmaps[i].len    = len;
  mmaps[i].prot   = prot;

  return (mmaps[i].addr);
}

/* Deallocate any mapping for the region starting at ADDR and extending LEN
   bytes.  Returns 0 if successful, -1 for errors (and sets errno).  */
int
munmap (caddr_t addr, size_t len)
{
  int regs[10];
  int i;
  _kernel_oserror *err;

  PTHREAD_UNSAFE

  len = len; /* XXX don't care about len for now */

  for (i = 0; i < MAX_MMAPS; i++)
    {
      if (mmaps[i].addr == addr)
	break;
    }

  /* If we couldn't find the mmap mapping, then return an error.  */
  if (i == MAX_MMAPS)
    return __set_errno (EINVAL);

  /* Unmap by deleting the dynamic area.  */
  regs[0] = 1;
  regs[1] = mmaps[i].number;
  mmaps[i].addr = 0;
  mmaps[i].number = -1;
  err = __os_swi (OS_DynamicArea, regs);
  if (err)
    {
      /* Failed to delete area.  */
      __ul_seterr (err, 1);
      return -1;
    }
  return 0;
}

/* Change the memory protection of the region starting at ADDR and
   extending LEN bytes to PROT.  Returns 0 if successful, -1 for errors
   (and sets errno).  */
int
mprotect (caddr_t addr, size_t len, int prot)
{
  addr = addr;
  len = len;
  prot = prot;
  return __set_errno (ENOSYS);
}

/* this is supposed to be able to work on non-mmaped memory too. */

/* Synchronize the region starting at ADDR and extending LEN bytes with the
   file it maps.  Filesystem operations on a file being mapped are
   unpredictable before this is done.  */
int
msync (caddr_t addr, size_t len)
{
  addr = addr;
  len = len;
  return __set_errno (ENOSYS);
}

/* Advise the system about particular usage patterns the program follows
   for the region starting at ADDR and extending LEN bytes.  */
int
madvise (caddr_t addr, size_t len, int advice)
{
  addr = addr;
  len = len;
  advice = advice;
  return __set_errno (ENOSYS);
}

/* Remap addresses mapped by the range [ADDR,ADDR+OLD_LEN) to new length
   NEW_LEN.  If MAY_MOVE is MREMAP_MAYMOVE the returned address may differ
   from ADDR.  The return value is the actual mapping address chosen or
   (caddr_t) -1 for errors (in which case `errno' is set).  */

caddr_t
mremap (caddr_t addr, size_t old_len, size_t new_len, int may_move)
{
  int i;
  int old_area;
  caddr_t new_addr;
  _kernel_oserror *err;
  int regs[10];

  PTHREAD_UNSAFE

  for (i = 0; i < MAX_MMAPS; i++)
    {
      if (mmaps[i].addr == addr)
	break;
    }

  /* If we couldn't find the mmap mapping, then return an error.  */
  if (i == MAX_MMAPS)
    return (caddr_t) __set_errno (EINVAL);

  old_len = page_align (old_len);

  /* Check correct length was passed.  */
  if (old_len != mmaps[i].len)
    return (caddr_t) __set_errno (EINVAL);

  new_len = page_align (new_len);
  regs[0] = mmaps[i].number;
  regs[1] = new_len - old_len;

  /* Check whether we actually need to alter the mmap area.  */
  if (regs[1] == 0)
    return addr;

  err = __os_swi (OS_ChangeDynamicArea, regs);
  if (err)
    {
      /* If we were trying to reduce the mmap size and that failed, then
	 return an error.  */
      if (new_len < old_len)
	{
	  __ul_seterr (err, 1);
	  /* Soldier on since we did manage to remap the memory.  */
	  return addr;
	}
      if ((may_move & MREMAP_MAYMOVE) == 0)
	{
	  __ul_seterr (err, 1); /* XXX Should we return ENOMEM ? */
	  return ((caddr_t)-1);
	}
      /* Create a new mmap section to replace this section and copy over the
	 data.  */
      old_area = mmaps[i].number;
      mmaps[i].number = -1;
      /* FIXME - get mapping type flags */
      new_addr = mmap (0, new_len, mmaps[i].prot, MAP_ANON, -1, 0);
      if (new_addr == (caddr_t)-1)
	{
	  /* If mmap failed, then keep the old area.  */
	  mmaps[i].addr   = addr;
	  mmaps[i].number = old_area;
	  return ((caddr_t)-1);
	}
      /* Fast page copy. */
      __mmap_page_copy (new_addr, addr, old_len);
      regs[0] = 1;
      regs[1] = old_area;
      err = __os_swi (OS_DynamicArea, regs);
      /* Record any error, which may be due to the deletion of the
	 old area failing. We also soldier on, since we did manage
	 to remap the memory.  */
      if (err)
	__ul_seterr (err, 1);
      addr = new_addr;
    }
  return addr;
}
