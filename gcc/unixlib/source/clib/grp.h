/****************************************************************************
 *
 * $Source$
 * $Date$
 * $Revision$
 * $State$
 * $Author$
 *
 ***************************************************************************/

#ifndef __GRP_H
#define __GRP_H 1

#ifndef __SYS_TYPES_H
#include <sys/types.h>
#endif

#ifndef __STDDEF_H
#include <stddef.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __FILE_declared
#define __FILE_declared 1
typedef struct __iobuf FILE;
#endif

struct group
{
  char *gr_name; /* Group name.  */
  char *gr_passwd; /* Group password.  */
  gid_t gr_gid; /* Group ID.  */
  char **gr_mem; /* Group members.  */
};

/* Rewind the group-file stream.  */
extern void setgrent (void);

/* Close the group-file stream.  */
extern void endgrent (void);

/* Read an entry from the group-file stream, opening it if necessary.  */
extern struct group *getgrent (void);

/* Read an entry from the password-file stream, opening it if
   necessary (re-entrant version).  */
extern int getgrent_r (struct group *result_buf, char *buffer,
		       size_t buflen, struct group **result);

/* Read an entry from stream.  */
extern struct group *fgetgrent (FILE *stream);

/* Read an entry from stream (re-entrant version).  */
extern int fgetgrent_r (FILE *stream, struct group *result_buf, char *buffer,
			size_t buflen, struct group **result);

/* Search for an entry with a matching group ID.  */
extern struct group *getgrgid (gid_t gid);

/* Search for an entry with a matching group ID (re-entrant version).  */
extern int getgrgid_r (gid_t gid, struct group *resbuf, char *buffer,
		       size_t buflen, struct group **result);

/* Search for an entry with a matching group name.  */
extern struct group *getgrnam (const char *name);

/* Search for an entry with a matching group name (re-entrant version).  */
extern int getgrnam_r (const char *name, struct group *result_buf,
		       char *buffer, size_t buflen, struct group **result);

/* Get a list of all supplementary groups this user is in */
extern int getgroups (int gidsetlen, gid_t *gidset);

/* Set the list of supplementary groups this user is in */
extern int setgroups (int ngroups, const gid_t *gidset);

/* Build a list of all groups the user is in, then call setgroups on the list*/
extern int initgroups (const char *name, gid_t basegid);

/* UnixLib group implementation function.  */
extern struct group *__grpread (FILE *, struct group *);

#ifdef __cplusplus
}
#endif

#endif
