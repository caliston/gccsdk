#ifndef lint
static char const 
yyrcsid[] = "$FreeBSD: src/usr.bin/yacc/skeleton.c,v 1.28 2000/01/17 02:04:06 bde Exp $";
#endif
#include <stdlib.h>
#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYLEX yylex()
#define YYEMPTY -1
#define yyclearin (yychar=(YYEMPTY))
#define yyerrok (yyerrflag=0)
#define YYRECOVERING() (yyerrflag!=0)
static int yygrowstack();
#define YYPREFIX "yy"
#line 28 "../cexp.y"
#include "config.h"

#include "system.h"
#include "intl.h"
#include <setjmp.h>
/* #define YYDEBUG 1 */

#ifdef MULTIBYTE_CHARS
#include "mbchar.h"
#include <locale.h>
#endif /* MULTIBYTE_CHARS */

typedef unsigned char U_CHAR;

/* This is used for communicating lists of keywords with cccp.c.  */
struct arglist {
  struct arglist *next;
  U_CHAR *name;
  int length;
  int argno;
};

HOST_WIDEST_INT parse_c_expression PROTO((char *, int));

static int yylex PROTO((void));
static void yyerror PVPROTO((const char *, ...))
  ATTRIBUTE_PRINTF_1 ATTRIBUTE_NORETURN;
static HOST_WIDEST_INT expression_value;
#ifdef TEST_EXP_READER
static int expression_signedp;
#endif

static jmp_buf parse_return_error;

/* Nonzero means count most punctuation as part of a name.  */
static int keyword_parsing = 0;

/* Nonzero means do not evaluate this expression.
   This is a count, since unevaluated expressions can nest.  */
static int skip_evaluation;

/* Nonzero means warn if undefined identifiers are evaluated.  */
static int warn_undef;

/* some external tables of character types */
extern unsigned char is_idstart[], is_idchar[], is_space[];

/* Flag for -pedantic.  */
extern int pedantic;

/* Flag for -traditional.  */
extern int traditional;

/* Flag for -lang-c89.  */
extern int c89;

#ifndef CHAR_TYPE_SIZE
#define CHAR_TYPE_SIZE BITS_PER_UNIT
#endif

#ifndef INT_TYPE_SIZE
#define INT_TYPE_SIZE BITS_PER_WORD
#endif

#ifndef LONG_TYPE_SIZE
#define LONG_TYPE_SIZE BITS_PER_WORD
#endif

#ifndef WCHAR_TYPE_SIZE
#define WCHAR_TYPE_SIZE INT_TYPE_SIZE
#endif

#ifndef MAX_CHAR_TYPE_SIZE
#define MAX_CHAR_TYPE_SIZE CHAR_TYPE_SIZE
#endif

#ifndef MAX_INT_TYPE_SIZE
#define MAX_INT_TYPE_SIZE INT_TYPE_SIZE
#endif

#ifndef MAX_LONG_TYPE_SIZE
#define MAX_LONG_TYPE_SIZE LONG_TYPE_SIZE
#endif

#ifndef MAX_WCHAR_TYPE_SIZE
#define MAX_WCHAR_TYPE_SIZE WCHAR_TYPE_SIZE
#endif

#define MAX_CHAR_TYPE_MASK (MAX_CHAR_TYPE_SIZE < HOST_BITS_PER_WIDEST_INT \
			    ? (~ (~ (HOST_WIDEST_INT) 0 << MAX_CHAR_TYPE_SIZE)) \
			    : ~ (HOST_WIDEST_INT) 0)

#define MAX_WCHAR_TYPE_MASK (MAX_WCHAR_TYPE_SIZE < HOST_BITS_PER_WIDEST_INT \
			     ? ~ (~ (HOST_WIDEST_INT) 0 << MAX_WCHAR_TYPE_SIZE) \
			     : ~ (HOST_WIDEST_INT) 0)

/* Suppose A1 + B1 = SUM1, using 2's complement arithmetic ignoring overflow.
   Suppose A, B and SUM have the same respective signs as A1, B1, and SUM1.
   Suppose SIGNEDP is negative if the result is signed, zero if unsigned.
   Then this yields nonzero if overflow occurred during the addition.
   Overflow occurs if A and B have the same sign, but A and SUM differ in sign,
   and SIGNEDP is negative.
   Use `^' to test whether signs differ, and `< 0' to isolate the sign.  */
#define overflow_sum_sign(a, b, sum, signedp) \
	((~((a) ^ (b)) & ((a) ^ (sum)) & (signedp)) < 0)

struct constant;

HOST_WIDEST_INT parse_escape PROTO((char **, HOST_WIDEST_INT));
int check_assertion PROTO((U_CHAR *, int, int, struct arglist *));
struct hashnode *lookup PROTO((U_CHAR *, int, int));
void error PVPROTO((const char *, ...)) ATTRIBUTE_PRINTF_1;
void verror PROTO((const char *, va_list));
void pedwarn PVPROTO((const char *, ...)) ATTRIBUTE_PRINTF_1;
void warning PVPROTO((const char *, ...)) ATTRIBUTE_PRINTF_1;

static int parse_number PROTO((int));
static HOST_WIDEST_INT left_shift PROTO((struct constant *, unsigned HOST_WIDEST_INT));
static HOST_WIDEST_INT right_shift PROTO((struct constant *, unsigned HOST_WIDEST_INT));
static void integer_overflow PROTO((void));

