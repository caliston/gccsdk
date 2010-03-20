# Automake style makefile for UnixLib
# Copyright (c) 2005-2010 UnixLib developers
# Written by Nick Burrett <nick@sqrt.co.uk>

# Directory where headers will be installed.
tooldir = $(exec_prefix)/$(target_alias)

# Multilib support
MAKEOVERRIDES=

# These flags exclusively apply to a C compiler
WARNINGSC = -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations \
	-Wnested-externs

WARNINGS = -pedantic -Wall -Wundef -Wpointer-arith \
	-Wcast-align -Wwrite-strings -Winline -Wno-unused \
	-Winline -Wno-unused -W -Wcast-qual -Wshadow $(WARNINGSC)

# The -isystem command tells GCC to prefer the header files in UnixLib,
# rather than trying to compile the library with the system headers.
# Header files that provide additional definitions only required for the
# building of UnixLib should be held in the source directories.
AM_CPPFLAGS = -isystem $(top_srcdir)/include -I $(top_srcdir)/incl-local

# C99 mode is required to build UnixLib because the library now contains
# a lot of C99 features.
# The __GNU_LIBRARY__ definition is for matching the expectation of the couple
# of GNU C Library files we're using.
# The NO_LONG_DOUBLE and NO_LONG_DOUBLE_MATH definitions results in having the
# 'long double' math routines aliased as the normal 'double' onces.
AM_CFLAGS = -D__GNU_LIBRARY__ -DNO_LONG_DOUBLE -D__NO_LONG_DOUBLE_MATH -D_GNU_SOURCE=1 -std=c99 $(LIBM_FLAGS)

# Assembler files rely heavily on the C preprocessor to keep structures
# referred to by both languages in sync.
AM_CCASFLAGS = -xassembler-with-cpp -isystem $(top_srcdir)/include -I $(top_srcdir)/incl-local

SUBDIRS = test

includedir = $(prefix)
grp_src = 	grp/getgrgid_r.c \
	grp/grpread.c \
	grp/fgetgrentr.c \
	grp/getgrnam.c \
	grp/fgetgrent.c \
	grp/getgroups.c \
	grp/getgrgid.c \
	grp/getgrent.c \
	grp/getgrnam_r.c \
	grp/getgrouplist.c

gcccompat_src = 	gcccompat/galloca.c \
	gcccompat/_galloca.s \
	gcccompat/_b_return.s \
	gcccompat/_eh_support.s \
	gcccompat/_b_frame.s

sched_src = 	sched/syield.c

fenv_src = 	fenv/fegetround.c \
	fenv/fclrexcpt.c \
	fenv/feenablxcpt.c \
	fenv/fsetexcptflg.c \
	fenv/fegetenv.c \
	fenv/feholdexcpt.c \
	fenv/fegetexcept.c \
	fenv/fraiseexcpt.c \
	fenv/fesetenv.c \
	fenv/fedisblxcpt.c \
	fenv/fesetround.c \
	fenv/ftestexcept.c

common_src = 	common/__stat.c \
	common/unixify.c \
	common/exist.c \
	common/funcallerr.c \
	common/attrib.c \
	common/cvttime.c \
	common/symlinks.c \
	common/riscosify.c \
	common/prefix.c \
	common/objattr.c \
	common/fdname.c \
	common/serial.c \
	common/sockvalid.c \
	common/_taskhandle.s \
	common/_atomic.s \
	common/_exist.s \
	common/_riscosify.s

misc_src = 	misc/dirname.c

pwd_src = 	pwd/getpw.c \
	pwd/fgetpwent.c \
	pwd/getpwent.c \
	pwd/putpwent.c \
	pwd/fgetpwentr.c \
	pwd/getpwnam.c \
	pwd/getpwuid_r.c \
	pwd/getpwuid.c \
	pwd/getpwnam_r.c \
	pwd/getlogin.c \
	pwd/pwdread.c

locale_src = 	locale/nl_langinfo.c \
	locale/setlocale.c \
	locale/territory.c \
	locale/localeconv.c \
	locale/ctypetable.c \
	locale/strxfrm.c \
	locale/strcoll.c \
	locale/iconv.c

stdio_src = 	stdio/flsbuf.c \
	stdio/newstream.c \
	stdio/perror.c \
	stdio/filbuf.c \
	stdio/ungetc.c \
	stdio/getc.c \
	stdio/printf.c \
	stdio/gets.c \
	stdio/clearerr.c \
	stdio/fread.c \
	stdio/getw.c \
	stdio/vasprintf.c \
	stdio/setbuf.c \
	stdio/popen.c \
	stdio/stdio.c \
	stdio/fgets.c \
	stdio/rename.c \
	stdio/fpurge.c \
	stdio/tmpfile.c \
	stdio/asprintf.c \
	stdio/fclose.c \
	stdio/freopen.c \
	stdio/fopen.c \
	stdio/scanf.c \
	stdio/fputs.c \
	stdio/putw.c \
	stdio/vfprintf.c \
	stdio/ferror.c \
	stdio/fflush.c \
	stdio/getdelim.c \
	stdio/fwrite.c \
	stdio/feof.c \
	stdio/fileno.c \
	stdio/putc.c \
	stdio/remove.c \
	stdio/puts.c \
	stdio/fpos.c

module_src = 	module/sul.s

