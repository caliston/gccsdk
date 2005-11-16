/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/pthread/keydest.c,v $
 * $Date: 2005/07/08 13:25:41 $
 * $Revision: 1.4 $
 * $State: Exp $
 * $Author: peter $
 *
 ***************************************************************************/

/* Written by Alex Waugh */

#include <stdlib.h>
#include <pthread.h>
#include <unixlib/unix.h>
#include <malloc.h>

/* Separated from key.c to avoid other key functions being
   pulled in by the linker */

/* Call all the destructors of a thread specific key */
void
__pthread_key_calldestructors (void)
{
  struct __pthread_key *key;
  int tries = 0;

  while ((key = __pthread_running_thread->keys) != NULL)
    {
      __pthread_running_thread->keys = key->next;
      if (key->value.nonconst != NULL && key->destructor != NULL && tries < PTHREAD_DESTRUCTOR_ITERATIONS)
        {
          tries++;
          key->destructor (key->value.nonconst);
        }
      free_unlocked (__ul_global.malloc_state, key);
    }
}