/* `signedp' values */
#define SIGNED (~0)
#define UNSIGNED 0
#line 154 "../cexp.y"
typedef union {
  struct constant {HOST_WIDEST_INT value; int signedp;} integer;
  struct name {U_CHAR *address; int length;} name;
  struct arglist *keywords;
} YYSTYPE;
#line 148 "y.tab.c"
#define YYERRCODE 256
#define INT 257
#define CHAR 258
#define NAME 259
#define ERROR 260
#define OR 261
#define AND 262
#define EQUAL 263
#define NOTEQUAL 264
#define LEQ 265
#define GEQ 266
#define LSH 267
#define RSH 268
#define UNARY 269
const short yylhs[] = {                                        -1,
    0,    2,    2,    1,    1,    1,    1,    1,    4,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    5,    1,    6,
    1,    7,    8,    1,    1,    1,    1,    3,    3,    3,
};
const short yylen[] = {                                         2,
    1,    1,    3,    2,    2,    2,    2,    2,    0,    6,
    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
    3,    3,    3,    3,    3,    3,    3,    0,    4,    0,
    4,    0,    0,    7,    1,    1,    1,    0,    4,    2,
};
const short yydefred[] = {                                      0,
   35,   36,   37,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    6,    4,    5,    7,    0,    0,   32,   30,
   28,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   11,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   12,   13,   14,    0,
    0,    0,    0,    0,    0,    0,    0,   33,   40,    0,
   10,    0,    0,    0,   39,
};
const short yydgoto[] = {                                      10,
   11,   12,   67,   39,   43,   42,   41,   72,
};
const short yysindex[] = {                                    168,
    0,    0,    0,  168,  168,  168,  168, -255,  168,    0,
  287,  -39,    0,    0,    0,    0,    0,  -23,    0,    0,
    0,  168,  168,  168,  168,  168,  168,  168,  168,  168,
  168,  168,  168,  168,  168,  168,  168,  168,  -34,    0,
  168,  168,  168,  449,  -30,  271,  463,  463,  -14,  -14,
  -14,  -14,   63,   63,   74,   74,    0,    0,    0,  287,
  -40,  395,  409,  435,  -40,  -40,  -22,    0,    0,  -21,
    0,  168,  -40,  287,    0,
};
const short yyrindex[] = {                                      0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   14,   11,    0,    0,    0,    0,    1,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  188,   49,  366,  158,  320,   91,  124,
  131,  307,   24,   76,    9,   36,    0,    0,    0,   16,
  -19,    0,  101,   34,  -19,  -19,    0,    0,    0,    0,
    0,    0,  -19,  122,    0,
};
const short yygindex[] = {                                      0,
  570,   17,  -63,    0,    0,    0,    0,    0,
};
#define YYTABLESIZE 731
const short yytable[] = {                                      66,
    8,   69,   70,   17,   38,   61,   37,   24,   15,   75,
    1,   35,   33,    2,   34,    3,   36,   40,   71,   73,
   38,   38,   37,   17,    0,   18,    0,   35,   33,   27,
   34,   28,   36,   29,    0,   16,    0,    8,    8,    0,
    9,    8,    8,    8,    8,    8,   15,    8,   26,   15,
    0,   15,   15,   15,    2,    0,    3,    2,    8,    3,
    8,   17,    8,    8,   17,    0,   15,   17,   15,    0,
   15,   15,    0,   16,   29,   18,   16,   29,   16,   16,
   16,   17,    0,   17,    0,   17,   17,    0,    0,   26,
   23,   29,   26,   16,    8,   16,   29,   16,   16,   37,
   31,    0,   15,    0,   35,   33,   26,   34,    0,   36,
   37,   26,    0,   18,    0,   35,   18,   17,    0,   18,
   36,   34,    0,   24,    8,    0,    0,    0,   23,   16,
   21,   23,   15,   18,   23,   18,    0,   18,   18,    0,
    0,   31,   26,    0,   31,    0,    0,   17,   23,    0,
   23,    0,   23,   23,    0,    0,    0,   19,   31,   16,
    0,   24,   34,   31,   24,   34,    0,   24,   21,   18,
    0,   21,   26,    0,   21,    0,    0,    0,    0,   34,
    0,   24,    0,   24,   23,   24,   24,   27,   21,    0,
   21,    0,   21,   21,    0,   19,    0,    0,   19,   18,
    6,   19,    8,    0,    0,    0,    0,    9,    0,    0,
    4,    0,    5,    0,   23,   19,    0,   24,   65,    0,
   19,    0,    0,    0,   21,    0,    0,    0,   27,    0,
    0,   27,   25,   26,   29,   30,   31,   32,    0,    0,
    0,    0,    0,    0,    0,   27,    0,   24,    0,    0,
   27,   19,   31,   32,   21,    0,    0,    0,    0,    0,
    0,    8,    8,    8,    8,    8,    8,    8,    8,   15,
   15,   15,   15,   15,   15,   15,   15,    0,    0,    0,
    0,   19,    0,    0,   17,   17,   17,   17,   17,   17,
   17,   17,    0,    7,   29,   29,   16,   16,   16,   16,
   16,   16,   16,   16,    0,    0,   22,   37,    0,   26,
   26,   27,   35,   33,    0,   34,    0,   36,    0,   20,
    0,    0,    0,   37,   24,    0,    0,    0,   35,   33,
   27,   34,   28,   36,    0,    0,   18,   18,   18,   18,
   18,   18,   18,   18,   22,    0,   27,   22,   28,   19,
   22,   23,   23,   23,   23,   23,   23,   20,    0,    0,
   20,   31,    0,   20,   22,   25,   22,    0,   22,   22,
    0,    0,    0,    0,    0,    0,    0,   20,    0,    0,
   23,    0,   20,    0,   24,   24,   24,   24,   24,   24,
    0,   21,   21,   21,   21,   21,   21,    0,    0,    0,
   22,    0,    0,   25,    0,    0,   25,    0,    0,   25,
   22,    0,    0,   20,    0,    0,    0,    0,   19,   19,
   19,   19,    0,   25,    1,    2,    3,    0,   25,    0,
   22,   37,   24,    0,    0,    0,   35,   33,    0,   34,
    0,   36,    0,   20,    0,   37,   24,    0,   27,   27,
   35,   33,   68,   34,   27,   36,   28,   19,    0,   25,
    0,    0,    0,    0,    0,    0,    0,    0,   27,    0,
   28,   37,   24,    0,    0,    0,   35,   33,    0,   34,
    0,   36,    0,    0,    0,   37,   24,    0,   23,   25,
   35,   33,    0,   34,   27,   36,   28,    0,    0,   37,
    0,    0,   23,    0,   35,   33,    0,   34,   27,   36,
   28,    0,    0,    0,    0,    0,    0,    0,   22,    0,
    0,    0,   27,    0,   28,    0,    0,    0,   23,    0,
    0,    0,   22,   25,   26,   29,   30,   31,   32,    0,
    0,    0,   23,    0,    0,    0,    0,   20,   21,   25,
   26,   29,   30,   31,   32,    0,    0,    0,   22,    0,
    0,    0,    0,    0,    0,    0,    0,   22,   22,   22,
   22,   22,   22,   13,   14,   15,   16,    0,    0,    0,
   20,   20,   20,   20,    0,    0,    0,    0,    0,    0,
    0,   44,   45,   46,   47,   48,   49,   50,   51,   52,
   53,   54,   55,   56,   57,   58,   59,   60,    0,    0,
   62,   63,   64,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   25,   25,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   74,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   20,   21,   25,   26,   29,
   30,   31,   32,    0,    0,    0,    0,    0,    0,    0,
   21,   25,   26,   29,   30,   31,   32,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   25,   26,   29,
   30,   31,   32,    0,    0,    0,    0,    0,    0,    0,
    0,   25,   26,   29,   30,   31,   32,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   29,   30,   31,
   32,
};
const short yycheck[] = {                                      40,
    0,   65,   66,  259,   44,   40,   37,   38,    0,   73,
    0,   42,   43,    0,   45,    0,   47,   41,   41,   41,
   44,   41,   37,    0,   -1,    9,   -1,   42,   43,   60,
   45,   62,   47,    0,   -1,    0,   -1,   37,   38,   -1,
   40,   41,   42,   43,   44,   45,   38,   47,    0,   41,
   -1,   43,   44,   45,   41,   -1,   41,   44,   58,   44,
   60,   38,   62,   63,   41,   -1,   58,   44,   60,   -1,
   62,   63,   -1,   38,   41,    0,   41,   44,   43,   44,
   45,   58,   -1,   60,   -1,   62,   63,   -1,   -1,   41,
    0,   58,   44,   58,   94,   60,   63,   62,   63,   37,
    0,   -1,   94,   -1,   42,   43,   58,   45,   -1,   47,
   37,   63,   -1,   38,   -1,   42,   41,   94,   -1,   44,
   47,    0,   -1,    0,  124,   -1,   -1,   -1,   38,   94,
    0,   41,  124,   58,   44,   60,   -1,   62,   63,   -1,
   -1,   41,   94,   -1,   44,   -1,   -1,  124,   58,   -1,
   60,   -1,   62,   63,   -1,   -1,   -1,    0,   58,  124,
   -1,   38,   41,   63,   41,   44,   -1,   44,   38,   94,
   -1,   41,  124,   -1,   44,   -1,   -1,   -1,   -1,   58,
   -1,   58,   -1,   60,   94,   62,   63,    0,   58,   -1,
   60,   -1,   62,   63,   -1,   38,   -1,   -1,   41,  124,
   33,   44,   35,   -1,   -1,   -1,   -1,   40,   -1,   -1,
   43,   -1,   45,   -1,  124,   58,   -1,   94,  259,   -1,
   63,   -1,   -1,   -1,   94,   -1,   -1,   -1,   41,   -1,
   -1,   44,  263,  264,  265,  266,  267,  268,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   58,   -1,  124,   -1,   -1,
   63,   94,  267,  268,  124,   -1,   -1,   -1,   -1,   -1,
   -1,  261,  262,  263,  264,  265,  266,  267,  268,  261,
  262,  263,  264,  265,  266,  267,  268,   -1,   -1,   -1,
   -1,  124,   -1,   -1,  261,  262,  263,  264,  265,  266,
  267,  268,   -1,  126,  261,  262,  261,  262,  263,  264,
  265,  266,  267,  268,   -1,   -1,    0,   37,   -1,  261,
  262,  124,   42,   43,   -1,   45,   -1,   47,   -1,    0,
   -1,   -1,   -1,   37,   38,   -1,   -1,   -1,   42,   43,
   60,   45,   62,   47,   -1,   -1,  261,  262,  263,  264,
  265,  266,  267,  268,   38,   -1,   60,   41,   62,   63,
   44,  261,  262,  263,  264,  265,  266,   38,   -1,   -1,
   41,  261,   -1,   44,   58,    0,   60,   -1,   62,   63,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   58,   -1,   -1,
   94,   -1,   63,   -1,  261,  262,  263,  264,  265,  266,
   -1,  261,  262,  263,  264,  265,  266,   -1,   -1,   -1,
   94,   -1,   -1,   38,   -1,   -1,   41,   -1,   -1,   44,
  124,   -1,   -1,   94,   -1,   -1,   -1,   -1,  261,  262,
  263,  264,   -1,   58,  257,  258,  259,   -1,   63,   -1,
  124,   37,   38,   -1,   -1,   -1,   42,   43,   -1,   45,
   -1,   47,   -1,  124,   -1,   37,   38,   -1,  261,  262,
   42,   43,   58,   45,   60,   47,   62,   63,   -1,   94,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   60,   -1,
   62,   37,   38,   -1,   -1,   -1,   42,   43,   -1,   45,
   -1,   47,   -1,   -1,   -1,   37,   38,   -1,   94,  124,
   42,   43,   -1,   45,   60,   47,   62,   -1,   -1,   37,
   -1,   -1,   94,   -1,   42,   43,   -1,   45,   60,   47,
   62,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  124,   -1,
   -1,   -1,   60,   -1,   62,   -1,   -1,   -1,   94,   -1,
   -1,   -1,  124,  263,  264,  265,  266,  267,  268,   -1,
   -1,   -1,   94,   -1,   -1,   -1,   -1,  261,  262,  263,
  264,  265,  266,  267,  268,   -1,   -1,   -1,  124,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  261,  262,  263,
  264,  265,  266,    4,    5,    6,    7,   -1,   -1,   -1,
  261,  262,  263,  264,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   22,   23,   24,   25,   26,   27,   28,   29,   30,
   31,   32,   33,   34,   35,   36,   37,   38,   -1,   -1,
   41,   42,   43,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  261,  262,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   72,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  261,  262,  263,  264,  265,
  266,  267,  268,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  262,  263,  264,  265,  266,  267,  268,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  263,  264,  265,
  266,  267,  268,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  263,  264,  265,  266,  267,  268,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  265,  266,  267,
  268,
};
#define YYFINAL 10
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 269
#if YYDEBUG
const char * const yyname[] = {
"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
"'!'",0,"'#'",0,"'%'","'&'",0,"'('","')'","'*'","'+'","','","'-'",0,"'/'",0,0,0,
0,0,0,0,0,0,0,"':'",0,"'<'",0,"'>'","'?'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,"'^'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,"'|'",0,"'~'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"INT","CHAR","NAME","ERROR","OR","AND",
"EQUAL","NOTEQUAL","LEQ","GEQ","LSH","RSH","UNARY",
};
const char * const yyrule[] = {
"$accept : start",
"start : exp1",
"exp1 : exp",
"exp1 : exp1 ',' exp",
"exp : '-' exp",
"exp : '!' exp",
"exp : '+' exp",
"exp : '~' exp",
"exp : '#' NAME",
"$$1 :",
"exp : '#' NAME $$1 '(' keywords ')'",
"exp : '(' exp1 ')'",
"exp : exp '*' exp",
"exp : exp '/' exp",
"exp : exp '%' exp",
"exp : exp '+' exp",
"exp : exp '-' exp",
"exp : exp LSH exp",
"exp : exp RSH exp",
"exp : exp EQUAL exp",
"exp : exp NOTEQUAL exp",
"exp : exp LEQ exp",
"exp : exp GEQ exp",
"exp : exp '<' exp",
"exp : exp '>' exp",
"exp : exp '&' exp",
"exp : exp '^' exp",
"exp : exp '|' exp",
"$$2 :",
"exp : exp AND $$2 exp",
"$$3 :",
"exp : exp OR $$3 exp",
"$$4 :",
"$$5 :",
"exp : exp '?' $$4 exp ':' $$5 exp",
"exp : INT",
"exp : CHAR",
"exp : NAME",
"keywords :",
"keywords : '(' keywords ')' keywords",
"keywords : NAME keywords",
};
#endif
#if YYDEBUG
#include <stdio.h>
#endif
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH 10000
#endif
#endif
#define YYINITSTACKSIZE 200
int yydebug;
int yynerrs;
int yyerrflag;
int yychar;
short *yyssp;
YYSTYPE *yyvsp;
YYSTYPE yyval;
YYSTYPE yylval;
short *yyss;
short *yysslim;
YYSTYPE *yyvs;
int yystacksize;
#line 395 "../cexp.y"