libm_generic_src = 	libm-generic/s_csinhf.c \
	libm-generic/w_fmodf.c \
	libm-generic/s_significandf.c \
	libm-generic/w_lgamma_r.c \
	libm-generic/e_gammal_r.c \
	libm-generic/s_cacosh.c \
	libm-generic/s_ccosf.c \
	libm-generic/s_nan.c \
	libm-generic/s_ldexp.c \
	libm-generic/w_atan2.c \
	libm-generic/w_atan2f.c \
	libm-generic/s_ccoshf.c \
	libm-generic/s_significand.c \
	libm-generic/w_exp10.c \
	libm-generic/w_exp10f.c \
	libm-generic/w_scalb.c \
	libm-generic/s_casinhf.c \
	libm-generic/s_fmin.c \
	libm-generic/s_clog10.c \
	libm-generic/w_acosh.c \
	libm-generic/s_cacoshf.c \
	libm-generic/w_fmod.c \
	libm-generic/e_scalb.c \
	libm-generic/s_cpow.c \
	libm-generic/s_catanhf.c \
	libm-generic/w_lgammaf.c \
	libm-generic/s_csin.c \
	libm-generic/w_lgamma.c \
	libm-generic/w_tgamma.c \
	libm-generic/w_sqrtf.c \
	libm-generic/s_csqrtf.c \
	libm-generic/w_exp2.c \
	libm-generic/s_cprojf.c \
	libm-generic/w_jn.c \
	libm-generic/s_ctanh.c \
	libm-generic/s_cacosf.c \
	libm-generic/w_pow.c \
	libm-generic/w_j1f.c \
	libm-generic/s_fma.c \
	libm-generic/s_fdimf.c \
	libm-generic/w_asinf.c \
	libm-generic/s_cacos.c \
	libm-generic/e_scalbf.c \
	libm-generic/s_ctanf.c \
	libm-generic/w_remainderf.c \
	libm-generic/w_log10.c \
	libm-generic/s_clogf.c \
	libm-generic/e_exp10f.c \
	libm-generic/s_nexttowardf.c \
	libm-generic/w_atanhf.c \
	libm-generic/s_ctanhf.c \
	libm-generic/w_log.c \
	libm-generic/w_acosf.c \
	libm-generic/w_tgammaf.c \
	libm-generic/s_ctan.c \
	libm-generic/w_coshf.c \
	libm-generic/w_log10f.c \
	libm-generic/w_acoshf.c \
	libm-generic/s_casinh.c \
	libm-generic/s_fdim.c \
	libm-generic/s_cpowf.c \
	libm-generic/w_remainder.c \
	libm-generic/s_catanh.c \
	libm-generic/s_ldexpf.c \
	libm-generic/w_j0.c \
	libm-generic/w_j1.c \
	libm-generic/w_cosh.c \
	libm-generic/s_csqrt.c \
	libm-generic/w_dremf.c \
	libm-generic/e_exp10.c \
	libm-generic/s_csinh.c \
	libm-generic/s_catanf.c \
	libm-generic/w_drem.c \
	libm-generic/w_logf.c \
	libm-generic/s_casinf.c \
	libm-generic/s_ccos.c \
	libm-generic/s_catan.c \
	libm-generic/w_scalbf.c \
	libm-generic/s_fmaf.c \
	libm-generic/w_jnf.c \
	libm-generic/w_powf.c \
	libm-generic/s_clog.c \
	libm-generic/w_hypotf.c \
	libm-generic/s_fmaxf.c \
	libm-generic/w_hypot.c \
	libm-generic/s_clog10f.c \
	libm-generic/s_nextafter.c \
	libm-generic/w_atanh.c \
	libm-generic/s_cexpf.c \
	libm-generic/s_nanf.c \
	libm-generic/w_sqrt.c \
	libm-generic/w_j0f.c \
	libm-generic/s_fminf.c \
	libm-generic/s_cproj.c \
	libm-generic/w_lgammaf_r.c \
	libm-generic/s_fmax.c \
	libm-generic/s_casin.c \
	libm-generic/w_exp2f.c \
	libm-generic/s_ccosh.c \
	libm-generic/s_csinf.c \
	libm-generic/w_log2.c \
	libm-generic/s_cexp.c \
	libm-generic/w_acos.c \
	libm-generic/w_asin.c \
	libm-generic/w_sinh.c \
	libm-generic/w_sinhf.c \
	libm-generic/w_log2f.c

gdtoa_src = 	gdtoa/misc.c \
	gdtoa/strtodg.c \
	gdtoa/_ldtoa.c \
	gdtoa/gmisc.c \
	gdtoa/g_Qfmt.c \
	gdtoa/strtoIg.c \
	gdtoa/g_xfmt.c \
	gdtoa/_hdtoa.c \
	gdtoa/strtoIQ.c \
	gdtoa/g_xLfmt.c \
	gdtoa/g_ffmt.c \
	gdtoa/strtordd.c \
	gdtoa/gethex.c \
	gdtoa/strtorx.c \
	gdtoa/strtorf.c \
	gdtoa/strtoIxL.c \
	gdtoa/hexnan.c \
	gdtoa/strtoId.c \
	gdtoa/glue.c \
	gdtoa/ulp.c \
	gdtoa/smisc.c \
	gdtoa/strtorQ.c \
	gdtoa/strtopQ.c \
	gdtoa/strtopd.c \
	gdtoa/strtoIf.c \
	gdtoa/g__fmt.c \
	gdtoa/g_dfmt.c \
	gdtoa/strtopdd.c \
	gdtoa/strtof.c \
	gdtoa/strtopxL.c \
	gdtoa/strtoIdd.c \
	gdtoa/strtod.c \
	gdtoa/dtoa.c \
	gdtoa/strtodI.c \
	gdtoa/g_ddfmt.c \
	gdtoa/strtopf.c \
	gdtoa/gdtoa.c \
	gdtoa/strtoIx.c \
	gdtoa/sum.c \
	gdtoa/hd_init.c \
	gdtoa/strtopx.c \
	gdtoa/strtord.c \
	gdtoa/dmisc.c \
	gdtoa/strtorxL.c

