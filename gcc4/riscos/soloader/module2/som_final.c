/* som_final.c
 *
 * Copyright 2006, 2007 GCCSDK Developers
 * Written by Lee Noar
 */

#include <stdlib.h>
#include <kernel.h>
#include <swis.h>
#include "somanager.h"
#include "som.h"
#include "som_os_swis.h"
#include "som_alloc.h"

_kernel_oserror *
module_finalisation (int fatal, int podule_base, void *pw)
{
  _kernel_oserror *err;

  if (!global.flags.no_client_check && global.client_list.count > 0)
    return somerr_in_use;

  if ((err = som_stop_call_every (pw)) != NULL)
    return err;

  somarray_fini (&global.object_array);

#ifdef LIBRARIES_IN_DA
  /* Don't bother individually freeing library memory on 32bit OS
     as deleting the DA will free them all in one go anyway.  */
  if (global.flags.host_32bit)
    dynamic_area_remove (global.library_da.number);
  else
#endif
    {
      som_library_object *global_library =
		linklist_first_som_library_object (&global.object_list);

      while (global_library)
	{
	  if (global_library->object.flags.type != object_flag_type_CLIENT
	      && global_library->object.base_addr)
	    som_free (global_library->object.base_addr);

	  global_library = linklist_next_som_library_object (global_library);
	}
    }

  dynamic_area_remove (global.data_da.number);

  return NULL;
}