/* During parsing of a C expression, the pointer to the next character
   is in this variable.  */

static char *lexptr;

/* Take care of parsing a number (anything that starts with a digit).
   Set yylval and return the token type; update lexptr.
   LEN is the number of characters in it.  */

/* maybe needs to actually deal with floating point numbers */

static int
parse_number (olen)
     int olen;
{
  register char *p = lexptr;
  register int c;
  register unsigned HOST_WIDEST_INT n = 0, nd, max_over_base;
  register int base = 10;
  register int len = olen;
  register int overflow = 0;
  register int digit, largest_digit = 0;
  int spec_long = 0;

  yylval.integer.signedp = SIGNED;

  if (*p == '0') {
    base = 8;
    if (len >= 3 && (p[1] == 'x' || p[1] == 'X')) {
      p += 2;
      base = 16;
      len -= 2;
    }
  }

  max_over_base = (unsigned HOST_WIDEST_INT) -1 / base;

  for (; len > 0; len--) {
    c = *p++;

    if (c >= '0' && c <= '9')
      digit = c - '0';
    else if (base == 16 && c >= 'a' && c <= 'f')
      digit = c - 'a' + 10;
    else if (base == 16 && c >= 'A' && c <= 'F')
      digit = c - 'A' + 10;
    else {
      /* `l' means long, and `u' means unsigned.  */
      while (1) {
	if (c == 'l' || c == 'L')
	  {
	    if (!pedantic < spec_long)
	      yyerror ("too many `l's in integer constant");
	    spec_long++;
	  }
	else if (c == 'u' || c == 'U')
	  {
	    if (! yylval.integer.signedp)
	      yyerror ("two `u's in integer constant");
	    yylval.integer.signedp = UNSIGNED;
	  }
	else {
	  if (c == '.' || c == 'e' || c == 'E' || c == 'p' || c == 'P')
	    yyerror ("Floating point numbers not allowed in #if expressions");
	  else
	    yyerror ("missing white space after number `%.*s'",
		     (int) (p - lexptr - 1), lexptr);
	}

	if (--len == 0)
	  break;
	c = *p++;
      }
      /* Don't look for any more digits after the suffixes.  */
      break;
    }
    if (largest_digit < digit)
      largest_digit = digit;
    nd = n * base + digit;
    overflow |= (max_over_base < n) | (nd < n);
    n = nd;
  }

  if (base <= largest_digit)
    pedwarn ("integer constant contains digits beyond the radix");

  if (overflow)
    pedwarn ("integer constant out of range");

  /* If too big to be signed, consider it unsigned.  */
  if (((HOST_WIDEST_INT) n & yylval.integer.signedp) < 0)
    {
      if (base == 10)
	warning ("integer constant is so large that it is unsigned");
      yylval.integer.signedp = UNSIGNED;
    }

  lexptr = p;
  yylval.integer.value = n;
  return INT;
}

