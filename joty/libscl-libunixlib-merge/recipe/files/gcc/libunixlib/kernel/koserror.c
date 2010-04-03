/* _kernel_oserror()
 * Copyright (c) 2010 UnixLib Developers
 */

#include <kernel.h>
#include <pthread.h>

/* Returns the last RISC OS error happened for the current thread, or NULL
   when non did happen.  */
_kernel_oserror *
_kernel_last_oserror (void)
{
  _kernel_oserror *err = &__pthread_running_thread->errbuf;
  return err->errnum ? err : NULL;
}