sound_src = 	sound/dsp.c

signal_src = 	signal/sigaddset.c \
	signal/sigprocmsk.c \
	signal/init.c \
	signal/signal.c \
	signal/sleep.c \
	signal/sigdelset.c \
	signal/sigaltstk.c \
	signal/sigsetmask.c \
	signal/sigpause.c \
	signal/pause.c \
	signal/sigvec.c \
	signal/raise.c \
	signal/signame.c \
	signal/post.c \
	signal/siginfo.c \
	signal/sigsets.c \
	signal/sigismembe.c \
	signal/sigpending.c \
	signal/sigstack.c \
	signal/sigsuspend.c \
	signal/kill.c \
	signal/psignal.c \
	signal/sigblock.c \
	signal/sigaction.c \
	signal/_signal.s \
	signal/_demangle.s \
	signal/sigexec.s

sys_src = 	sys/execl.c \
	sys/execle.c \
	sys/mount.c \
	sys/alarm.c \
	sys/mman.c \
	sys/execlp.c \
	sys/exec.c \
	sys/vfork.c \
	sys/stackalloc.c \
	sys/errlist.c \
	sys/sigsetjmp.c \
	sys/brk.c \
	sys/execv.c \
	sys/execvp.c \
	sys/_os.s \
	sys/_mman.s \
	sys/_swi.s \
	sys/_getcpuarch.s \
	sys/_jmp.s \
	sys/_syslib.s \
	sys/_vfork.s \
	sys/_sigjmp.s

ctype_src = 	ctype/ctypeproc.c \
	ctype/ctype.c

string_src = 	string/strcat.c \
	string/strichr.c \
	string/strdup.c \
	string/strchr.c \
	string/strcmp.c \
	string/strnlen.c \
	string/stpcpy.c \
	string/strchrnul.c \
	string/strndup.c \
	string/strpbrk.c \
	string/strncpy.c \
	string/stpncpy.c \
	string/strrichr.c \
	string/swab.c \
	string/memrchr.c \
	string/memcmp.c \
	string/strncat.c \
	string/rawmemchr.c \
	string/strtok_r.c \
	string/strspn.c \
	string/strcspn.c \
	string/strsignal.c \
	string/strtok.c \
	string/basename.c \
	string/memchr.c \
	string/stricmp.c \
	string/strstr.c \
	string/strsep.c \
	string/strnicmp.c \
	string/strrchr.c \
	string/memccpy.c \
	string/strncmp.c \
	string/_ffsll.s \
	string/_strlen.s \
	string/_memcpy.s \
	string/_strcpy.s \
	string/_ffs.s \
	string/_memset.s

debug_src = 	debug/debug.c \
	debug/dvsprintf.c

crt_src = 	crt/crt0.s \
	crt/gcrt0.s

scl_src = 	scl/_kosargs.s \
	scl/_kosrdch.s \
	scl/_kernel.s \
	scl/_kosfile.s \
	scl/_kgetenv.s \
	scl/_kosgbpb.s \
	scl/_kosbyte.s \
	scl/_ksetenv.s \
	scl/_kosbput.s \
	scl/_kosfind.s \
	scl/_koscli.s \
	scl/_kswi_c.s \
	scl/_kcurskch.s \
	scl/_kfpavailable.s \
	scl/_kosbget.s

search_src = 	search/tsearch.c \
	search/hsearch.c \
	search/lsearch.c \
	search/insremque.c \
	search/hsearch_r.c

inttypes_src = 	inttypes/strtoumax.c \
	inttypes/strtoimax.c

wchar_src = 	wchar/wcscpy.c \
	wchar/wctob.c \
	wchar/wcscat.c \
	wchar/wmemcmp.c \
	wchar/wcpcpy.c \
	wchar/mbrlen.c \
	wchar/mbtowc.c \
	wchar/mbsinit.c \
	wchar/wcstod.c \
	wchar/wmemcpy.c \
	wchar/btowc.c \
	wchar/wcsstr.c \
	wchar/wctype.c \
	wchar/wcsncmp.c \
	wchar/wcsncat.c \
	wchar/wmemset.c \
	wchar/mbsrtowcs.c \
	wchar/mbsnrtowcs.c \
	wchar/wcscspn.c \
	wchar/wcsxfrm.c \
	wchar/wcscoll.c \
	wchar/wmemchr.c \
	wchar/wcsrchr.c \
	wchar/wcswidth.c \
	wchar/wcstof.c \
	wchar/wcspbrk.c \
	wchar/mbrtowc.c \
	wchar/wcstold.c \
	wchar/wcslen.c \
	wchar/wcstombs.c \
	wchar/wcsncpy.c \
	wchar/wcsrtombs.c \
	wchar/wctomb.c \
	wchar/wcpncpy.c \
	wchar/wcscmp.c \
	wchar/wcwidth.c \
	wchar/mblen.c \
	wchar/wcstok.c \
	wchar/wmemmove.c \
	wchar/wcsspn.c \
	wchar/wcrtomb.c \
	wchar/wcschr.c \
	wchar/wcstol.c \
	wchar/wcsnrtombs.c \
	wchar/wcsdup.c \
	wchar/mbstowcs.c