struct token {
  const char *operator;
  int token;
};

static struct token tokentab2[] = {
  {"&&", AND},
  {"||", OR},
  {"<<", LSH},
  {">>", RSH},
  {"==", EQUAL},
  {"!=", NOTEQUAL},
  {"<=", LEQ},
  {">=", GEQ},
  {"++", ERROR},
  {"--", ERROR},
  {NULL, ERROR}
};

/* Read one token, getting characters through lexptr.  */

static int
yylex ()
{
  register int c;
  register int namelen;
  register unsigned char *tokstart;
  register struct token *toktab;
  int wide_flag;
  HOST_WIDEST_INT mask;

 retry:

  tokstart = (unsigned char *) lexptr;
  c = *tokstart;
  /* See if it is a special token of length 2.  */
  if (! keyword_parsing)
    for (toktab = tokentab2; toktab->operator != NULL; toktab++)
      if (c == *toktab->operator && tokstart[1] == toktab->operator[1]) {
	lexptr += 2;
	if (toktab->token == ERROR)
	  yyerror ("`%s' not allowed in operand of `#if'", toktab->operator);
	return toktab->token;
      }

  switch (c) {
  case '\n':
    return 0;
    
  case ' ':
  case '\t':
  case '\r':
    lexptr++;
    goto retry;
    
  case 'L':
    /* Capital L may start a wide-string or wide-character constant.  */
    if (lexptr[1] == '\'')
      {
	lexptr++;
	wide_flag = 1;
	mask = MAX_WCHAR_TYPE_MASK;
	goto char_constant;
      }
    if (lexptr[1] == '"')
      {
	lexptr++;
	wide_flag = 1;
	mask = MAX_WCHAR_TYPE_MASK;
	goto string_constant;
      }
    break;

  case '\'':
    wide_flag = 0;
    mask = MAX_CHAR_TYPE_MASK;
  char_constant:
    lexptr++;
    if (keyword_parsing) {
      char *start_ptr = lexptr - 1;
      while (1) {
	c = *lexptr++;
	if (c == '\\')
	  c = parse_escape (&lexptr, mask);
	else if (c == '\'')
	  break;
      }
      yylval.name.address = tokstart;
      yylval.name.length = lexptr - start_ptr;
      return NAME;
    }

    /* This code for reading a character constant
       handles multicharacter constants and wide characters.
       It is mostly copied from c-lex.c.  */
    {
      register HOST_WIDEST_INT result = 0;
      register int num_chars = 0;
      int chars_seen = 0;
      unsigned width = MAX_CHAR_TYPE_SIZE;
      int max_chars;
#ifdef MULTIBYTE_CHARS
      int longest_char = local_mb_cur_max ();
      char *token_buffer = (char *) alloca (longest_char);
      (void) local_mbtowc (NULL_PTR, NULL_PTR, 0);
#endif

      max_chars = MAX_LONG_TYPE_SIZE / width;
      if (wide_flag)
	width = MAX_WCHAR_TYPE_SIZE;

      while (1)
	{
	  c = *lexptr++;

	  if (c == '\'' || c == EOF)
	    break;

	  ++chars_seen;
	  if (c == '\\')
	    {
	      c = parse_escape (&lexptr, mask);
	    }
	  else
	    {
#ifdef MULTIBYTE_CHARS
	      wchar_t wc;
	      int i;
	      int char_len = -1;
	      for (i = 1; i <= longest_char; ++i)
		{
		  token_buffer[i - 1] = c;
		  char_len = local_mbtowc (& wc, token_buffer, i);
		  if (char_len != -1)
		    break;
		  c = *lexptr++;
		}
	      if (char_len > 1)
		{
		  /* mbtowc sometimes needs an extra char before accepting */
		  if (char_len < i)
		    lexptr--;
		  if (! wide_flag)
		    {
		      /* Merge character into result; ignore excess chars.  */
		      for (i = 1; i <= char_len; ++i)
			{
			  if (i > max_chars)
			    break;
			  if (width < HOST_BITS_PER_INT)
			    result = (result << width)
			      | (token_buffer[i - 1]
				 & ((1 << width) - 1));
			  else
			    result = token_buffer[i - 1];
			}
		      num_chars += char_len;
		      continue;
		    }
		}
	      else
		{
		  if (char_len == -1)
		    warning ("Ignoring invalid multibyte character");
		}
	      if (wide_flag)
		c = wc;
#endif /* ! MULTIBYTE_CHARS */
	    }

	  if (wide_flag)
	    {
	      if (chars_seen == 1) /* only keep the first one */
		result = c;
	      continue;
	    }

	  /* Merge character into result; ignore excess chars.  */
	  num_chars++;
	  if (num_chars <= max_chars)
	    {
	      if (width < HOST_BITS_PER_INT)
		result = (result << width) | (c & ((1 << width) - 1));
	      else
		result = c;
	    }
	}

      if (c != '\'')
	error ("malformatted character constant");
      else if (chars_seen == 0)
	error ("empty character constant");
      else if (num_chars > max_chars)
	{
	  num_chars = max_chars;
	  error ("character constant too long");
	}
      else if (chars_seen != 1 && ! traditional)
	warning ("multi-character character constant");

      /* If char type is signed, sign-extend the constant.  */
      if (! wide_flag)
	{
	  int num_bits = num_chars * width;
	  if (num_bits == 0)
	    /* We already got an error; avoid invalid shift.  */
	    yylval.integer.value = 0;
	  else if (lookup ((U_CHAR *) "__CHAR_UNSIGNED__",
		      sizeof ("__CHAR_UNSIGNED__") - 1, -1)
	      || ((result >> (num_bits - 1)) & 1) == 0)
	    yylval.integer.value
	      = result & (~ (unsigned HOST_WIDEST_INT) 0
			  >> (HOST_BITS_PER_WIDEST_INT - num_bits));
	  else
	    yylval.integer.value
	      = result | ~(~ (unsigned HOST_WIDEST_INT) 0
			   >> (HOST_BITS_PER_WIDEST_INT - num_bits));
	}
      else
	{
	  yylval.integer.value = result;
	}
    }

    /* This is always a signed type.  */
    yylval.integer.signedp = SIGNED;
    
    return CHAR;

    /* some of these chars are invalid in constant expressions;
       maybe do something about them later */
  case '/':
  case '+':
  case '-':
  case '*':
  case '%':
  case '|':
  case '&':
  case '^':
  case '~':
  case '!':
  case '@':
  case '<':
  case '>':
  case '[':
  case ']':
  case '.':
  case '?':
  case ':':
  case '=':
  case '{':
  case '}':
  case ',':
  case '#':
    if (keyword_parsing)
      break;
  case '(':
  case ')':
    lexptr++;
    return c;

  case '"':
    mask = MAX_CHAR_TYPE_MASK;
  string_constant:
    if (keyword_parsing) {
      char *start_ptr = lexptr;
      lexptr++;
      while (1) {
	c = *lexptr++;
	if (c == '\\')
	  c = parse_escape (&lexptr, mask);
	else if (c == '"')
	  break;
      }
      yylval.name.address = tokstart;
      yylval.name.length = lexptr - start_ptr;
      return NAME;
    }
    yyerror ("string constants not allowed in #if expressions");
    return ERROR;
  }

  if (c >= '0' && c <= '9' && !keyword_parsing) {
    /* It's a number */
    for (namelen = 1; ; namelen++) {
      int d = tokstart[namelen];
      if (! ((is_idchar[d] || d == '.')
	     || ((d == '-' || d == '+')
		 && (c == 'e' || c == 'E'
		     || ((c == 'p' || c == 'P') && ! c89))
		 && ! traditional)))
	break;
      c = d;
    }
    return parse_number (namelen);
  }

  /* It is a name.  See how long it is.  */

  if (keyword_parsing) {
    for (namelen = 0;; namelen++) {
      if (is_space[tokstart[namelen]])
	break;
      if (tokstart[namelen] == '(' || tokstart[namelen] == ')')
	break;
      if (tokstart[namelen] == '"' || tokstart[namelen] == '\'')
	break;
    }
  } else {
    if (!is_idstart[c]) {
      yyerror ("Invalid token in expression");
      return ERROR;
    }

    for (namelen = 0; is_idchar[tokstart[namelen]]; namelen++)
      ;
  }
  
  lexptr += namelen;
  yylval.name.address = tokstart;
  yylval.name.length = namelen;
  return NAME;
}


