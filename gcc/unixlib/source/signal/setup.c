/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/signal/setup.c,v $
 * $Date: 2001/01/29 15:10:20 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: setup.c,v 1.2 2001/01/29 15:10:20 admin Exp $";
#endif

/* signal.c.setup: Written by Nick Burrett, 1 September 1996.  */

#include <stdio.h>
#include <signal.h>
#include <unixlib/sigstate.h>

/* #define DEBUG */

#ifdef DEBUG
#include <unixlib/os.h>
#endif

/* This function chooses a suitable execution environment
   for the signal handler and calls the appropriate function
   to perform the job.

   Return 0 on sucess, 1 on fail.  */

int
__unixlib_setup_sighandler (struct unixlib_sigstate *ss,
			    sighandler_t handler,
			    int signo, int flags)
{
  int system_stack;

#ifdef DEBUG
  __os_print ("__unixlib_setup_sighandler: signo = ");
  __os_prdec (signo); __os_print (", handler = "); __os_prhex ((int) handler);
  __os_print ("\r\n");
#endif
  system_stack = ((ss->signalstack.ss_flags & SA_DISABLE)
		  || ss->signalstack.ss_size == 0
		  || ss->signalstack.ss_sp == 0) ? 1 : 0;

  /* The user has requested to execute the signal on a sigstack
     but it can only be executed on the system stack. Return failure.  */
  if ((flags & SA_ONSTACK) && system_stack)
    {
#ifdef DEBUG
      __os_print ("__unixlib_setup_sighandler: bad system stack\r\n");
      __os_print ("   ss_size = "); __os_prdec ((int) ss->signalstack.ss_size);
      __os_print (", ss_sp = "); __os_prdec ((int) ss->signalstack.ss_sp);
      __os_print (", ss_flags = "); __os_prdec ((int) ss->signalstack.ss_flags);
      __os_print ("\r\n");
#endif
      return 1;
    }

  /* If the SA_DISABLE flag is set, we will not execute
     this signal on a signal stack.

     Look out for problems where the stack pointer is zero or the
     stack size is zero.  */
  if (system_stack)
    {
#ifdef DEBUG
      __os_print (" unixlib_setup_sighandler: executing off normal stack\r\n");
#endif
      __unixlib_exec_sig (handler, signo);
      return 0;
    }

  /* Specify that the signal stack is currently in use.  */
  ss->signalstack.ss_flags |= SA_ONSTACK;

  /* If ss_size == -1, then this sigaltstack was the result of
     a BSD sigstack conversion. Run the BSD alternative signal
     executor.  */
  if (ss->signalstack.ss_size == -1)
    {
#ifdef DEBUG
      __os_print (" unixlib_setup_sighandler: executing off BSD stack\r\n");
#endif
      __unixlib_exec_sigstack_bsd (ss->signalstack.ss_sp, handler, signo);
    }
  else
    {
#ifdef DEBUG
      __os_print (" unixlib_setup_sighandler: executing off POSIX stack\r\n");
#endif
      __unixlib_exec_sigstack (ss->signalstack.ss_sp, ss->signalstack.ss_size,
			       handler, signo);
    }
  /* Say that the signal stack is no longer in use.  */
  ss->signalstack.ss_flags &= ~SA_ONSTACK;

  return 0;
}