pthread_src = 	pthread/atfork.c \
	pthread/detach.c \
	pthread/keydest.c \
	pthread/rwlock.c \
	pthread/exit.c \
	pthread/newnode.c \
	pthread/condattr.c \
	pthread/once.c \
	pthread/attr.c \
	pthread/pthsignal.c \
	pthread/mutexattr.c \
	pthread/sem.c \
	pthread/context.c \
	pthread/cleanupcall.c \
	pthread/schedparam.c \
	pthread/pthinit.c \
	pthread/self.c \
	pthread/mutex.c \
	pthread/equal.c \
	pthread/create.c \
	pthread/key.c \
	pthread/cond.c \
	pthread/error.c \
	pthread/lock.c \
	pthread/cleanup.c \
	pthread/join.c \
	pthread/rwlockattr.c \
	pthread/cancel.c \
	pthread/testcancel.c \
	pthread/_yield.s \
	pthread/_exit.s \
	pthread/_context.s \
	pthread/_ints.s

termios_src = 	termios/gtty.c \
	termios/tcflush.c \
	termios/tcflow.c \
	termios/tcgetattr.c \
	termios/tcdrain.c \
	termios/stty.c \
	termios/cfsetispee.c \
	termios/tcsetpgrp.c \
	termios/tcsendbrk.c \
	termios/ctermid.c \
	termios/tcgetpgrp.c \
	termios/tcsetattr.c \
	termios/cuserid.c \
	termios/termcap.c \
	termios/cfgetispee.c \
	termios/cfgetospee.c \
	termios/cfsetospee.c

resource_src = 	resource/setuid.c \
	resource/initialise.c \
	resource/getprior.c \
	resource/setprior.c \
	resource/getuid.c \
	resource/getrusage.c \
	resource/getrlimit.c \
	resource/getppid.c \
	resource/getpgrp.c \
	resource/setpgid.c \
	resource/getgid.c \
	resource/getegid.c \
	resource/getpid.c \
	resource/setrlimit.c \
	resource/ulimit.c \
	resource/seteuid.c \
	resource/setpgrp.c \
	resource/setsid.c \
	resource/setgid.c \
	resource/geteuid.c

assert_src = 	assert/assert.c

unix_src = 	unix/fchmod.c \
	unix/pipe.c \
	unix/nice.c \
	unix/chdir.c \
	unix/utime.c \
	unix/mkdir.c \
	unix/fcntl.c \
	unix/getopt.c \
	unix/chmod.c \
	unix/stat.c \
	unix/alphasort.c \
	unix/truncate.c \
	unix/poll.c \
	unix/wait3.c \
	unix/readv.c \
	unix/writev.c \
	unix/rmdir.c \
	unix/dirfd.c \
	unix/umask.c \
	unix/waitpid.c \
	unix/unlink.c \
	unix/write.c \
	unix/select.c \
	unix/fstat.c \
	unix/getcwd.c \
	unix/sysconf.c \
	unix/proc.c \
	unix/getdomain.c \
	unix/statfs.c \
	unix/dev.c \
	unix/getenv.c \
	unix/getsubopt.c \
	unix/features.c \
	unix/ispipe.c \
	unix/reopen.c \
	unix/creat.c \
	unix/dup2.c \
	unix/lseek.c \
	unix/getopt1.c \
	unix/dirent.c \
	unix/lstat.c \
	unix/fnmatch.c \
	unix/custom.c \
	unix/getdtables.c \
	unix/wait4.c \
	unix/setenv.c \
	unix/syslog.c \
	unix/isatty.c \
	unix/unix.c \
	unix/pathconf.c \
	unix/glob.c \
	unix/sync.c \
	unix/uname.c \
	unix/open.c \
	unix/putenv.c \
	unix/gethostnam.c \
	unix/ioctl.c \
	unix/close.c \
	unix/read.c \
	unix/access.c \
	unix/wait.c \
	unix/pselect.c \
	unix/dup.c \
	unix/tty.c

stdlib_src = 	stdlib/realpath.c \
	stdlib/atof.c \
	stdlib/strtold.c \
	stdlib/lrand48.c \
	stdlib/lcong48.c \
	stdlib/atoll.c \
	stdlib/rand.c \
	stdlib/labs.c \
	stdlib/drand48.c \
	stdlib/seed48.c \
	stdlib/_rand48.c \
	stdlib/system.c \
	stdlib/xpg_basename.c \
	stdlib/mrand48.c \
	stdlib/strtoul.c \
	stdlib/errno.c \
	stdlib/strtoll.c \
	stdlib/random.c \
	stdlib/abort.c \
	stdlib/strtoull.c \
	stdlib/msort.c \
	stdlib/atol.c \
	stdlib/erand48.c \
	stdlib/atexit.c \
	stdlib/strtol.c \
	stdlib/jrand48.c \
	stdlib/div.c \
	stdlib/abs.c \
	stdlib/llabs.c \
	stdlib/atoi.c \
	stdlib/nrand48.c \
	stdlib/alloc.c \
	stdlib/bsearch.c \
	stdlib/srand48.c

