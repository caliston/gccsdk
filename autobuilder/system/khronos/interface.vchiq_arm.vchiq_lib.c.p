--- interface/vchiq_arm/vchiq_lib.c.orig	2016-11-14 11:29:55.405054238 +0000
+++ interface/vchiq_arm/vchiq_lib.c	2016-11-14 11:43:03.413076836 +0000
@@ -30,6 +30,14 @@
 #include <sys/ioctl.h>
 #include <stdio.h>
 
+#ifdef __riscos__
+#include <kernel.h>
+#include <stdint.h>
+#include "main.h"
+#include "../inline_swis.h"
+#include "../reporter.h"
+#endif
+
 #include "vchiq.h"
 #include "vchiq_cfg.h"
 #include "vchiq_ioctl.h"
@@ -38,13 +46,23 @@
 #include "interface/vcos/vcos.h"
 
 #define IS_POWER_2(x) ((x & (x - 1)) == 0)
-#define VCHIQ_MAX_INSTANCE_SERVICES 32
+//#define VCHIQ_MAX_INSTANCE_SERVICES 32
 #define MSGBUF_SIZE (VCHIQ_MAX_MSG_SIZE + sizeof(VCHIQ_HEADER_T))
 
+#ifdef __riscos__
+#include "vchiq_module.h"
+
+#define SERVICE_ADD(service) \
+  globals->services[((SHIM_SERVICE_T *)service)->handle & (VCHIQ_MAX_INSTANCE_SERVICES - 1)] = service;
+#define SERVICE_REMOVE(service) \
+  globals->services[((SHIM_SERVICE_T *)service)->handle & (VCHIQ_MAX_INSTANCE_SERVICES - 1)] = 0;
+#endif
+
 #define RETRY(r,x) do { r = x; } while ((r == -1) && (errno == EINTR))
 
 #define VCOS_LOG_CATEGORY (&vchiq_lib_log_category)
 
+#ifndef __riscos__
 typedef struct vchiq_service_struct
 {
    VCHIQ_SERVICE_BASE_T base;
@@ -73,13 +91,15 @@
 } vchiq_instance;
 
 typedef struct vchiq_instance_struct VCHI_STATE_T;
+#endif
+
 
 /* Local data */
 static VCOS_LOG_LEVEL_T vchiq_default_lib_log_level = VCOS_LOG_WARN;
 static VCOS_LOG_CAT_T vchiq_lib_log_category;
-static VCOS_MUTEX_T vchiq_lib_mutex;
-static void *free_msgbufs;
-static unsigned int handle_seq;
+//static VCOS_MUTEX_T vchiq_lib_mutex;
+//static void *free_msgbufs;
+//static unsigned int handle_seq;
 
 vcos_static_assert(IS_POWER_2(VCHIQ_MAX_INSTANCE_SERVICES));
 
@@ -87,7 +107,9 @@
 static VCHIQ_INSTANCE_T
 vchiq_lib_init(const int dev_vchiq_fd);
 
+#ifndef __riscos__
 static void *completion_thread(void *);
+#endif
 
 static VCHIQ_STATUS_T
 create_service(VCHIQ_INSTANCE_T instance,
@@ -96,6 +118,7 @@
    int is_open,
    VCHIQ_SERVICE_HANDLE_T *phandle);
 
+#ifndef __riscos__
 static int
 fill_peek_buf(VCHI_SERVICE_T *service,
    VCHI_FLAGS_T flags);
@@ -105,22 +128,26 @@
 
 static void
 free_msgbuf(void *buf);