/* Parse a C escape sequence.  STRING_PTR points to a variable
   containing a pointer to the string to parse.  That pointer
   is updated past the characters we use.  The value of the
   escape sequence is returned.

   RESULT_MASK is used to mask out the result;
   an error is reported if bits are lost thereby.

   A negative value means the sequence \ newline was seen,
   which is supposed to be equivalent to nothing at all.

   If \ is followed by a null character, we return a negative
   value and leave the string pointer pointing at the null character.

   If \ is followed by 000, we return 0 and leave the string pointer
   after the zeros.  A value of 0 does not mean end of string.  */

HOST_WIDEST_INT
parse_escape (string_ptr, result_mask)
     char **string_ptr;
     HOST_WIDEST_INT result_mask;
{
  register int c = *(*string_ptr)++;
  switch (c)
    {
    case 'a':
      return TARGET_BELL;
    case 'b':
      return TARGET_BS;
    case 'e':
    case 'E':
      if (pedantic)
	pedwarn ("non-ANSI-standard escape sequence, `\\%c'", c);
      return 033;
    case 'f':
      return TARGET_FF;
    case 'n':
      return TARGET_NEWLINE;
    case 'r':
      return TARGET_CR;
    case 't':
      return TARGET_TAB;
    case 'v':
      return TARGET_VT;
    case '\n':
      return -2;
    case 0:
      (*string_ptr)--;
      return 0;
      
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
      {
	register HOST_WIDEST_INT i = c - '0';
	register int count = 0;
	while (++count < 3)
	  {
	    c = *(*string_ptr)++;
	    if (c >= '0' && c <= '7')
	      i = (i << 3) + c - '0';
	    else
	      {
		(*string_ptr)--;
		break;
	      }
	  }
	if (i != (i & result_mask))
	  {
	    i &= result_mask;
	    pedwarn ("octal escape sequence out of range");
	  }
	return i;
      }
    case 'x':
      {
	register unsigned HOST_WIDEST_INT i = 0, overflow = 0;
	register int digits_found = 0, digit;
	for (;;)
	  {
	    c = *(*string_ptr)++;
	    if (c >= '0' && c <= '9')
	      digit = c - '0';
	    else if (c >= 'a' && c <= 'f')
	      digit = c - 'a' + 10;
	    else if (c >= 'A' && c <= 'F')
	      digit = c - 'A' + 10;
	    else
	      {
		(*string_ptr)--;
		break;
	      }
	    overflow |= i ^ (i << 4 >> 4);
	    i = (i << 4) + digit;
	    digits_found = 1;
	  }
	if (!digits_found)
	  yyerror ("\\x used with no following hex digits");
	if (overflow | (i != (i & result_mask)))
	  {
	    i &= result_mask;
	    pedwarn ("hex escape sequence out of range");
	  }
	return i;
      }
    default:
      return c;
    }
}

