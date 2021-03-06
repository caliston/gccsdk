--- zipup.c.orig	2008-01-12 22:29:14.000000000 -0800
+++ zipup.c	2008-01-12 22:36:00.000000000 -0800
@@ -118,6 +118,9 @@
 #else
    local int filetypes OF((char *, char *));
 #endif
+#ifdef FORRISCOS
+   local int set_extra_field_forriscos OF((struct zlist far *z, iztimes *z_utim));
+#endif
 local unsigned file_read OF((char *buf, unsigned size));
 #ifdef USE_ZLIB
   local int zl_deflate_init OF((int pack_level));
@@ -276,7 +279,133 @@
 }
 #endif /* ?RISCOS */
 
+#ifdef FORRISCOS
+
+int set_extra_field_forriscos(z, z_utim)
+        struct zlist far *z;
+        iztimes *z_utim;
+{
+#ifdef USE_EF_UT_TIME
+  char *eb_ptr;
+#endif /* USE_EF_UT_TIME */
+  char *cptr;
+  char *extra_block;
+  unsigned int addr;
+  unsigned int ftype = 0xfff; /* Untyped files default to 'text' */
+  unsigned timlo;             /* 3 lower bytes of acorn file-time plus carry byte */
+  unsigned timhi;             /* 2 high bytes of acorn file-time */
+
+#define EB_SPARK_LEN    20
+#define EB_SPARK_SIZE (EB_HEADSIZE+EB_SPARK_LEN)
+#ifdef USE_EF_UT_TIME
+# ifdef IZ_CHECK_TZ
+#  define EB_UTTIME_SIZE (zp_tz_is_valid ? EB_HEADSIZE+EB_UT_LEN(1) : 0)
+# else
+#  define EB_UTTIME_SIZE (EB_HEADSIZE+EB_UT_LEN(1))
+# endif
+#else
+#  define EB_UTTIME_SIZE 0
+#endif
+#define EF_SPARK_TOTALSIZE (EB_SPARK_SIZE + EB_UTTIME_SIZE)
+
+  cptr=strrchr(z->iname, (int) ',');
+  if (cptr)
+    if ((cptr - z->iname) != (int)(strlen(z->iname)-4))
+      cptr = NULL;  /* There was a comma, but it wasn't a ,xxx at the end! */
+
+  if (cptr)
+  {
+    *cptr='\0'; /* Chop the filename at the comma */
+
+    ftype = strtol(cptr+1, NULL, 16); /* read the ,xxx as hex filetype */
+  }
+  else
+  {
+    /* When there is no given filetype, but there is a full stop in the name,
+       then it is better to let the unzip utility in RISC OS do a MimeMap lookup
+       instead, and therefore do nothing here */
+    if (strchr(z->iname, '.'))
+      return ZE_OK;
+  }
+
+  z->extra=(char *)malloc(EF_SPARK_TOTALSIZE);
+  if (z->extra==NULL) {
+    fprintf(stderr," set_extra_field_forriscos: not enough memory\n");
+    return ZE_MEM;
+  }
+  z->cextra = z->extra;
+  z->cext = z->ext = EF_SPARK_TOTALSIZE;
+
+  timlo = ((unsigned)z_utim->mtime & 0x00ffffffU) * 100 + 0x00996a00U;
+  timhi = ((unsigned)z_utim->mtime >> 24);
+  timhi = timhi * 100 + 0x0000336eU + (timlo >> 24);
+
+  extra_block=z->extra;
+  /* ID */
+  extra_block[0]='A';
+  extra_block[1]='C';
+
+  /* size */
+  extra_block[2]=(char)(EB_SPARK_LEN);
+  extra_block[3]=(char)(EB_SPARK_LEN)>>8;
+
+  /* ID_2 */
+  extra_block[4]='A';
+  extra_block[5]='R';
+  extra_block[6]='C';
+  extra_block[7]='0';
+
+  /* Load address */
+  addr=0xfff00000 | (ftype << 8);  /* This file is typed, and has filetype 'ftype' */
+  addr|= ((timhi >> 8) & 0xffU);
+  extra_block[8]=(char)(addr);
+  extra_block[9]=(char)(addr>>8);
+  extra_block[10]=(char)(addr>>16);
+  extra_block[11]=(char)(addr>>24);
+
+  /* Exec address */
+  addr=(timlo & 0x00ffffffU) | ((timhi & 0x000000ffU) << 24);
+  extra_block[12]=(char)(addr);
+  extra_block[13]=(char)(addr>>8);
+  extra_block[14]=(char)(addr>>16);
+  extra_block[15]=(char)(addr>>24);
+
+  /* Attributes */
+  extra_block[16]=0x13;  /* Private read/write, no public access, unlocked */
+  extra_block[17]=0;
+  extra_block[18]=0;
+  extra_block[19]=0;
+
+  /* Zero */
+  extra_block[20]=0;
+  extra_block[21]=0;
+  extra_block[22]=0;
+  extra_block[23]=0;
+
+#ifdef USE_EF_UT_TIME
+# ifdef IZ_CHECK_TZ
+  if (zp_tz_is_valid) {
+# endif
+    eb_ptr = z->extra + EB_SPARK_SIZE;
+
+    eb_ptr[0]  = 'U';
+    eb_ptr[1]  = 'T';
+    eb_ptr[2]  = EB_UT_LEN(1);          /* length of data part of e.f. */
+    eb_ptr[3]  = 0;
+    eb_ptr[4]  = EB_UT_FL_MTIME;
+    eb_ptr[5]  = (char)(z_utim->mtime);
+    eb_ptr[6]  = (char)(z_utim->mtime >> 8);
+    eb_ptr[7]  = (char)(z_utim->mtime >> 16);
+    eb_ptr[8]  = (char)(z_utim->mtime >> 24);
+# ifdef IZ_CHECK_TZ
+  }
+# endif
+#endif /* USE_EF_UT_TIME */
+
+  return ZE_OK;
+}
 
+#endif /* FORRISCOS */
 
 /* Note: a zip "entry" includes a local header (which includes the file
    name), an encryption header if encrypting, the compressed data
@@ -360,6 +489,15 @@
 #if !(defined(VMS) && defined(VMS_PK_EXTRA))
     if (extra_fields) {
       /* create extra field and change z->att and z->atx if desired */
+#ifdef FORRISCOS
+      if (decomma)
+      {
+        /* If we're making a zip for RISC OS, we don't bother with any other */
+        /*  OS-Specific info (although we could - but there's no point!)     */
+        set_extra_field_forriscos(z, &f_utim);
+      }
+      else
+#endif
       set_extra_field(z, &f_utim);
 #ifdef QLZIP
       if(qlflag)