+#endif
 
 static __inline int
 is_valid_instance(VCHIQ_INSTANCE_T instance)
 {
-   return (instance == &vchiq_instance) && (instance->initialised > 0);
+   return (instance == vchiq_instance) && (instance->state->initialised > 0);
 }
 
 static inline VCHIQ_SERVICE_T *
 handle_to_service(VCHIQ_SERVICE_HANDLE_T handle)
 {
-   return &vchiq_instance.services[handle & (VCHIQ_MAX_INSTANCE_SERVICES - 1)];
+   return vchiq_instance->state->services[handle & (VCHIQ_MAX_INSTANCE_SERVICES - 1)];
 }
 
 static VCHIQ_SERVICE_T *
 find_service_by_handle(VCHIQ_SERVICE_HANDLE_T handle)
 {
+#ifdef __riscos__
+   return (VCHIQ_SERVICE_T *)handle;
+#else
    VCHIQ_SERVICE_T *service;
 
    service = handle_to_service(handle);
@@ -131,6 +158,7 @@
       vcos_log_info("Invalid service handle 0x%x", handle);
 
    return service;
+#endif
 }
 
 /*
@@ -166,6 +194,12 @@
 VCHIQ_STATUS_T
 vchiq_shutdown(VCHIQ_INSTANCE_T instance)
 {
+  int i;
+
+  for (i = 0; i < VCHIQ_MAX_INSTANCE_SERVICES; i++)
+     if (globals->services[i])
+	vchi_service_destroy(globals->services[i]);
+#ifndef __riscos__
    vcos_log_trace( "%s called", __func__ );
 
    if (!is_valid_instance(instance))
@@ -220,9 +254,7 @@
    vcos_global_unlock();
 
    vcos_log_trace( "%s returning", __func__ );
-
-   vcos_log_unregister(&vchiq_lib_log_category);
-
+#endif
    return VCHIQ_SUCCESS;
 }
 
@@ -230,19 +262,29 @@
 vchiq_connect(VCHIQ_INSTANCE_T instance)
 {
    VCHIQ_STATUS_T status = VCHIQ_SUCCESS;
-   VCOS_THREAD_ATTR_T attrs;
-   int ret;
 
    vcos_log_trace( "%s called", __func__ );
 
    if (!is_valid_instance(instance))
       return VCHIQ_ERROR;
 
+#ifndef __riscos__
    vcos_mutex_lock(&instance->mutex);
+#endif
 
    if (instance->connected)
       goto out;
 
+#ifdef __riscos__
+   if (swi_vchiq_connect(instance) != NULL)
+   {
+      vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+      status = VCHIQ_ERROR;
+      goto out;
+   }
+#else
+   VCOS_THREAD_ATTR_T attrs;
+   int ret;
    ret = ioctl(instance->fd, VCHIQ_IOC_CONNECT, 0);
    if (ret != 0)
    {
@@ -259,9 +301,12 @@
    }
 
    instance->connected = 1;
+#endif
 
 out:
+#ifndef __riscos__
    vcos_mutex_unlock(&instance->mutex);
+#endif
    return status;
 }
 
@@ -302,8 +347,6 @@
    const VCHIQ_SERVICE_PARAMS_T *params,
    VCHIQ_SERVICE_HANDLE_T *phandle)
 {
-   VCHIQ_STATUS_T status;
-
    vcos_log_trace( "%s called fourcc = 0x%08x (%c%c%c%c)",
                    __func__,
                    params->fourcc,
@@ -318,20 +361,56 @@
    if (!is_valid_instance(instance))
       return VCHIQ_ERROR;
 
+#ifdef __riscos__
+   SERVICE_CREATION_T setup;
+
+   setup.version.version = params->version;
+   setup.version.version_min = params->version_min;
+   setup.service_id = params->fourcc;
+   setup.connection = 0;
+   setup.rx_fifo_size = 0;
+   setup.tx_fifo_size = 0;
+   setup.callback = params->callback;
+   setup.callback_param = params->userdata;
+   setup.want_unaligned_bulk_rx = 0;
+   setup.want_unaligned_bulk_tx = 0;
+   setup.want_crc = 0;
+
+   if (swi_vchiq_service_open(instance, &setup, phandle) != NULL)
+   {
+      vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+      return VCHIQ_ERROR;
+   }
+
+   SERVICE_ADD(*phandle);
+
+   vcos_log_trace( "%s returning service handle = 0x%08x", __func__, (uint32_t)*phandle );
+
+   return VCHIQ_SUCCESS;
+#else
+   VCHIQ_STATUS_T status;
    status = create_service(instance,
       params,
       NULL/*vchi_callback*/,
       1/*open*/,
       phandle);
-
    vcos_log_trace( "%s returning service handle = 0x%08x", __func__, (uint32_t)*phandle );
 
    return status;