static void
integer_overflow ()
{
  if (!skip_evaluation && pedantic)
    pedwarn ("integer overflow in preprocessor expression");
}

static HOST_WIDEST_INT
left_shift (a, b)
     struct constant *a;
     unsigned HOST_WIDEST_INT b;
{
   /* It's unclear from the C standard whether shifts can overflow.
      The following code ignores overflow; perhaps a C standard
      interpretation ruling is needed.  */
  if (b >= HOST_BITS_PER_WIDEST_INT)
    return 0;
  else
    return (unsigned HOST_WIDEST_INT) a->value << b;
}

static HOST_WIDEST_INT
right_shift (a, b)
     struct constant *a;
     unsigned HOST_WIDEST_INT b;
{
  if (b >= HOST_BITS_PER_WIDEST_INT)
    return a->signedp ? a->value >> (HOST_BITS_PER_WIDEST_INT - 1) : 0;
  else if (a->signedp)
    return a->value >> b;
  else
    return (unsigned HOST_WIDEST_INT) a->value >> b;
}

/* This page contains the entry point to this file.  */

/* Parse STRING as an expression, and complain if this fails
   to use up all of the contents of STRING.
   STRING may contain '\0' bytes; it is terminated by the first '\n'
   outside a string constant, so that we can diagnose '\0' properly.
   If WARN_UNDEFINED is nonzero, warn if undefined identifiers are evaluated.
   We do not support C comments.  They should be removed before
   this function is called.  */

HOST_WIDEST_INT
parse_c_expression (string, warn_undefined)
     char *string;
     int warn_undefined;
{
  lexptr = string;
  warn_undef = warn_undefined;

  /* if there is some sort of scanning error, just return 0 and assume
     the parsing routine has printed an error message somewhere.
     there is surely a better thing to do than this.     */
  if (setjmp (parse_return_error))
    return 0;

  if (yyparse () != 0)
    abort ();

  if (*lexptr != '\n')
    error ("Junk after end of expression.");

  return expression_value;	/* set by yyparse () */
}

static void
yyerror VPROTO ((const char * msgid, ...))
{
#ifndef ANSI_PROTOTYPES
  const char * msgid;
#endif
  va_list args;

  VA_START (args, msgid);

#ifndef ANSI_PROTOTYPES
  msgid = va_arg (args, const char *);
#endif

  verror (msgid, args);
  va_end (args);
  skip_evaluation = 0;
  longjmp (parse_return_error, 1);
}


#ifdef TEST_EXP_READER

#if YYDEBUG
extern int yydebug;
#endif

int pedantic;
int traditional;
int c89;

int main PROTO((int, char **));
static void initialize_random_junk PROTO((void));
static void print_unsigned_host_widest_int PROTO((unsigned HOST_WIDEST_INT));

/* Main program for testing purposes.  */
int
main (argc, argv)
     int argc;
     char **argv;
{
  int n, c;
  char buf[1024];
  unsigned HOST_WIDEST_INT u;

  pedantic = 1 < argc;
  traditional = 2 < argc;
  c89 = 3 < argc;
#if YYDEBUG
  yydebug = 4 < argc;
#endif
  initialize_random_junk ();

  for (;;) {
    printf ("enter expression: ");
    n = 0;
    while ((buf[n] = c = getchar ()) != '\n' && c != EOF)
      n++;
    if (c == EOF)
      break;
    parse_c_expression (buf, 1);
    printf ("parser returned ");
    u = (unsigned HOST_WIDEST_INT) expression_value;
    if (expression_value < 0 && expression_signedp) {
      u = -u;
      printf ("-");
    }
    if (u == 0)
      printf ("0");
    else
      print_unsigned_host_widest_int (u);
    if (! expression_signedp)
      printf("u");
    printf ("\n");
  }

  return 0;
}

static void
print_unsigned_host_widest_int (u)
     unsigned HOST_WIDEST_INT u;
{
  if (u) {
    print_unsigned_host_widest_int (u / 10);
    putchar ('0' + (int) (u % 10));
  }
}

/* table to tell if char can be part of a C identifier. */
unsigned char is_idchar[256];
/* table to tell if char can be first char of a c identifier. */
unsigned char is_idstart[256];
/* table to tell if c is horizontal or vertical space.  */
unsigned char is_space[256];

/*
 * initialize random junk in the hash table and maybe other places
 */
static void
initialize_random_junk ()
{
  register int i;

  /*
   * Set up is_idchar and is_idstart tables.  These should be
   * faster than saying (is_alpha (c) || c == '_'), etc.
   * Must do set up these things before calling any routines tthat
   * refer to them.
   */
  for (i = 'a'; i <= 'z'; i++) {
    ++is_idchar[i - 'a' + 'A'];
    ++is_idchar[i];
    ++is_idstart[i - 'a' + 'A'];
    ++is_idstart[i];
  }
  for (i = '0'; i <= '9'; i++)
    ++is_idchar[i];
  ++is_idchar['_'];
  ++is_idstart['_'];
  ++is_idchar['$'];
  ++is_idstart['$'];

  ++is_space[' '];
  ++is_space['\t'];
  ++is_space['\v'];
  ++is_space['\f'];
  ++is_space['\n'];
  ++is_space['\r'];
}

void
error VPROTO ((char * msgid, ...))
{
#ifndef ANSI_PROTOTYPES
  char * msgid;
#endif
  va_list args;

  VA_START (args, msgid);

#ifndef ANSI_PROTOTYPES
  msgid = va_arg (args, char *);
#endif

  fprintf (stderr, "error: ");
  vfprintf (stderr, _(msgid), args);
  fprintf (stderr, "\n");
  va_end (args);
}

void
pedwarn VPROTO ((char * msgid, ...))
{
#ifndef ANSI_PROTOTYPES
  char * msgid;
#endif
  va_list args;

  VA_START (args, msgid);

#ifndef ANSI_PROTOTYPES
  msgid = va_arg (args, char *);
#endif

  fprintf (stderr, "pedwarn: ");
  vfprintf (stderr, _(msgid), args);
  fprintf (stderr, "\n");
  va_end (args);
}

void
warning VPROTO ((char * msgid, ...))
{
#ifndef ANSI_PROTOTYPES
  char * msgid;
#endif
  va_list args;

  VA_START (args, msgid);

#ifndef ANSI_PROTOTYPES
  msgid = va_arg (args, char *);
#endif

  fprintf (stderr, "warning: ");
  vfprintf (stderr, _(msgid), args);
  fprintf (stderr, "\n");
  va_end (args);
}


int
check_assertion (name, sym_length, tokens_specified, tokens)
     U_CHAR *name;
     int sym_length;
     int tokens_specified;
     struct arglist *tokens;
{
  return 0;
}

struct hashnode *
lookup (name, len, hash)
     U_CHAR *name;
     int len;
     int hash;
{
  return (DEFAULT_SIGNED_CHAR) ? 0 : ((struct hashnode *) -1);
}