stat_src = 	stat/mkfifo.c \
	stat/mknod.c

resolv_src = 	resolv/base64.c \
	resolv/nsap_addr.c \
	resolv/ns_parse.c \
	resolv/res_debug.c \
	resolv/ns_netint.c \
	resolv/ns_ttl.c \
	resolv/inet_net_pton.c \
	resolv/res_send.c \
	resolv/inet_addr.c \
	resolv/herror.c \
	resolv/ns_samedomain.c \
	resolv/res_data.c \
	resolv/res_init.c \
	resolv/gethnamaddr.c \
	resolv/opensock.c \
	resolv/inet_ntop.c \
	resolv/res_comp.c \
	resolv/res_mkquery.c \
	resolv/inet_neta.c \
	resolv/res_hconf.c \
	resolv/res_query.c \
	resolv/inet_net_ntop.c \
	resolv/ns_print.c \
	resolv/ns_name.c \
	resolv/inet_pton.c

netlib_src = 	netlib/inet_ntoa.c \
	netlib/sendmsg.c \
	netlib/socketpair.c \
	netlib/recvmsg.c \
	netlib/listen.c \
	netlib/in6_addr.c \
	netlib/recvfrom.c \
	netlib/getsockopt.c \
	netlib/inet_lnaof.c \
	netlib/h_errno.c \
	netlib/getpeernam.c \
	netlib/serv.c \
	netlib/inet_netof.c \
	netlib/inet_mkad.c \
	netlib/connect.c \
	netlib/setsockopt.c \
	netlib/sendto.c \
	netlib/readline.c \
	netlib/accept.c \
	netlib/proto.c \
	netlib/bind.c \
	netlib/socket.c \
	netlib/shutdown.c \
	netlib/net.c \
	netlib/inet_netwo.c \
	netlib/recv.c \
	netlib/getaddrinfo.c \
	netlib/send.c \
	netlib/getsocknam.c \
	netlib/_sockstat.s \
	netlib/_sread.s \
	netlib/_getsockop.s \
	netlib/_sendmsg.s \
	netlib/_recvmsg.s \
	netlib/_setsockop.s \
	netlib/_gettsize.s \
	netlib/_net_error.s \
	netlib/_sendtosm.s \
	netlib/_send.s \
	netlib/_swrite.s \
	netlib/_readv.s \
	netlib/_socket.s \
	netlib/_sclose.s \
	netlib/_writev.s \
	netlib/_recvfrom.s \
	netlib/_listen.s \
	netlib/_accept.s \
	netlib/_sioctl.s \
	netlib/_getpeerna.s \
	netlib/_sendto.s \
	netlib/_recv.s \
	netlib/_getsockna.s \
	netlib/_shutdown.s \
	netlib/_connect.s \
	netlib/_select.s \
	netlib/_bind.s

time_src = 	time/gettod.c \
	time/clk_gettime.c \
	time/difftime.c \
	time/setitmr.c \
	time/adjtime.c \
	time/dysize.c \
	time/time.c \
	time/localtime.c \
	time/localtime_r.c \
	time/broken.c \
	time/settod.c \
	time/clk_getres.c \
	time/gmtime_r.c \
	time/calendconv.c \
	time/utimes.c \
	time/asctime.c \
	time/gmtime.c \
	time/times.c \
	time/clk_settime.c \
	time/ftime.c \
	time/tzset.c \
	time/ctime.c \
	time/strftime.c \
	time/getitmr.c \
	time/timegm.c \
	time/mktime.c \
	time/stdtime.c \
	time/_clock.s

gmon_src = 	gmon/machine-gmon.c \
	gmon/gmon.c \
	gmon/mcount.c \
	gmon/prof-freq.c \
	gmon/profil.c \
	gmon/gmon-start.c \
	gmon/_profile.s

unistd_src = 	unistd/readlink.c \
	unistd/fchown.c \
	unistd/lockf.c \
	unistd/getpass.c \
	unistd/lchown.c \
	unistd/chroot.c \
	unistd/getpagesiz.c \
	unistd/chown.c \
	unistd/fchdir.c \
	unistd/symlink.c \
	unistd/link.c

libm_complex_src = 	libm-complex/cabsf.c \
	libm-complex/conjf.c \
	libm-complex/cabs.c \
	libm-complex/cargf.c \
	libm-complex/crealf.c \
	libm-complex/conj.c \
	libm-complex/carg.c \
	libm-complex/creal.c \
	libm-complex/cimag.c \
	libm-complex/cimagf.c

libm_support_src = 	libm-support/s_lib_version.c \
	libm-support/k_standard.c \
	libm-support/s_matherr.c \
	libm-support/s_signgam.c