+#endif
 }
 
 VCHIQ_STATUS_T
 vchiq_close_service(VCHIQ_SERVICE_HANDLE_T handle)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_close(handle) == NULL) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -349,11 +428,20 @@
       return VCHIQ_ERROR;
 
    return VCHIQ_SUCCESS;
+#endif
 }
 
 VCHIQ_STATUS_T
 vchiq_remove_service(VCHIQ_SERVICE_HANDLE_T handle)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_release(handle) == NULL) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -370,6 +458,7 @@
       return VCHIQ_ERROR;
 
    return VCHIQ_SUCCESS;
+#endif
 }
 
 VCHIQ_STATUS_T
@@ -377,6 +466,16 @@
    const VCHIQ_ELEMENT_T *elements,
    int count)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_msg_queue(handle, elements->data, elements->size,
+			       VCHI_FLAGS_BLOCK_UNTIL_QUEUED) == NULL ? VCHIQ_SUCCESS :
+									VCHIQ_ERROR);
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_MESSAGE_T args;
    int ret;
@@ -392,6 +491,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_MESSAGE, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 void
@@ -400,7 +500,11 @@
 {
    vcos_log_trace( "%s handle=%08x, header=%x", __func__, (uint32_t)handle, (uint32_t)header );
 
+#ifdef __riscos__
+   free(header);
+#else
    free_msgbuf(header);
+#endif
 }
 
 VCHIQ_STATUS_T
@@ -409,6 +513,19 @@
    int size,
    void *userdata)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   void *buffer = globals->uncached_memory_bulk;
+   memcpy(buffer, data, size);
+   return (swi_vchiq_queue_bulk_transmit(handle, buffer, size,
+					 VCHI_FLAGS_CALLBACK_WHEN_OP_COMPLETE |
+					   VCHI_FLAGS_BLOCK_UNTIL_QUEUED,
+					 userdata) == NULL ? VCHIQ_SUCCESS : VCHIQ_ERROR);
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -426,6 +543,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_TRANSMIT, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 VCHIQ_STATUS_T
@@ -434,6 +552,41 @@
    int size,
    void *userdata)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle || size > (1024 * 1024))