PTR
xmalloc (size)
  size_t size;
{
  return (PTR) malloc (size);
}
#endif
#line 1281 "y.tab.c"
/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack()
{
    int newsize, i;
    short *newss;
    YYSTYPE *newvs;

    if ((newsize = yystacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return -1;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;
    i = yyssp - yyss;
    newss = yyss ? (short *)realloc(yyss, newsize * sizeof *newss) :
      (short *)malloc(newsize * sizeof *newss);
    if (newss == NULL)
        return -1;
    yyss = newss;
    yyssp = newss + i;
    newvs = yyvs ? (YYSTYPE *)realloc(yyvs, newsize * sizeof *newvs) :
      (YYSTYPE *)malloc(newsize * sizeof *newvs);
    if (newvs == NULL)
        return -1;
    yyvs = newvs;
    yyvsp = newvs + i;
    yystacksize = newsize;
    yysslim = yyss + newsize - 1;
    return 0;
}

#define YYABORT goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR goto yyerrlab

#ifndef YYPARSE_PARAM
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG void
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG
#define YYPARSE_PARAM_DECL
#endif	/* ANSI-C/C++ */
#else	/* YYPARSE_PARAM */
#ifndef YYPARSE_PARAM_TYPE
#define YYPARSE_PARAM_TYPE void *
#endif
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG YYPARSE_PARAM_TYPE YYPARSE_PARAM
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG YYPARSE_PARAM
#define YYPARSE_PARAM_DECL YYPARSE_PARAM_TYPE YYPARSE_PARAM;
#endif	/* ANSI-C/C++ */
#endif	/* ! YYPARSE_PARAM */

int
yyparse (YYPARSE_PARAM_ARG)
    YYPARSE_PARAM_DECL
{
    register int yym, yyn, yystate;
#if YYDEBUG
    register const char *yys;

    if ((yys = getenv("YYDEBUG")))
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = (-1);

    if (yyss == NULL && yygrowstack()) goto yyoverflow;
    yyssp = yyss;
    yyvsp = yyvs;
    *yyssp = yystate = 0;

yyloop:
    if ((yyn = yydefred[yystate])) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yyssp >= yysslim && yygrowstack())
        {
            goto yyoverflow;
        }
        *++yyssp = yystate = yytable[yyn];
        *++yyvsp = yylval;
        yychar = (-1);
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;
#if defined(lint) || defined(__GNUC__)
    goto yynewerror;
#endif
yynewerror:
    yyerror("syntax error");
#if defined(lint) || defined(__GNUC__)
    goto yyerrlab;
#endif
yyerrlab:
    ++yynerrs;
yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yyssp]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yyssp, yytable[yyn]);
#endif
                if (yyssp >= yysslim && yygrowstack())
                {
                    goto yyoverflow;
                }
                *++yyssp = yystate = yytable[yyn];
                *++yyvsp = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yyssp);
#endif
                if (yyssp <= yyss) goto yyabort;
                --yyssp;
                --yyvsp;
            }
        }
    }
    else
    {
        if (yychar == 0) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = (-1);
        goto yyloop;
    }
yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    yyval = yyvsp[1-yym];
    switch (yyn)
    {
case 1:
#line 185 "../cexp.y"
{
		  expression_value = yyvsp[0].integer.value;
#ifdef TEST_EXP_READER
		  expression_signedp = yyvsp[0].integer.signedp;
#endif
		}
break;
case 3:
#line 196 "../cexp.y"
{ if (pedantic)
			    pedwarn ("comma operator in operand of `#if'");
			  yyval.integer = yyvsp[0].integer; }
break;
case 4:
#line 203 "../cexp.y"
{ yyval.integer.value = - yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[0].integer.signedp;
			  if ((yyval.integer.value & yyvsp[0].integer.value & yyval.integer.signedp) < 0)
			    integer_overflow (); }
break;
case 5:
#line 208 "../cexp.y"
{ yyval.integer.value = ! yyvsp[0].integer.value;
			  yyval.integer.signedp = SIGNED; }
break;
case 6:
#line 211 "../cexp.y"
{ yyval.integer = yyvsp[0].integer; }
break;
case 7:
#line 213 "../cexp.y"
{ yyval.integer.value = ~ yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[0].integer.signedp; }
break;
case 8:
#line 216 "../cexp.y"
{ yyval.integer.value = check_assertion (yyvsp[0].name.address, yyvsp[0].name.length,
						      0, NULL_PTR);
			  yyval.integer.signedp = SIGNED; }
break;
case 9:
#line 220 "../cexp.y"
{ keyword_parsing = 1; }
break;
case 10:
#line 222 "../cexp.y"
{ yyval.integer.value = check_assertion (yyvsp[-4].name.address, yyvsp[-4].name.length,
						      1, yyvsp[-1].keywords);
			  keyword_parsing = 0;
			  yyval.integer.signedp = SIGNED; }
break;
case 11:
#line 227 "../cexp.y"
{ yyval.integer = yyvsp[-1].integer; }
break;
case 12:
#line 232 "../cexp.y"
{ yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp;
			  if (yyval.integer.signedp)
			    {
			      yyval.integer.value = yyvsp[-2].integer.value * yyvsp[0].integer.value;
			      if (yyvsp[-2].integer.value
				  && (yyval.integer.value / yyvsp[-2].integer.value != yyvsp[0].integer.value
				      || (yyval.integer.value & yyvsp[-2].integer.value & yyvsp[0].integer.value) < 0))
				integer_overflow ();
			    }
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					* yyvsp[0].integer.value); }
break;
case 13:
#line 245 "../cexp.y"
{ if (yyvsp[0].integer.value == 0)
			    {
			      if (!skip_evaluation)
				error ("division by zero in #if");
			      yyvsp[0].integer.value = 1;
			    }
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp;
			  if (yyval.integer.signedp)
			    {
			      yyval.integer.value = yyvsp[-2].integer.value / yyvsp[0].integer.value;
			      if ((yyval.integer.value & yyvsp[-2].integer.value & yyvsp[0].integer.value) < 0)
				integer_overflow ();
			    }
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					/ yyvsp[0].integer.value); }
break;
case 14:
#line 262 "../cexp.y"
{ if (yyvsp[0].integer.value == 0)
			    {
			      if (!skip_evaluation)
				error ("division by zero in #if");
			      yyvsp[0].integer.value = 1;
			    }
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp;
			  if (yyval.integer.signedp)
			    yyval.integer.value = yyvsp[-2].integer.value % yyvsp[0].integer.value;
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					% yyvsp[0].integer.value); }
break;
case 15:
#line 275 "../cexp.y"
{ yyval.integer.value = yyvsp[-2].integer.value + yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp;
			  if (overflow_sum_sign (yyvsp[-2].integer.value, yyvsp[0].integer.value,
						 yyval.integer.value, yyval.integer.signedp))
			    integer_overflow (); }