libm_dbl64_src = 	libm-dbl64/s_atan.c \
	libm-dbl64/e_j1.c \
	libm-dbl64/s_lrint.c \
	libm-dbl64/s_modf.c \
	libm-dbl64/k_tan.c \
	libm-dbl64/e_gamma_r.c \
	libm-dbl64/s_round.c \
	libm-dbl64/s_logb.c \
	libm-dbl64/mpexp.c \
	libm-dbl64/e_atan2.c \
	libm-dbl64/e_exp2.c \
	libm-dbl64/mplog.c \
	libm-dbl64/s_isnan.c \
	libm-dbl64/s_nearbyint.c \
	libm-dbl64/e_cosh.c \
	libm-dbl64/e_sqrt.c \
	libm-dbl64/e_exp.c \
	libm-dbl64/mptan.c \
	libm-dbl64/e_asin.c \
	libm-dbl64/e_log10.c \
	libm-dbl64/s_cbrt.c \
	libm-dbl64/s_floor.c \
	libm-dbl64/s_copysign.c \
	libm-dbl64/e_pow.c \
	libm-dbl64/s_scalbln.c \
	libm-dbl64/e_lgamma_r.c \
	libm-dbl64/s_sincos.c \
	libm-dbl64/s_fpclassify.c \
	libm-dbl64/s_sin.c \
	libm-dbl64/mpsqrt.c \
	libm-dbl64/s_trunc.c \
	libm-dbl64/halfulp.c \
	libm-dbl64/sincos32.c \
	libm-dbl64/slowpow.c \
	libm-dbl64/s_asinh.c \
	libm-dbl64/dosincos.c \
	libm-dbl64/t_exp.c \
	libm-dbl64/mpatan.c \
	libm-dbl64/s_signbit.c \
	libm-dbl64/e_fmod.c \
	libm-dbl64/branred.c \
	libm-dbl64/mpa.c \
	libm-dbl64/s_isinf.c \
	libm-dbl64/slowexp.c \
	libm-dbl64/s_finite.c \
	libm-dbl64/e_rem_pio2.c \
	libm-dbl64/s_scalbn.c \
	libm-dbl64/e_acosh.c \
	libm-dbl64/k_rem_pio2.c \
	libm-dbl64/e_atanh.c \
	libm-dbl64/s_tanh.c \
	libm-dbl64/e_sinh.c \
	libm-dbl64/s_tan.c \
	libm-dbl64/s_lround.c \
	libm-dbl64/doasin.c \
	libm-dbl64/e_j0.c \
	libm-dbl64/s_expm1.c \
	libm-dbl64/e_remainder.c \
	libm-dbl64/w_exp.c \
	libm-dbl64/s_log1p.c \
	libm-dbl64/mpatan2.c \
	libm-dbl64/s_remquo.c \
	libm-dbl64/s_ceil.c \
	libm-dbl64/s_llrint.c \
	libm-dbl64/e_jn.c \
	libm-dbl64/e_hypot.c \
	libm-dbl64/s_erf.c \
	libm-dbl64/e_log.c \
	libm-dbl64/s_frexp.c \
	libm-dbl64/s_rint.c \
	libm-dbl64/s_ilogb.c \
	libm-dbl64/e_log2.c \
	libm-dbl64/s_fabs.c \
	libm-dbl64/s_llround.c

libm_flt32_src = 	libm-flt32/e_expf.c \
	libm-flt32/s_ceilf.c \
	libm-flt32/k_tanf.c \
	libm-flt32/s_tanf.c \
	libm-flt32/k_cosf.c \
	libm-flt32/e_j0f.c \
	libm-flt32/e_j1f.c \
	libm-flt32/s_rintf.c \
	libm-flt32/s_remquof.c \
	libm-flt32/e_powf.c \
	libm-flt32/e_asinf.c \
	libm-flt32/e_remainderf.c \
	libm-flt32/w_expf.c \
	libm-flt32/s_lroundf.c \
	libm-flt32/s_llroundf.c \
	libm-flt32/e_acoshf.c \
	libm-flt32/s_floorf.c \
	libm-flt32/s_finitef.c \
	libm-flt32/s_log1pf.c \
	libm-flt32/s_erff.c \
	libm-flt32/s_cbrtf.c \
	libm-flt32/s_fabsf.c \
	libm-flt32/s_sinf.c \
	libm-flt32/s_atanf.c \
	libm-flt32/k_sinf.c \
	libm-flt32/s_fpclassifyf.c \
	libm-flt32/e_exp2f.c \
	libm-flt32/s_roundf.c \
	libm-flt32/s_copysignf.c \
	libm-flt32/s_scalbnf.c \
	libm-flt32/e_hypotf.c \
	libm-flt32/e_gammaf_r.c \
	libm-flt32/e_sqrtf.c \
	libm-flt32/e_rem_pio2f.c \
	libm-flt32/s_expm1f.c \
	libm-flt32/e_jnf.c \
	libm-flt32/s_nextafterf.c \
	libm-flt32/e_acosf.c \
	libm-flt32/e_sinhf.c \
	libm-flt32/s_cosf.c \
	libm-flt32/s_sincosf.c \
	libm-flt32/s_frexpf.c \
	libm-flt32/s_signbitf.c \
	libm-flt32/s_nearbyintf.c \
	libm-flt32/s_asinhf.c \
	libm-flt32/e_lgammaf_r.c \
	libm-flt32/e_coshf.c \
	libm-flt32/e_atan2f.c \
	libm-flt32/e_atanhf.c \
	libm-flt32/s_lrintf.c \
	libm-flt32/k_rem_pio2f.c \
	libm-flt32/e_log2f.c \
	libm-flt32/s_modff.c \
	libm-flt32/s_isinff.c \
	libm-flt32/e_log10f.c \
	libm-flt32/s_ilogbf.c \
	libm-flt32/s_tanhf.c \
	libm-flt32/s_scalblnf.c \
	libm-flt32/s_logbf.c \
	libm-flt32/s_truncf.c \
	libm-flt32/s_isnanf.c \
	libm-flt32/e_logf.c \
	libm-flt32/s_llrintf.c \
	libm-flt32/e_fmodf.c