+      return VCHIQ_ERROR;
+
+   uint32_t *buffer = globals->uncached_memory_bulk;
+   _kernel_oserror *err = swi_vchiq_queue_bulk_receive(handle, buffer, size,
+						       VCHI_FLAGS_CALLBACK_WHEN_OP_COMPLETE |
+							VCHI_FLAGS_BLOCK_UNTIL_QUEUED,
+						       userdata);
+   if (err)
+      return VCHIQ_ERROR;
+
+   {
+      /* Despite the bulk memory buffer being uncacheable, the reading of bulk
+       * data still shows some corruption (though trasmitting bulk data works
+       * correctly).
+       * By accident, I found that reading every location of the buffer before
+       * doing the copy fixed the corruption. Something to do with cache
+       * synchronisation perhaps? I don't really understand it, but it seems to
+       * work. Fortunately, bulk reads are not a common requirement.
+       * 'x' is volatile to prevent the compiler from optimising the whole thing
+       * away.
+       */
+      volatile int x;
+      int i;
+
+      for (i = 0; i < (size >> 2); i++)
+         x = buffer[i];
+   }
+
+   memcpy(data, buffer, size);
+   return VCHIQ_SUCCESS;
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -451,6 +604,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_RECEIVE, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 VCHIQ_STATUS_T
@@ -488,6 +642,30 @@
    void *userdata,
    VCHIQ_BULK_MODE_T mode)
 {
+#ifdef __riscos__
+   vcos_log_trace( "%s called service handle = 0x%08x", __func__, (uint32_t)handle );
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   VCHI_FLAGS_T flags;
+   switch (mode)
+   {
+     case VCHIQ_BULK_MODE_CALLBACK:
+       flags = VCHI_FLAGS_CALLBACK_WHEN_OP_COMPLETE | VCHI_FLAGS_BLOCK_UNTIL_QUEUED;
+       break;
+     case VCHIQ_BULK_MODE_BLOCKING:
+       flags = VCHI_FLAGS_BLOCK_UNTIL_DATA_READ;
+       break;
+     case VCHIQ_BULK_MODE_NOCALLBACK:
+     default:
+       flags = VCHI_FLAGS_NONE;
+       break;
+   }
+
+   return (swi_vchiq_queue_bulk_transmit(handle, data, size, flags, userdata) == NULL ?
+		VCHIQ_SUCCESS : VCHIQ_ERROR);
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -505,6 +683,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_TRANSMIT, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 VCHIQ_STATUS_T
@@ -539,6 +718,11 @@
    VCHIQ_BULK_MODE_T mode,
    int (*copy_pagelist)())
 {
+#ifdef __riscos__
+   report_text(__func__);
+   report_text("  forced to return VCHIQ_ERROR");
+   return VCHIQ_ERROR;
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -558,17 +742,22 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_RECEIVE, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 int
 vchiq_get_client_id(VCHIQ_SERVICE_HANDLE_T handle)
 {
+#ifdef __riscos__
+   return VCHIQ_ERROR;
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
 
    if (!service)
       return VCHIQ_ERROR;
 
    return ioctl(service->fd, VCHIQ_IOC_GET_CLIENT_ID, service->handle);
+#endif
 }
 
 void *
@@ -592,6 +781,9 @@
    int config_size,
    VCHIQ_CONFIG_T *pconfig)
 {
+#ifdef __riscos__
+   return VCHIQ_ERROR;
+#else
    VCHIQ_GET_CONFIG_T args;
    int ret;
 
@@ -604,11 +796,18 @@
    RETRY(ret, ioctl(instance->fd, VCHIQ_IOC_GET_CONFIG, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 int32_t
 vchiq_use_service( const VCHIQ_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_use(handle) == NULL ? 0 : -1);
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -617,11 +816,18 @@
 
    RETRY(ret,ioctl(service->fd, VCHIQ_IOC_USE_SERVICE, service->handle));
    return ret;
+#endif
 }
 
 int32_t
 vchiq_release_service( const VCHIQ_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_release(handle) == NULL ? 0 : -1);
+#else
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -630,12 +836,16 @@
 
    RETRY(ret,ioctl(service->fd, VCHIQ_IOC_RELEASE_SERVICE, service->handle));
    return ret;
+#endif
 }
 
 VCHIQ_STATUS_T
 vchiq_set_service_option(VCHIQ_SERVICE_HANDLE_T handle,
    VCHIQ_SERVICE_OPTION_T option, int value)
 {
+#ifdef __riscos__
+   return VCHIQ_ERROR;
+#else
    VCHIQ_SET_SERVICE_OPTION_T args;
    VCHIQ_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
@@ -650,6 +860,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_SET_SERVICE_OPTION, &args));
 
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 /*
@@ -681,6 +892,11 @@
    vcos_unused(function_table);
    vcos_unused(low_level);
 
+// Returning NULL here *may* be a bad idea.
+//   VCHI_CONNECTION_T *t = malloc(sizeof(VCHI_CONNECTION_T));
+//   memset(t, 0xfc, sizeof(VCHI_CONNECTION_T));
+//   return t;
+
    return NULL;
 }
 
@@ -704,6 +920,14 @@
    uint32_t *msg_size,
    VCHI_FLAGS_T flags )
 {
+#ifdef __riscos__
+   if (swi_vchiq_msg_peek(handle, flags, data, msg_size) != NULL)
+   {
+      vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+      return -1;
+   }
+   return 0;
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -719,6 +943,7 @@
    }
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -734,6 +959,12 @@
 int32_t
 vchi_msg_remove( VCHI_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_msg_remove(handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
 
    if (!service)
@@ -746,6 +977,7 @@
    service->peek_size = -1;
 
    return 0;
+#endif
 }
 
 /***********************************************************
@@ -769,6 +1001,17 @@
    VCHI_FLAGS_T flags,
    void * msg_handle )
 {
+#ifdef __riscos__
+   VCHIQ_ELEMENT_T element = {data, data_size};
+
+   vcos_unused(msg_handle);
+   vcos_assert(flags == VCHI_FLAGS_BLOCK_UNTIL_QUEUED);
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_msg_queue(handle, &element, 1, flags) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_MESSAGE_T args;
    VCHIQ_ELEMENT_T element = {data, data_size};
@@ -786,6 +1029,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_MESSAGE, &args));
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -809,6 +1053,11 @@
    VCHI_FLAGS_T flags,
    void * bulk_handle )
 {
+#ifdef __riscos__
+   report_text(__func__);
+   report_text("  forced to return VCHIQ_ERROR");
+   return VCHIQ_ERROR;
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -839,6 +1088,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_RECEIVE, &args));
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -862,6 +1112,18 @@
    VCHI_FLAGS_T flags,
    void * bulk_handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   void *buffer = globals->uncached_memory_bulk;
+   memcpy(buffer, data_src, data_size);
+   return (swi_vchiq_queue_bulk_transmit(handle,
+					 buffer,
+					 data_size,
+					 flags,
+					 bulk_handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_BULK_TRANSFER_T args;
    int ret;
@@ -893,6 +1155,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_BULK_TRANSMIT, &args));
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -916,6 +1179,16 @@
    uint32_t *actual_msg_size,
    VCHI_FLAGS_T flags )
 {
+#ifdef __riscos__
+   vcos_assert(flags == VCHI_FLAGS_NONE || flags == VCHI_FLAGS_BLOCK_UNTIL_OP_COMPLETE);
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_msg_dequeue(handle, data,
+				 max_data_size_to_read,
+				 flags, actual_msg_size) == 0 ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_DEQUEUE_MESSAGE_T args;
    int ret;
@@ -959,6 +1232,7 @@
       fprintf(stderr, "vchi_msg_dequeue -> %d(%d)\n", ret, errno);
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -987,6 +1261,16 @@
    VCHI_FLAGS_T flags,
    void *msg_handle )
 {
+#ifdef __riscos__
+   vcos_unused(msg_handle);
+
+   vcos_assert(flags == VCHI_FLAGS_BLOCK_UNTIL_QUEUED);
+
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_msg_queuev(handle, vector, count, flags, msg_handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    VCHIQ_QUEUE_MESSAGE_T args;
    int ret;
@@ -1004,6 +1288,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_QUEUE_MESSAGE, &args));
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -1021,11 +1306,13 @@
 {
    int ret = -1;
 
+#ifndef __riscos__
    if (message && message->message && !message->service)
    {
       free_msgbuf(message->message);
       ret = 0;
    }
+#endif
 
    return ret;
 }
@@ -1053,6 +1340,12 @@
    VCHI_FLAGS_T flags,
    VCHI_HELD_MSG_T *message_handle )
 {
+#ifdef __riscos__
+   report_text(__func__);
+   report_text("  forced to return VCHIQ_ERROR");
+//   fprintf(stderr, "[%s:%d:%s] - forced to return VCHIQ_ERROR\n", __func__, __LINE__, __FILE__);
+   return VCHIQ_ERROR;
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -1074,6 +1367,7 @@
    }
 
    return 0;
+#endif
 }
 
 /***********************************************************
@@ -1173,6 +1467,25 @@
    SERVICE_CREATION_T *setup,
    VCHI_SERVICE_HANDLE_T *handle )
 {
+#ifdef __riscos__
+   {
+     if (swi_vchiq_service_open((VCHIQ_INSTANCE_T)instance_handle, setup, handle) != NULL)
+     {
+        vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+        return -1;
+     }
+     SERVICE_ADD(*handle);
+   }
+
+   vcos_log_info("service handle %x  using fourcc 0x%x (%c%c%c%c)",
+		 *handle, setup->service_id,
+                 (setup->service_id >> 24) & 0xff,
+                 (setup->service_id >> 16) & 0xff,
+                 (setup->service_id >>  8) & 0xff,
+                 (setup->service_id      ) & 0xff );
+
+   return 0;
+#else
    VCHIQ_SERVICE_PARAMS_T params;
    VCHIQ_STATUS_T status;
 
@@ -1189,14 +1502,25 @@
       (VCHIQ_SERVICE_HANDLE_T *)handle);
 
    return (status == VCHIQ_SUCCESS) ? 0 : -1;
+#endif
 }
 
 int32_t
 vchi_service_create( VCHI_INSTANCE_T instance_handle,
    SERVICE_CREATION_T *setup, VCHI_SERVICE_HANDLE_T *handle )
 {
-   VCHIQ_SERVICE_PARAMS_T params;
+#ifdef __riscos__
+   if (swi_vchiq_service_create((VCHIQ_INSTANCE_T)instance_handle, setup, handle) != NULL)
+   {
+      vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+      return -1;
+   }
+   SERVICE_ADD(*handle);
+
+   return 0;
+#else
    VCHIQ_STATUS_T status;
+   VCHIQ_SERVICE_PARAMS_T params;
 
    memset(&params, 0, sizeof(params));
    params.fourcc = setup->service_id;
@@ -1211,11 +1535,20 @@
       (VCHIQ_SERVICE_HANDLE_T *)handle);
 
    return (status == VCHIQ_SUCCESS) ? 0 : -1;
+#endif
 }
 
 int32_t
 vchi_service_close( const VCHI_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   SERVICE_REMOVE(handle);
+
+   return (swi_vchiq_service_close(handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -1228,11 +1561,20 @@
       service->lib_handle = VCHIQ_SERVICE_HANDLE_INVALID;
 
    return ret;
+#endif
 }
 
 int32_t
 vchi_service_destroy( const VCHI_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   SERVICE_REMOVE(handle);
+
+   return (swi_vchiq_service_destroy(handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -1244,6 +1586,7 @@
    service->lib_handle = VCHIQ_SERVICE_HANDLE_INVALID;
 
    return ret;
+#endif
 }
 
 /* ----------------------------------------------------------------------
@@ -1307,6 +1650,12 @@
 int32_t
 vchi_service_use( const VCHI_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_use(handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -1315,6 +1664,7 @@
 
    RETRY(ret,ioctl(service->fd, VCHIQ_IOC_USE_SERVICE, service->handle));
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -1329,6 +1679,12 @@
  ***********************************************************/
 int32_t vchi_service_release( const VCHI_SERVICE_HANDLE_T handle )
 {
+#ifdef __riscos__
+   if (!handle)
+      return VCHIQ_ERROR;
+
+   return (swi_vchiq_service_release(handle) == NULL ? 0 : -1);
+#else
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
 
@@ -1337,6 +1693,7 @@
 
    RETRY(ret,ioctl(service->fd, VCHIQ_IOC_RELEASE_SERVICE, service->handle));
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -1354,6 +1711,10 @@
 int32_t vchi_service_set_option( const VCHI_SERVICE_HANDLE_T handle,
    VCHI_SERVICE_OPTION_T option, int value)
 {
+#ifdef __riscos__
+   fprintf(stderr, "[%s:%d:%s] - forced to return VCHIQ_ERROR\n", __func__, __LINE__, __FILE__);
+   return VCHIQ_ERROR;
+#else
    VCHIQ_SET_SERVICE_OPTION_T args;
    VCHI_SERVICE_T *service = find_service_by_handle(handle);
    int ret;
@@ -1377,6 +1738,7 @@
    RETRY(ret, ioctl(service->fd, VCHIQ_IOC_SET_SERVICE_OPTION, &args));
 
    return ret;
+#endif
 }
 
 /***********************************************************
@@ -1396,6 +1758,10 @@
                              void *ptr,
                              size_t num_bytes )
 {
+#ifdef __riscos__
+   fprintf(stderr, "[%s:%d:%s] - forced to return VCHIQ_ERROR\n", __func__, __LINE__, __FILE__);
+   return VCHIQ_ERROR;
+#else
    VCHIQ_SERVICE_T *service = (VCHIQ_SERVICE_T *)handle;
    VCHIQ_DUMP_MEM_T  dump_mem;
    int ret;
@@ -1408,6 +1774,7 @@
 
    RETRY(ret,ioctl(service->fd, VCHIQ_IOC_DUMP_PHYS_MEM, &dump_mem));
    return (ret >= 0) ? VCHIQ_SUCCESS : VCHIQ_ERROR;
+#endif
 }
 
 
@@ -1421,7 +1788,7 @@
 {
    static int mutex_initialised = 0;
    static VCOS_MUTEX_T vchiq_lib_mutex;
-   VCHIQ_INSTANCE_T instance = &vchiq_instance;
+   VCHIQ_INSTANCE_T instance = vchiq_instance;
 
    vcos_global_lock();
    if (!mutex_initialised)
@@ -1437,8 +1804,17 @@
 
    vcos_mutex_lock(&vchiq_lib_mutex);
 
-   if (instance->initialised == 0)
+   if (instance == NULL || instance->state == NULL || instance->state->initialised == 0)
    {
+#ifdef __riscos__
+      if (swi_vchiq_initialise(globals->private_word, &instance) == NULL)
+      {
+	 vchiq_instance = instance;
+//	 vcos_mutex_create(&instance->mutex, "VCHIQ instance");
+//	 instance->used_services = 0;
+	 instance->state->initialised = 1;
+      }
+#else
       instance->fd = dev_vchiq_fd == -1 ?
          open("/dev/vchiq", O_RDWR) :
          dup(dev_vchiq_fd);
@@ -1483,10 +1859,11 @@
       {
          instance = NULL;
       }
+#endif
    }
-   else if (instance->initialised > 0)
+   else if (instance->state->initialised > 0)
    {
-      instance->initialised++;
+      instance->state->initialised++;
    }
 
    vcos_mutex_unlock(&vchiq_lib_mutex);
@@ -1494,6 +1871,7 @@
    return instance;
 }
 
+#ifndef __riscos__
 static void *
 completion_thread(void *arg)
 {
@@ -1578,6 +1956,7 @@
 
    return NULL;
 }
+#endif
 
 static VCHIQ_STATUS_T
 create_service(VCHIQ_INSTANCE_T instance,
@@ -1586,6 +1965,38 @@
    int is_open,
    VCHIQ_SERVICE_HANDLE_T *phandle)
 {
+#ifdef __riscos__
+   SERVICE_CREATION_T setup;
+
+   setup.version.version = params->version;
+   setup.version.version_min = params->version_min;
+   setup.service_id = params->fourcc;
+   setup.connection = 0;
+   setup.rx_fifo_size = 0;
+   setup.tx_fifo_size = 0;
+   setup.callback = params->callback;//vchi_callback;
+   setup.callback_param = params->userdata;
+   setup.want_unaligned_bulk_rx = 0;
+   setup.want_unaligned_bulk_tx = 0;
+   setup.want_crc = 0;
+
+   if (swi_vchiq_service_create(instance, &setup, phandle) != NULL)
+   {
+      vcos_log_error("RISC OS: Error returned by SWI in '%s'", __func__);
+      return VCHIQ_ERROR;
+   }
+
+   vcos_log_info("handle %x, service handle %x  using fourcc 0x%x",
+		 *phandle, ((SHIM_SERVICE_T *)*phandle)->handle, params->fourcc);
+//   int i = ((SHIM_SERVICE_T *)*phandle)->handle & (VCHIQ_MAX_SERVICES - 1);
+//   ((VCHIQ_INSTANCE_T)instance)->state->services[i]->service_use_count++;
+//   ((VCHIQ_INSTANCE_T)instance)->state->services[i]->srvstate = VCHIQ_SRVSTATE_OPEN;
+
+//   ((SHIM_SERVICE_T *)*phandle)->callback = setup.callback;
+//   ((SHIM_SERVICE_T *)*phandle)->callback_param = setup.callback_param;
+
+   return VCHIQ_SUCCESS;
+#else
    VCHIQ_SERVICE_T *service = NULL;
    VCHIQ_STATUS_T status = VCHIQ_SUCCESS;
    int i;
@@ -1695,8 +2106,10 @@
    }
 
    return status;
+#endif
 }
 
+#ifndef __riscos__
 static int
 fill_peek_buf(VCHI_SERVICE_T *service,
    VCHI_FLAGS_T flags)
@@ -1762,3 +2175,4 @@
    free_msgbufs = buf;
    vcos_mutex_unlock(&vchiq_lib_mutex);
 }
+#endif