break;
case 16:
#line 281 "../cexp.y"
{ yyval.integer.value = yyvsp[-2].integer.value - yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp;
			  if (overflow_sum_sign (yyval.integer.value, yyvsp[0].integer.value,
						 yyvsp[-2].integer.value, yyval.integer.signedp))
			    integer_overflow (); }
break;
case 17:
#line 287 "../cexp.y"
{ yyval.integer.signedp = yyvsp[-2].integer.signedp;
			  if ((yyvsp[0].integer.value & yyvsp[0].integer.signedp) < 0)
			    yyval.integer.value = right_shift (&yyvsp[-2].integer, -yyvsp[0].integer.value);
			  else
			    yyval.integer.value = left_shift (&yyvsp[-2].integer, yyvsp[0].integer.value); }
break;
case 18:
#line 293 "../cexp.y"
{ yyval.integer.signedp = yyvsp[-2].integer.signedp;
			  if ((yyvsp[0].integer.value & yyvsp[0].integer.signedp) < 0)
			    yyval.integer.value = left_shift (&yyvsp[-2].integer, -yyvsp[0].integer.value);
			  else
			    yyval.integer.value = right_shift (&yyvsp[-2].integer, yyvsp[0].integer.value); }
break;
case 19:
#line 299 "../cexp.y"
{ yyval.integer.value = (yyvsp[-2].integer.value == yyvsp[0].integer.value);
			  yyval.integer.signedp = SIGNED; }
break;
case 20:
#line 302 "../cexp.y"
{ yyval.integer.value = (yyvsp[-2].integer.value != yyvsp[0].integer.value);
			  yyval.integer.signedp = SIGNED; }
break;
case 21:
#line 305 "../cexp.y"
{ yyval.integer.signedp = SIGNED;
			  if (yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp)
			    yyval.integer.value = yyvsp[-2].integer.value <= yyvsp[0].integer.value;
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					<= yyvsp[0].integer.value); }
break;
case 22:
#line 312 "../cexp.y"
{ yyval.integer.signedp = SIGNED;
			  if (yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp)
			    yyval.integer.value = yyvsp[-2].integer.value >= yyvsp[0].integer.value;
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					>= yyvsp[0].integer.value); }
break;
case 23:
#line 319 "../cexp.y"
{ yyval.integer.signedp = SIGNED;
			  if (yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp)
			    yyval.integer.value = yyvsp[-2].integer.value < yyvsp[0].integer.value;
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					< yyvsp[0].integer.value); }
break;
case 24:
#line 326 "../cexp.y"
{ yyval.integer.signedp = SIGNED;
			  if (yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp)
			    yyval.integer.value = yyvsp[-2].integer.value > yyvsp[0].integer.value;
			  else
			    yyval.integer.value = ((unsigned HOST_WIDEST_INT) yyvsp[-2].integer.value
					> yyvsp[0].integer.value); }
break;
case 25:
#line 333 "../cexp.y"
{ yyval.integer.value = yyvsp[-2].integer.value & yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp; }
break;
case 26:
#line 336 "../cexp.y"
{ yyval.integer.value = yyvsp[-2].integer.value ^ yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp; }
break;
case 27:
#line 339 "../cexp.y"
{ yyval.integer.value = yyvsp[-2].integer.value | yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-2].integer.signedp & yyvsp[0].integer.signedp; }
break;
case 28:
#line 342 "../cexp.y"
{ skip_evaluation += !yyvsp[-1].integer.value; }
break;
case 29:
#line 344 "../cexp.y"
{ skip_evaluation -= !yyvsp[-3].integer.value;
			  yyval.integer.value = (yyvsp[-3].integer.value && yyvsp[0].integer.value);
			  yyval.integer.signedp = SIGNED; }
break;
case 30:
#line 348 "../cexp.y"
{ skip_evaluation += !!yyvsp[-1].integer.value; }
break;
case 31:
#line 350 "../cexp.y"
{ skip_evaluation -= !!yyvsp[-3].integer.value;
			  yyval.integer.value = (yyvsp[-3].integer.value || yyvsp[0].integer.value);
			  yyval.integer.signedp = SIGNED; }
break;
case 32:
#line 354 "../cexp.y"
{ skip_evaluation += !yyvsp[-1].integer.value; }
break;
case 33:
#line 356 "../cexp.y"
{ skip_evaluation += !!yyvsp[-4].integer.value - !yyvsp[-4].integer.value; }
break;
case 34:
#line 358 "../cexp.y"
{ skip_evaluation -= !!yyvsp[-6].integer.value;
			  yyval.integer.value = yyvsp[-6].integer.value ? yyvsp[-3].integer.value : yyvsp[0].integer.value;
			  yyval.integer.signedp = yyvsp[-3].integer.signedp & yyvsp[0].integer.signedp; }
break;
case 35:
#line 362 "../cexp.y"
{ yyval.integer = yylval.integer; }
break;
case 36:
#line 364 "../cexp.y"
{ yyval.integer = yylval.integer; }
break;
case 37:
#line 366 "../cexp.y"
{ if (warn_undef && !skip_evaluation)
			    warning ("`%.*s' is not defined",
				     yyvsp[0].name.length, yyvsp[0].name.address);
			  yyval.integer.value = 0;
			  yyval.integer.signedp = SIGNED; }
break;
case 38:
#line 374 "../cexp.y"
{ yyval.keywords = 0; }
break;
case 39:
#line 376 "../cexp.y"
{ struct arglist *temp;
			  yyval.keywords = (struct arglist *) xmalloc (sizeof (struct arglist));
			  yyval.keywords->next = yyvsp[-2].keywords;
			  yyval.keywords->name = (U_CHAR *) "(";
			  yyval.keywords->length = 1;
			  temp = yyval.keywords;
			  while (temp != 0 && temp->next != 0)
			    temp = temp->next;
			  temp->next = (struct arglist *) xmalloc (sizeof (struct arglist));
			  temp->next->next = yyvsp[0].keywords;
			  temp->next->name = (U_CHAR *) ")";
			  temp->next->length = 1; }
break;
case 40:
#line 389 "../cexp.y"
{ yyval.keywords = (struct arglist *) xmalloc (sizeof (struct arglist));
			  yyval.keywords->name = yyvsp[-1].name.address;
			  yyval.keywords->length = yyvsp[-1].name.length;
			  yyval.keywords->next = yyvsp[0].keywords; }
break;
#line 1751 "y.tab.c"
    }
    yyssp -= yym;
    yystate = *yyssp;
    yyvsp -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yyssp = YYFINAL;
        *++yyvsp = yyval;
        if (yychar < 0)
        {
            if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
            if (yydebug)
            {
                yys = 0;
                if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
                if (!yys) yys = "illegal-symbol";
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == 0) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yyssp, yystate);
#endif
    if (yyssp >= yysslim && yygrowstack())
    {
        goto yyoverflow;
    }
    *++yyssp = yystate;
    *++yyvsp = yyval;
    goto yyloop;
yyoverflow:
    yyerror("yacc stack overflow");
yyabort:
    return (1);
yyaccept:
    return (0);
}