crypt_src = 	crypt/md5-crypt.c \
	crypt/crypt.c \
	crypt/crypt-entry.c \
	crypt/md5.c \
	crypt/crypt_util.c

regexp_src = 	regexp/regerror.c \
	regexp/regcomp.c \
	regexp/regfree.c \
	regexp/regexec.c

libc_headers = 	malloc.h \
	fcrypt.h \
	pwd.h \
	utime.h \
	netdb.h \
	search.h \
	ulimit.h \
	sysexits.h \
	termios.h \
	iconv.h \
	unistd.h \
	grp.h \
	strings.h \
	string.h \
	syslog.h \
	nl_types.h \
	stdint.h \
	regexp.h \
	setjmp.h \
	getopt.h \
	signal.h \
	fenv.h \
	stdlib.h \
	inttypes.h \
	features.h \
	ctype.h \
	kernel.h \
	fcntl.h \
	time.h \
	langinfo.h \
	ieee754.h \
	termcap.h \
	poll.h \
	wctype.h \
	fnmatch.h \
	resolv.h \
	glob.h \
	complex.h \
	dlfcn.h \
	endian.h \
	sched.h \
	dirent.h \
	math.h \
	swis.h \
	crypt.h \
	regex.h \
	termio.h \
	assert.h \
	locale.h \
	wchar.h \
	stdio.h \
	pthread.h \
	alloca.h \
	ar.h \
	sgtty.h \
	memory.h \
	byteswap.h \
	limits.h \
	errno.h \
	semaphore.h \
	libgen.h \
	stdio_ext.h \
	fpu_control.h \
	arpa/nameser.h \
	arpa/inet.h \
	arpa/ftp.h \
	arpa/tftp.h \
	arpa/telnet.h \
	arpa/nameser_compat.h \
	sys/queue.h \
	sys/netdb.h \
	sys/gmon.h \
	sys/stat.h \
	sys/statfs.h \
	sys/termios.h \
	sys/utsname.h \
	sys/syslog.h \
	sys/mount.h \
	sys/ioctl.h \
	sys/signal.h \
	sys/file.h \
	sys/fcntl.h \
	sys/time.h \
	sys/mman.h \
	sys/dir.h \
	sys/bitypes.h \
	sys/poll.h \
	sys/elf.h \
	sys/uio.h \
	sys/select.h \
	sys/soundcard.h \
	sys/sysmacros.h \
	sys/un.h \
	sys/socket.h \
	sys/times.h \
	sys/types.h \
	sys/byteorder.h \
	sys/wait.h \
	sys/gmon_out.h \
	sys/resource.h \
	sys/cdefs.h \
	sys/param.h \
	sys/errno.h \
	sys/timeb.h \
	sys/vfs.h \
	unixlib/buildoptions.h \
	unixlib/local.h \
	unixlib/types.h \
	string/byteswap.h \
	rpc/netdb.h \
	bits/netdb.h \
	bits/mathdef.h \
	bits/signum.h \
	bits/posix_opt.h \
	bits/mathcalls.h \
	bits/inf.h \
	bits/fenv.h \
	bits/huge_val.h \
	bits/wordsize.h \
	bits/socket.h \
	bits/sched.h \
	bits/locale.h \
	bits/wchar.h \
	bits/huge_vall.h \
	bits/in.h \
	bits/sockaddr.h \
	bits/byteswap.h \
	bits/huge_valf.h \
	bits/libc-lock.h \
	bits/nan.h \
	bits/cmathcalls.h \
	bits/mathinline.h \
	net/if.h \
	resolv/resolv.h \
	netinet/tcp.h \
	netinet/ip.h \
	netinet/udp.h \
	netinet/ip_icmp.h \
	netinet/in_systm.h \
	netinet/ip_var.h \
	netinet/in.h
libc_headers += unixlib/stubs.h

nobase_noinst_HEADERS = 	incl-local/memcopy.h \
	incl-local/pwd.h \
	incl-local/math_private.h \
	incl-local/unistd.h \
	incl-local/grp.h \
	incl-local/setjmp.h \
	incl-local/signal.h \
	incl-local/stdlib.h \
	incl-local/features.h \
	incl-local/time.h \
	incl-local/dirent.h \
	incl-local/locale.h \
	incl-local/stdio.h \
	incl-local/pthread.h \
	incl-local/errno.h \
	incl-local/sys/stat.h \
	incl-local/sys/debug.h \
	incl-local/sys/select.h \
	incl-local/sys/socket.h \
	incl-local/sys/cdefs.h \
	incl-local/internal/tty.h \
	incl-local/internal/swiparams.h \
	incl-local/internal/defines.h \
	incl-local/internal/local.h \
	incl-local/internal/dev.h \
	incl-local/internal/asm_dec.s \
	incl-local/internal/math.h \
	incl-local/internal/sigstate.h \
	incl-local/internal/machine-gmon.h \
	incl-local/internal/os.h \
	incl-local/internal/fd.h \
	incl-local/internal/symlinks.h \
	incl-local/internal/unix.h \
	incl-local/internal/elf-macros.s \
	incl-local/bits/netdb.h

libm_la_SOURCES = libm-support/libm.c

toolexeclib_LTLIBRARIES = libunixlib.la libm.la
libunixlib_la_SOURCES = $(grp_src) $(gcccompat_src) $(sched_src) $(fenv_src) \
	$(common_src) $(misc_src) $(pwd_src) $(locale_src) \
	$(stdio_src) $(libm_generic_src) $(gdtoa_src) $(sound_src) \
	$(signal_src) $(sys_src) $(ctype_src) $(string_src) \
	$(debug_src) $(scl_src) $(search_src) $(inttypes_src) \
	$(wchar_src) $(pthread_src) $(termios_src) $(resource_src) \
	$(assert_src) $(unix_src) $(stdlib_src) $(stat_src) \
	$(resolv_src) $(netlib_src) $(time_src) $(gmon_src) \
	$(unistd_src) $(libm_complex_src) $(libm_support_src) $(libm_dbl64_src) \
	$(libm_flt32_src) $(crypt_src) $(regexp_src) 

libunixlib_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,$(top_srcdir)/vscript

libm_la_LDFLAGS = -Wc,-nostdlib -version-info 1:0:0

if BUILDING_SCL
toolexeclib_DATA = crt0-scl.o
else
toolexeclib_DATA = crt0.o gcrt0.o
endif

crt0-scl.o: crt/crt0-scl.s
	$(CCASCOMPILE) -o crt0-scl.o -c `test -f 'crt/crt0-scl.s' || echo '$(srcdir)/'`crt/crt0-scl.s
crt0.o: crt/crt0.s
	$(CCASCOMPILE) -o crt0.o -c `test -f 'crt/crt0.s' || echo '$(srcdir)/'`crt/crt0.s
gcrt0.o: crt/gcrt0.s
	$(CCASCOMPILE) -o gcrt0.o -c `test -f 'crt/gcrt0.s' || echo '$(srcdir)/'`crt/gcrt0.s

# Build the SharedUnixLibrary module
bin_PROGRAMS = sul

sul.o: module/sul.s
	$(CCASCOMPILE) -o sul.o -c `test -f 'module/sul.s' || echo '$(srcdir)/'`module/sul.s

# The ARM linker cannot change output formats during the link
# stage.  We must use strip to convert the ELF binary into
# a raw binary
sul$(EXEEXT): sul.o
	$(STRIP) -O binary -o sul$(EXEEXT) sul.o

# These rules are copied direct from a generated Makefile.
# The only difference is that stack checking is turned off
# for these targets.
# Automake doesn't seem to provide a per-object file flag
# setting function.
brk.lo: sys/brk.c
	if $(LTCOMPILE) -Wc,-mno-apcs-stack-check \
	-MT brk.lo -MD -MP -MF "$(DEPDIR)/brk.Tpo" -c -o brk.lo \
	`test -f 'sys/brk.c' || echo '$(srcdir)/'`sys/brk.c; \
	then mv -f "$(DEPDIR)/brk.Tpo" "$(DEPDIR)/brk.Plo"; \
	else rm -f "$(DEPDIR)/brk.Tpo"; exit 1; fi

stackalloc.lo: sys/stackalloc.c
	if $(LTCOMPILE) -Wc,-mno-apcs-stack-check \
	-MT stackalloc.lo -MD -MP -MF "$(DEPDIR)/stackalloc.Tpo" -c -o stackalloc.lo \
	`test -f 'sys/stackalloc.c' || echo '$(srcdir)/'`sys/stackalloc.c; \
	then mv -f "$(DEPDIR)/stackalloc.Tpo" "$(DEPDIR)/stackalloc.Plo"; \
	else rm -f "$(DEPDIR)/stackalloc.Tpo"; exit 1; fi

dvsprintf.lo: debug/dvsprintf.c
	if $(LTCOMPILE) -Wc,-mno-apcs-stack-check \
	-MT dvsprintf.lo -MD -MP -MF "$(DEPDIR)/dvsprintf.Tpo" -c -o dvsprintf.lo \
	`test -f 'debug/dvsprintf.c' || echo '$(srcdir)/'`debug/dvsprintf.c; \
	then mv -f "$(DEPDIR)/dvsprintf.Tpo" "$(DEPDIR)/dvsprintf.Plo"; \
	else rm -f "$(DEPDIR)/dvsprintf.Tpo"; exit 1; fi

install-data-local: install-headers

install-headers:
	$(mkinstalldirs) $(DESTDIR)${tooldir}/include
	for dir in arpa bits net netinet resolv rpc string sys unixlib; do \
	  $(mkinstalldirs) $(DESTDIR)${tooldir}/include/$${dir} ; done
	for file in ${libc_headers}; do \
	  $(INSTALL_DATA) $(srcdir)/include/$${file} $(DESTDIR)${tooldir}/include/$${file} ; done

