/* YACC parser for C syntax and for Objective C.  -*-c-*-
   Copyright (C) 1987, 1988, 1989, 1992, 1993, 1994, 1995, 1996, 1997,
   1998, 1999, 2000, 2001, 2002, 2003, 2004 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.  */

/* This file defines the grammar of C and that of Objective C.
   @@ifobjc ... @@end_ifobjc  conditionals contain code for Objective C only.
   @@ifc ... @@end_ifc  conditionals contain code for C only.
   Sed commands in Makefile.in are used to convert this file into
   c-parse.y and into objc-parse.y.  */

/* To whomever it may concern: I have heard that such a thing was once
   written by AT&T, but I have never seen it.  */


%{
#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "tm.h"
#include "tree.h"
#include "input.h"
#include "cpplib.h"
#include "intl.h"
#include "timevar.h"
#include "c-pragma.h"		/* For YYDEBUG definition, and parse_in.  */
#include "c-tree.h"
#include "flags.h"
#include "varray.h"
#include "output.h"
#include "toplev.h"
#include "ggc.h"

#include "objc-act.h"

/* Like YYERROR but do call yyerror.  */
#define YYERROR1 { yyerror ("syntax error"); YYERROR; }

/* Like the default stack expander, except (1) use realloc when possible,
   (2) impose no hard maxiumum on stack size, (3) REALLY do not use alloca.

   Irritatingly, YYSTYPE is defined after this %{ %} block, so we cannot
   give malloced_yyvs its proper type.  This is ok since all we need from
   it is to be able to free it.  */

static short *malloced_yyss;
static void *malloced_yyvs;

#define yyoverflow(MSG, SS, SSSIZE, VS, VSSIZE, YYSSZ)			\
do {									\
  size_t newsize;							\
  short *newss;								\
  YYSTYPE *newvs;							\
  newsize = *(YYSSZ) *= 2;						\
  if (malloced_yyss)							\
    {									\
      newss = really_call_realloc (*(SS), newsize * sizeof (short));	\
      newvs = really_call_realloc (*(VS), newsize * sizeof (YYSTYPE));	\
    }									\
  else									\
    {									\
      newss = really_call_malloc (newsize * sizeof (short));		\
      newvs = really_call_malloc (newsize * sizeof (YYSTYPE));		\
      if (newss)							\
        memcpy (newss, *(SS), (SSSIZE));				\
      if (newvs)							\
        memcpy (newvs, *(VS), (VSSIZE));				\
    }									\
  if (!newss || !newvs)							\
    {									\
      yyerror (MSG);							\
      return 2;								\
    }									\
  *(SS) = newss;							\
  *(VS) = newvs;							\
  malloced_yyss = newss;						\
  malloced_yyvs = (void *) newvs;					\
} while (0)
%}

%start program

%union {long itype; tree ttype; enum tree_code code;
	location_t location; }

/* All identifiers that are not reserved words
   and are not declared typedefs in the current block */
%token IDENTIFIER

/* All identifiers that are declared typedefs in the current block.
   In some contexts, they are treated just like IDENTIFIER,
   but they can also serve as typespecs in declarations.  */
%token TYPENAME

/* Reserved words that specify storage class.
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token SCSPEC			/* Storage class other than static.  */
%token STATIC			/* Static storage class.  */

/* Reserved words that specify type.
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token TYPESPEC

/* Reserved words that qualify type: "const", "volatile", or "restrict".
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token TYPE_QUAL

/* Character or numeric constants.
   yylval is the node for the constant.  */
%token CONSTANT

/* String constants in raw form.
   yylval is a STRING_CST node.  */

%token STRING

/* "...", used for functions with variable arglists.  */
%token ELLIPSIS

/* the reserved words */
/* SCO include files test "ASM", so use something else. */
%token SIZEOF ENUM STRUCT UNION IF ELSE WHILE DO FOR SWITCH CASE DEFAULT
%token BREAK CONTINUE RETURN GOTO ASM_KEYWORD TYPEOF ALIGNOF
%token ATTRIBUTE EXTENSION LABEL
%token REALPART IMAGPART VA_ARG CHOOSE_EXPR TYPES_COMPATIBLE_P
%token PTR_VALUE PTR_BASE PTR_EXTENT
%token FUNC_NAME

/* Add precedence rules to solve dangling else s/r conflict */
%nonassoc IF
%nonassoc ELSE

/* Define the operator tokens and their precedences.
   The value is an integer because, if used, it is the tree code
   to use in the expression made from the operator.  */

%right <code> ASSIGN '='
%right <code> '?' ':'
%left <code> OROR
%left <code> ANDAND
%left <code> '|'
%left <code> '^'
%left <code> '&'
%left <code> EQCOMPARE
%left <code> ARITHCOMPARE
%left <code> LSHIFT RSHIFT
%left <code> '+' '-'
%left <code> '*' '/' '%'
%right <code> UNARY PLUSPLUS MINUSMINUS
%left HYPERUNARY
%left <code> POINTSAT '.' '(' '['

/* The Objective-C keywords.  These are included in C and in
   Objective C, so that the token codes are the same in both.  */
%token INTERFACE IMPLEMENTATION END SELECTOR DEFS ENCODE
%token CLASSNAME PUBLIC PRIVATE PROTECTED PROTOCOL OBJECTNAME CLASS ALIAS
%token AT_THROW AT_TRY AT_CATCH AT_FINALLY AT_SYNCHRONIZED
%token OBJC_STRING

%type <code> unop
%type <ttype> ENUM STRUCT UNION IF ELSE WHILE DO FOR SWITCH CASE DEFAULT
%type <ttype> BREAK CONTINUE RETURN GOTO ASM_KEYWORD SIZEOF TYPEOF ALIGNOF

%type <ttype> identifier IDENTIFIER TYPENAME CONSTANT expr nonnull_exprlist exprlist
%type <ttype> expr_no_commas cast_expr unary_expr primary STRING
%type <ttype> declspecs_nosc_nots_nosa_noea declspecs_nosc_nots_nosa_ea
%type <ttype> declspecs_nosc_nots_sa_noea declspecs_nosc_nots_sa_ea
%type <ttype> declspecs_nosc_ts_nosa_noea declspecs_nosc_ts_nosa_ea
%type <ttype> declspecs_nosc_ts_sa_noea declspecs_nosc_ts_sa_ea
%type <ttype> declspecs_sc_nots_nosa_noea declspecs_sc_nots_nosa_ea
%type <ttype> declspecs_sc_nots_sa_noea declspecs_sc_nots_sa_ea
%type <ttype> declspecs_sc_ts_nosa_noea declspecs_sc_ts_nosa_ea
%type <ttype> declspecs_sc_ts_sa_noea declspecs_sc_ts_sa_ea
%type <ttype> declspecs_ts declspecs_nots
%type <ttype> declspecs_ts_nosa declspecs_nots_nosa
%type <ttype> declspecs_nosc_ts declspecs_nosc_nots declspecs_nosc declspecs
%type <ttype> maybe_type_quals_attrs typespec_nonattr typespec_attr
%type <ttype> typespec_reserved_nonattr typespec_reserved_attr
%type <ttype> typespec_nonreserved_nonattr

%type <ttype> scspec SCSPEC STATIC TYPESPEC TYPE_QUAL maybe_type_qual
%type <ttype> initdecls notype_initdecls initdcl notype_initdcl
%type <ttype> init maybeasm
%type <ttype> asm_operands nonnull_asm_operands asm_operand asm_clobbers
%type <ttype> maybe_attribute attributes attribute attribute_list attrib
%type <ttype> any_word

%type <ttype> compstmt compstmt_start compstmt_nostart compstmt_primary_start
%type <ttype> do_stmt_start poplevel stmt label

%type <ttype> c99_block_start c99_block_end
%type <ttype> declarator
%type <ttype> notype_declarator after_type_declarator
%type <ttype> parm_declarator
%type <ttype> parm_declarator_starttypename parm_declarator_nostarttypename
%type <ttype> array_declarator

%type <ttype> structsp_attr structsp_nonattr
%type <ttype> component_decl_list component_decl_list2
%type <ttype> component_decl components components_notype component_declarator
%type <ttype> component_notype_declarator
%type <ttype> enumlist enumerator
%type <ttype> struct_head union_head enum_head
%type <ttype> typename absdcl absdcl1 absdcl1_ea absdcl1_noea
%type <ttype> direct_absdcl1 absdcl_maybe_attribute
%type <ttype> xexpr parms parm firstparm identifiers

%type <ttype> parmlist parmlist_1 parmlist_2
%type <ttype> parmlist_or_identifiers parmlist_or_identifiers_1
%type <ttype> identifiers_or_typenames

%type <itype> setspecs setspecs_fp extension

%type <location> save_location

/* the Objective-C nonterminals */

%type <ttype> ivar_decl_list ivar_decls ivar_decl ivars ivar_declarator
%type <ttype> methoddecl unaryselector keywordselector selector
%type <ttype> keyworddecl receiver objcmessageexpr messageargs
%type <ttype> keywordexpr keywordarglist keywordarg
%type <ttype> myparms myparm optparmlist reservedwords objcselectorexpr
%type <ttype> selectorarg keywordnamelist keywordname objcencodeexpr
%type <ttype> non_empty_protocolrefs protocolrefs identifier_list objcprotocolexpr

%type <ttype> CLASSNAME OBJECTNAME OBJC_STRING

%type <ttype> superclass
%type <itype> objc_try_catch_stmt objc_finally_block

%{
/* Number of statements (loosely speaking) and compound statements
   seen so far.  */
static int stmt_count;
static int compstmt_count;

/* Input location of the end of the body of last simple_if;
   used by the stmt-rule immediately after simple_if returns.  */
static location_t if_stmt_locus;


/* List of types and structure classes of the current declaration.  */
static GTY(()) tree current_declspecs;
static GTY(()) tree prefix_attributes;

/* List of all the attributes applying to the identifier currently being
   declared; includes prefix_attributes and possibly some more attributes
   just after a comma.  */
static GTY(()) tree all_prefix_attributes;

/* Stack of saved values of current_declspecs, prefix_attributes and
   all_prefix_attributes.  */
static GTY(()) tree declspec_stack;

/* PUSH_DECLSPEC_STACK is called from setspecs; POP_DECLSPEC_STACK
   should be called from the productions making use of setspecs.  */
#define PUSH_DECLSPEC_STACK						 \
  do {									 \
    declspec_stack = tree_cons (build_tree_list (prefix_attributes,	 \
						 all_prefix_attributes), \
				current_declspecs,			 \
				declspec_stack);			 \
  } while (0)

#define POP_DECLSPEC_STACK						\
  do {									\
    current_declspecs = TREE_VALUE (declspec_stack);			\
    prefix_attributes = TREE_PURPOSE (TREE_PURPOSE (declspec_stack));	\
    all_prefix_attributes = TREE_VALUE (TREE_PURPOSE (declspec_stack));	\
    declspec_stack = TREE_CHAIN (declspec_stack);			\
  } while (0)

/* For __extension__, save/restore the warning flags which are
   controlled by __extension__.  */
#define SAVE_EXT_FLAGS()		\
	(pedantic			\
	 | (warn_pointer_arith << 1)	\
	 | (warn_traditional << 2)	\
	 | (flag_iso << 3))

#define RESTORE_EXT_FLAGS(val)			\
  do {						\
    pedantic = val & 1;				\
    warn_pointer_arith = (val >> 1) & 1;	\
    warn_traditional = (val >> 2) & 1;		\
    flag_iso = (val >> 3) & 1;			\
  } while (0)

/* Objective-C specific parser/lexer information */

static enum tree_code objc_inherit_code;
static int objc_pq_context = 0, objc_public_flag = 0;

/* The following flag is needed to contextualize ObjC lexical analysis.
   In some cases (e.g., 'int NSObject;'), it is undesirable to bind
   an identifier to an ObjC class, even if a class with that name
   exists.  */
static int objc_need_raw_identifier;
#define OBJC_NEED_RAW_IDENTIFIER(VAL)	objc_need_raw_identifier = VAL


static bool parsing_iso_function_signature;

/* Tell yyparse how to print a token's value, if yydebug is set.  */

#define YYPRINT(FILE,YYCHAR,YYLVAL) yyprint(FILE,YYCHAR,YYLVAL)

static void yyprint (FILE *, int, YYSTYPE);
static void yyerror (const char *);
static int yylexname (void);
static inline int _yylex (void);
static int  yylex (void);
static void init_reswords (void);

  /* Initialisation routine for this file.  */
void
c_parse_init (void)
{
  init_reswords ();
}

%}

%%
program: /* empty */
		{ if (pedantic)
		    pedwarn ("ISO C forbids an empty source file");
		}
	| extdefs
	;

/* the reason for the strange actions in this rule
 is so that notype_initdecls when reached via datadef
 can find a valid list of type and sc specs in $0. */

extdefs:
	{$<ttype>$ = NULL_TREE; } extdef
	| extdefs {$<ttype>$ = NULL_TREE; ggc_collect(); } extdef
	;

extdef:
	extdef_1
	{ parsing_iso_function_signature = false; } /* Reset after any external definition.  */
	;

extdef_1:
	fndef
	| datadef
	| objcdef
	| ASM_KEYWORD '(' expr ')' ';'
		{ STRIP_NOPS ($3);
		  if ((TREE_CODE ($3) == ADDR_EXPR
		       && TREE_CODE (TREE_OPERAND ($3, 0)) == STRING_CST)
		      || TREE_CODE ($3) == STRING_CST)
		    assemble_asm ($3);
		  else
		    error ("argument of `asm' is not a constant string"); }
	| extension extdef
		{ RESTORE_EXT_FLAGS ($1); }
	;

datadef:
	  setspecs notype_initdecls ';'
		{ if (pedantic)
		    error ("ISO C forbids data definition with no type or storage class");
		  else
		    warning ("data definition has no type or storage class");

		  POP_DECLSPEC_STACK; }
        | declspecs_nots setspecs notype_initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs ';'
	  { shadow_tag ($1); }
	| error ';'
	| error '}'
	| ';'
		{ if (pedantic)
		    pedwarn ("ISO C does not allow extra `;' outside of a function"); }
	;

fndef:
	  declspecs_ts setspecs declarator
		{ if (! start_function (current_declspecs, $3,
					all_prefix_attributes))
		    YYERROR1;
		}
	  old_style_parm_decls save_location
		{ DECL_SOURCE_LOCATION (current_function_decl) = $6;
		  store_parm_decls (); }
	  compstmt_or_error
		{ finish_function ();
		  POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs declarator error
		{ POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_declarator
		{ if (! start_function (current_declspecs, $3,
					all_prefix_attributes))
		    YYERROR1;
		}
	  old_style_parm_decls save_location
		{ DECL_SOURCE_LOCATION (current_function_decl) = $6;
		  store_parm_decls (); }
	  compstmt_or_error
		{ finish_function ();
		  POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_declarator error
		{ POP_DECLSPEC_STACK; }
	| setspecs notype_declarator
		{ if (! start_function (NULL_TREE, $2,
					all_prefix_attributes))
		    YYERROR1;
		}
	  old_style_parm_decls save_location
		{ DECL_SOURCE_LOCATION (current_function_decl) = $5;
		  store_parm_decls (); }
	  compstmt_or_error
		{ finish_function ();
		  POP_DECLSPEC_STACK; }
	| setspecs notype_declarator error
		{ POP_DECLSPEC_STACK; }
	;

identifier:
	IDENTIFIER
	| TYPENAME
	| OBJECTNAME
	| CLASSNAME
	;

unop:     '&'
		{ $$ = ADDR_EXPR; }
	| '-'
		{ $$ = NEGATE_EXPR; }
	| '+'
		{ $$ = CONVERT_EXPR;
		}
	| PLUSPLUS
		{ $$ = PREINCREMENT_EXPR; }
	| MINUSMINUS
		{ $$ = PREDECREMENT_EXPR; }
	| '~'
		{ $$ = BIT_NOT_EXPR; }
	| '!'
		{ $$ = TRUTH_NOT_EXPR; }
	;

expr:	nonnull_exprlist
		{ $$ = build_compound_expr ($1); }
	;

exprlist:
	  /* empty */
		{ $$ = NULL_TREE; }
	| nonnull_exprlist
	;

nonnull_exprlist:
	expr_no_commas
		{ $$ = build_tree_list (NULL_TREE, $1); }
	| nonnull_exprlist ',' expr_no_commas
		{ chainon ($1, build_tree_list (NULL_TREE, $3)); }
	;

unary_expr:
	primary
	| '*' cast_expr   %prec UNARY
		{ $$ = build_indirect_ref ($2, "unary *"); }
	/* __extension__ turns off -pedantic for following primary.  */
	| extension cast_expr	  %prec UNARY
		{ $$ = $2;
		  RESTORE_EXT_FLAGS ($1); }
	| unop cast_expr  %prec UNARY
		{ $$ = build_unary_op ($1, $2, 0);
		  overflow_warning ($$); }
	/* Refer to the address of a label as a pointer.  */
	| ANDAND identifier
		{ $$ = finish_label_address_expr ($2); }
	| sizeof unary_expr  %prec UNARY
		{ skip_evaluation--;
		  if (TREE_CODE ($2) == COMPONENT_REF
		      && DECL_C_BIT_FIELD (TREE_OPERAND ($2, 1)))
		    error ("`sizeof' applied to a bit-field");
		  $$ = c_sizeof (TREE_TYPE ($2)); }
	| sizeof '(' typename ')'  %prec HYPERUNARY
		{ skip_evaluation--;
		  $$ = c_sizeof (groktypename ($3)); }
	| alignof unary_expr  %prec UNARY
		{ skip_evaluation--;
		  $$ = c_alignof_expr ($2); }
	| alignof '(' typename ')'  %prec HYPERUNARY
		{ skip_evaluation--;
		  $$ = c_alignof (groktypename ($3)); }
	| REALPART cast_expr %prec UNARY
		{ $$ = build_unary_op (REALPART_EXPR, $2, 0); }
	| IMAGPART cast_expr %prec UNARY
		{ $$ = build_unary_op (IMAGPART_EXPR, $2, 0); }
	;

sizeof:
	SIZEOF { skip_evaluation++; }
	;

alignof:
	ALIGNOF { skip_evaluation++; }
	;

typeof:
	TYPEOF { skip_evaluation++; }
	;

cast_expr:
	unary_expr
	| '(' typename ')' cast_expr  %prec UNARY
		{ $$ = c_cast_expr ($2, $4); }
	;

expr_no_commas:
	  cast_expr
	| expr_no_commas '+' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '-' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '*' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '/' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '%' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas LSHIFT expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas RSHIFT expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas ARITHCOMPARE expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas EQCOMPARE expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '&' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '|' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas '^' expr_no_commas
		{ $$ = parser_build_binary_op ($2, $1, $3); }
	| expr_no_commas ANDAND
		{ $1 = c_common_truthvalue_conversion
		    (default_conversion ($1));
		  skip_evaluation += $1 == truthvalue_false_node; }
	  expr_no_commas
		{ skip_evaluation -= $1 == truthvalue_false_node;
		  $$ = parser_build_binary_op (TRUTH_ANDIF_EXPR, $1, $4); }
	| expr_no_commas OROR
		{ $1 = c_common_truthvalue_conversion
		    (default_conversion ($1));
		  skip_evaluation += $1 == truthvalue_true_node; }
	  expr_no_commas
		{ skip_evaluation -= $1 == truthvalue_true_node;
		  $$ = parser_build_binary_op (TRUTH_ORIF_EXPR, $1, $4); }
	| expr_no_commas '?'
		{ $1 = c_common_truthvalue_conversion
		    (default_conversion ($1));
		  skip_evaluation += $1 == truthvalue_false_node; }
          expr ':'
		{ skip_evaluation += (($1 == truthvalue_true_node)
				      - ($1 == truthvalue_false_node)); }
	  expr_no_commas
		{ skip_evaluation -= $1 == truthvalue_true_node;
		  $$ = build_conditional_expr ($1, $4, $7); }
	| expr_no_commas '?'
		{ if (pedantic)
		    pedwarn ("ISO C forbids omitting the middle term of a ?: expression");
		  /* Make sure first operand is calculated only once.  */
		  $<ttype>2 = save_expr ($1);
		  $1 = c_common_truthvalue_conversion
		    (default_conversion ($<ttype>2));
		  skip_evaluation += $1 == truthvalue_true_node; }
	  ':' expr_no_commas
		{ skip_evaluation -= $1 == truthvalue_true_node;
		  $$ = build_conditional_expr ($1, $<ttype>2, $5); }
	| expr_no_commas '=' expr_no_commas
		{ char class;
		  $$ = build_modify_expr ($1, NOP_EXPR, $3);
		  class = TREE_CODE_CLASS (TREE_CODE ($$));
		  if (IS_EXPR_CODE_CLASS (class))
		    C_SET_EXP_ORIGINAL_CODE ($$, MODIFY_EXPR);
		}
	| expr_no_commas ASSIGN expr_no_commas
		{ char class;
		  $$ = build_modify_expr ($1, $2, $3);
		  /* This inhibits warnings in
		     c_common_truthvalue_conversion.  */
		  class = TREE_CODE_CLASS (TREE_CODE ($$));
		  if (IS_EXPR_CODE_CLASS (class))
		    C_SET_EXP_ORIGINAL_CODE ($$, ERROR_MARK);
		}
	;

primary:
	IDENTIFIER
		{
		  if (yychar == YYEMPTY)
		    yychar = YYLEX;
		  $$ = build_external_ref ($1, yychar == '(');
		}
	| CONSTANT
	| STRING
	| FUNC_NAME
		{ $$ = fname_decl (C_RID_CODE ($$), $$); }
	| '(' typename ')' '{'
		{ start_init (NULL_TREE, NULL, 0);
		  $2 = groktypename ($2);
		  really_start_incremental_init ($2); }
	  initlist_maybe_comma '}'  %prec UNARY
		{ tree constructor = pop_init_level (0);
		  tree type = $2;
		  finish_init ();

		  if (pedantic && ! flag_isoc99)
		    pedwarn ("ISO C90 forbids compound literals");
		  $$ = build_compound_literal (type, constructor);
		}
	| '(' expr ')'
		{ char class = TREE_CODE_CLASS (TREE_CODE ($2));
		  if (IS_EXPR_CODE_CLASS (class))
		    C_SET_EXP_ORIGINAL_CODE ($2, ERROR_MARK);
		  $$ = $2; }
	| '(' error ')'
		{ $$ = error_mark_node; }
	| compstmt_primary_start compstmt_nostart ')'
                 { tree saved_last_tree;

		   if (pedantic)
		     pedwarn ("ISO C forbids braced-groups within expressions");
		  saved_last_tree = COMPOUND_BODY ($1);
		  RECHAIN_STMTS ($1, COMPOUND_BODY ($1));
		  last_tree = saved_last_tree;
		  TREE_CHAIN (last_tree) = NULL_TREE;
		  if (!last_expr_type)
		    last_expr_type = void_type_node;
		  $$ = build1 (STMT_EXPR, last_expr_type, $1);
		  TREE_SIDE_EFFECTS ($$) = 1;
		}
	| compstmt_primary_start error ')'
		{
		  last_tree = COMPOUND_BODY ($1);
		  TREE_CHAIN (last_tree) = NULL_TREE;
		  $$ = error_mark_node;
		}
	| primary '(' exprlist ')'   %prec '.'
		{ $$ = build_function_call ($1, $3); }
	| VA_ARG '(' expr_no_commas ',' typename ')'
		{ $$ = build_va_arg ($3, groktypename ($5)); }

      | CHOOSE_EXPR '(' expr_no_commas ',' expr_no_commas ',' expr_no_commas ')'
		{
                  tree c;

                  c = fold ($3);
                  STRIP_NOPS (c);
                  if (TREE_CODE (c) != INTEGER_CST)
                    error ("first argument to __builtin_choose_expr not a constant");
                  $$ = integer_zerop (c) ? $7 : $5;
		}
      | TYPES_COMPATIBLE_P '(' typename ',' typename ')'
		{
		  tree e1, e2;

		  e1 = TYPE_MAIN_VARIANT (groktypename ($3));
		  e2 = TYPE_MAIN_VARIANT (groktypename ($5));

		  $$ = comptypes (e1, e2, COMPARE_STRICT)
		    ? build_int_2 (1, 0) : build_int_2 (0, 0);
		}
	| primary '[' expr ']'   %prec '.'
		{ $$ = build_array_ref ($1, $3); }
	| primary '.' identifier
		{
		    if (!is_public ($1, $3))
		      $$ = error_mark_node;
		    else
		      $$ = build_component_ref ($1, $3);
		}
	| primary POINTSAT identifier
		{
                  tree expr = build_indirect_ref ($1, "->");

		      if (!is_public (expr, $3))
			$$ = error_mark_node;
		      else
			$$ = build_component_ref (expr, $3);
		}
	| primary PLUSPLUS
		{ $$ = build_unary_op (POSTINCREMENT_EXPR, $1, 0); }
	| primary MINUSMINUS
		{ $$ = build_unary_op (POSTDECREMENT_EXPR, $1, 0); }
	| objcmessageexpr
		{ $$ = build_message_expr ($1); }
	| objcselectorexpr
		{ $$ = build_selector_expr ($1); }
	| objcprotocolexpr
		{ $$ = build_protocol_expr ($1); }
	| objcencodeexpr
		{ $$ = build_encode_expr ($1); }
	| OBJC_STRING
		{ $$ = build_objc_string_object ($1); }
	;

old_style_parm_decls:
	old_style_parm_decls_1
	{
	  parsing_iso_function_signature = false; /* Reset after decls.  */
	}
	;

old_style_parm_decls_1:
	/* empty */
	{
	  if (warn_traditional && !in_system_header
	      && parsing_iso_function_signature)
	    warning ("traditional C rejects ISO C style function definitions");
	  if (warn_old_style_definition && !in_system_header
	      && !parsing_iso_function_signature)
	    warning ("old-style parameter declaration");
	  parsing_iso_function_signature = false; /* Reset after warning.  */
	}
	| datadecls
	{
	  if (warn_old_style_definition && !in_system_header)
	    warning ("old-style parameter declaration");
	}
	;

/* The following are analogous to lineno_decl, decls and decl
   except that they do not allow nested functions.
   They are used for old-style parm decls.  */
lineno_datadecl:
	  save_location datadecl
		{ }
	;

datadecls:
	lineno_datadecl
	| errstmt
	| datadecls lineno_datadecl
	| lineno_datadecl errstmt
	;

/* We don't allow prefix attributes here because they cause reduce/reduce
   conflicts: we can't know whether we're parsing a function decl with
   attribute suffix, or function defn with attribute prefix on first old
   style parm.  */
datadecl:
	declspecs_ts_nosa setspecs initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_nots_nosa setspecs notype_initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_ts_nosa ';'
		{ shadow_tag_warned ($1, 1);
		  pedwarn ("empty declaration"); }
	| declspecs_nots_nosa ';'
		{ pedwarn ("empty declaration"); }
	;

/* This combination which saves a lineno before a decl
   is the normal thing to use, rather than decl itself.
   This is to avoid shift/reduce conflicts in contexts
   where statement labels are allowed.  */
lineno_decl:
	  save_location decl
		{ }
	;

/* records the type and storage class specs to use for processing
   the declarators that follow.
   Maintains a stack of outer-level values of current_declspecs,
   for the sake of parm declarations nested in function declarators.  */
setspecs: /* empty */
		{ pending_xref_error ();
		  PUSH_DECLSPEC_STACK;
		  split_specs_attrs ($<ttype>0,
				     &current_declspecs, &prefix_attributes);
		  all_prefix_attributes = prefix_attributes; }
	;

/* Possibly attributes after a comma, which should reset all_prefix_attributes
   to prefix_attributes with these ones chained on the front.  */
maybe_resetattrs:
	  maybe_attribute
		{ all_prefix_attributes = chainon ($1, prefix_attributes); }
	;

decl:
	declspecs_ts setspecs initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_initdecls ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs nested_function
		{ POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_nested_function
		{ POP_DECLSPEC_STACK; }
	| declspecs ';'
		{ shadow_tag ($1); }
	| extension decl
		{ RESTORE_EXT_FLAGS ($1); }
	;

/* A list of declaration specifiers.  These are:

   - Storage class specifiers (scspec), which for GCC currently includes
   function specifiers ("inline").

   - Type specifiers (typespec_*).

   - Type qualifiers (TYPE_QUAL).

   - Attribute specifier lists (attributes).

   These are stored as a TREE_LIST; the head of the list is the last
   item in the specifier list.  Each entry in the list has either a
   TREE_PURPOSE that is an attribute specifier list, or a TREE_VALUE that
   is a single other specifier or qualifier; and a TREE_CHAIN that is the
   rest of the list.  TREE_STATIC is set on the list if something other
   than a storage class specifier or attribute has been seen; this is used
   to warn for the obsolescent usage of storage class specifiers other than
   at the start of the list.  (Doing this properly would require function
   specifiers to be handled separately from storage class specifiers.)

   The various cases below are classified according to:

   (a) Whether a storage class specifier is included or not; some
   places in the grammar disallow storage class specifiers (_sc or _nosc).

   (b) Whether a type specifier has been seen; after a type specifier,
   a typedef name is an identifier to redeclare (_ts or _nots).

   (c) Whether the list starts with an attribute; in certain places,
   the grammar requires specifiers that don't start with an attribute
   (_sa or _nosa).

   (d) Whether the list ends with an attribute (or a specifier such that
   any following attribute would have been parsed as part of that specifier);
   this avoids shift-reduce conflicts in the parsing of attributes
   (_ea or _noea).

   TODO:

   (i) Distinguish between function specifiers and storage class specifiers,
   at least for the purpose of warnings about obsolescent usage.

   (ii) Halve the number of productions here by eliminating the _sc/_nosc
   distinction and instead checking where required that storage class
   specifiers aren't present.  */

/* Declspecs which contain at least one type specifier or typedef name.
   (Just `const' or `volatile' is not enough.)
   A typedef'd name following these is taken as a name to be declared.
   Declspecs have a non-NULL TREE_VALUE, attributes do not.  */

declspecs_nosc_nots_nosa_noea:
	  TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_nosc_nots_nosa_ea:
	  declspecs_nosc_nots_nosa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_nosc_nots_sa_noea:
	  declspecs_nosc_nots_sa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_nosc_nots_sa_ea:
	  attributes
		{ $$ = tree_cons ($1, NULL_TREE, NULL_TREE);
		  TREE_STATIC ($$) = 0; }
	| declspecs_nosc_nots_sa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_nosc_ts_nosa_noea:
	  typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_noea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_ea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_noea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_ea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_nosc_ts_nosa_ea:
	  typespec_attr
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_nosa_noea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_ea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_noea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_ea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_nosc_ts_sa_noea:
	  declspecs_nosc_ts_sa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_sa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_sa_noea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_sa_ea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_noea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_ea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_nosc_ts_sa_ea:
	  declspecs_nosc_ts_sa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_sa_noea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_sa_ea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_noea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_ea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_sc_nots_nosa_noea:
	  scspec
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE);
		  TREE_STATIC ($$) = 0; }
	| declspecs_sc_nots_nosa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_nots_nosa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_nosa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_nosa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_nots_nosa_ea:
	  declspecs_sc_nots_nosa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_nots_sa_noea:
	  declspecs_sc_nots_sa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_sa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_sa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_nots_sa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_sa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_sa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_nots_sa_ea:
	  declspecs_sc_nots_sa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_ts_nosa_noea:
	  declspecs_sc_ts_nosa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_nosa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_nosa_noea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_nosa_ea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_noea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_ea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_nosa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_nosa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_nosa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_nosa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_ts_nosa_ea:
	  declspecs_sc_ts_nosa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_nosa_noea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_nosa_ea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_noea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_ea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

declspecs_sc_ts_sa_noea:
	  declspecs_sc_ts_sa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_sa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_sa_noea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_sa_ea typespec_reserved_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_sa_noea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_sa_ea typespec_nonattr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_ts_sa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_sa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_sa_noea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_sa_ea scspec
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	;

declspecs_sc_ts_sa_ea:
	  declspecs_sc_ts_sa_noea attributes
		{ $$ = tree_cons ($2, NULL_TREE, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_sa_noea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_ts_sa_ea typespec_reserved_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_sa_noea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_sa_ea typespec_attr
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	;

/* Particular useful classes of declspecs.  */
declspecs_ts:
	  declspecs_nosc_ts_nosa_noea
	| declspecs_nosc_ts_nosa_ea
	| declspecs_nosc_ts_sa_noea
	| declspecs_nosc_ts_sa_ea
	| declspecs_sc_ts_nosa_noea
	| declspecs_sc_ts_nosa_ea
	| declspecs_sc_ts_sa_noea
	| declspecs_sc_ts_sa_ea
	;

declspecs_nots:
	  declspecs_nosc_nots_nosa_noea
	| declspecs_nosc_nots_nosa_ea
	| declspecs_nosc_nots_sa_noea
	| declspecs_nosc_nots_sa_ea
	| declspecs_sc_nots_nosa_noea
	| declspecs_sc_nots_nosa_ea
	| declspecs_sc_nots_sa_noea
	| declspecs_sc_nots_sa_ea
	;

declspecs_ts_nosa:
	  declspecs_nosc_ts_nosa_noea
	| declspecs_nosc_ts_nosa_ea
	| declspecs_sc_ts_nosa_noea
	| declspecs_sc_ts_nosa_ea
	;

declspecs_nots_nosa:
	  declspecs_nosc_nots_nosa_noea
	| declspecs_nosc_nots_nosa_ea
	| declspecs_sc_nots_nosa_noea
	| declspecs_sc_nots_nosa_ea
	;

declspecs_nosc_ts:
	  declspecs_nosc_ts_nosa_noea
	| declspecs_nosc_ts_nosa_ea
	| declspecs_nosc_ts_sa_noea
	| declspecs_nosc_ts_sa_ea
	;

declspecs_nosc_nots:
	  declspecs_nosc_nots_nosa_noea
	| declspecs_nosc_nots_nosa_ea
	| declspecs_nosc_nots_sa_noea
	| declspecs_nosc_nots_sa_ea
	;

declspecs_nosc:
	  declspecs_nosc_ts_nosa_noea
	| declspecs_nosc_ts_nosa_ea
	| declspecs_nosc_ts_sa_noea
	| declspecs_nosc_ts_sa_ea
	| declspecs_nosc_nots_nosa_noea
	| declspecs_nosc_nots_nosa_ea
	| declspecs_nosc_nots_sa_noea
	| declspecs_nosc_nots_sa_ea
	;

declspecs:
	  declspecs_nosc_nots_nosa_noea
	| declspecs_nosc_nots_nosa_ea
	| declspecs_nosc_nots_sa_noea
	| declspecs_nosc_nots_sa_ea
	| declspecs_nosc_ts_nosa_noea
	| declspecs_nosc_ts_nosa_ea
	| declspecs_nosc_ts_sa_noea
	| declspecs_nosc_ts_sa_ea
	| declspecs_sc_nots_nosa_noea
	| declspecs_sc_nots_nosa_ea
	| declspecs_sc_nots_sa_noea
	| declspecs_sc_nots_sa_ea
	| declspecs_sc_ts_nosa_noea
	| declspecs_sc_ts_nosa_ea
	| declspecs_sc_ts_sa_noea
	| declspecs_sc_ts_sa_ea
	;

/* A (possibly empty) sequence of type qualifiers and attributes.  */
maybe_type_quals_attrs:
	  /* empty */
		{ $$ = NULL_TREE; }
	| declspecs_nosc_nots
		{ $$ = $1; }
	;

/* A type specifier (but not a type qualifier).
   Once we have seen one of these in a declaration,
   if a typedef name appears then it is being redeclared.

   The _reserved versions start with a reserved word and may appear anywhere
   in the declaration specifiers; the _nonreserved versions may only
   appear before any other type specifiers, and after that are (if names)
   being redeclared.

   FIXME: should the _nonreserved version be restricted to names being
   redeclared only?  The other entries there relate only the GNU extensions
   and Objective C, and are historically parsed thus, and don't make sense
   after other type specifiers, but it might be cleaner to count them as
   _reserved.

   _attr means: specifiers that either end with attributes,
   or are such that any following attributes would
   be parsed as part of the specifier.

   _nonattr: specifiers.  */

typespec_nonattr:
	  typespec_reserved_nonattr
	| typespec_nonreserved_nonattr
	;

typespec_attr:
	  typespec_reserved_attr
	;

typespec_reserved_nonattr:
	  TYPESPEC
		{ OBJC_NEED_RAW_IDENTIFIER (1);	}
	| structsp_nonattr
	;

typespec_reserved_attr:
	  structsp_attr
	;

typespec_nonreserved_nonattr:
	  TYPENAME
		{ /* For a typedef name, record the meaning, not the name.
		     In case of `foo foo, bar;'.  */
		  $$ = lookup_name ($1); }
	| CLASSNAME protocolrefs
		{ $$ = get_static_reference ($1, $2); }
	| OBJECTNAME protocolrefs
		{ $$ = get_object_reference ($2); }

/* Make "<SomeProtocol>" equivalent to "id <SomeProtocol>"
   - nisse@lysator.liu.se */
        | non_empty_protocolrefs
                { $$ = get_object_reference ($1); }
	| typeof '(' expr ')'
		{ skip_evaluation--;
		  if (TREE_CODE ($3) == COMPONENT_REF
		      && DECL_C_BIT_FIELD (TREE_OPERAND ($3, 1)))
		    error ("`typeof' applied to a bit-field");
		  $$ = TREE_TYPE ($3); }
	| typeof '(' typename ')'
		{ skip_evaluation--; $$ = groktypename ($3); }
	;

/* typespec_nonreserved_attr does not exist.  */

initdecls:
	initdcl
	| initdecls ',' maybe_resetattrs initdcl
	;

notype_initdecls:
	notype_initdcl
	| notype_initdecls ',' maybe_resetattrs notype_initdcl
	;

maybeasm:
	  /* empty */
		{ $$ = NULL_TREE; }
	| ASM_KEYWORD '(' STRING ')'
		{ $$ = $3; }
	;

initdcl:
	  declarator maybeasm maybe_attribute '='
		{ $<ttype>$ = start_decl ($1, current_declspecs, 1,
					  chainon ($3, all_prefix_attributes));
		  start_init ($<ttype>$, $2, global_bindings_p ()); }
	  init
/* Note how the declaration of the variable is in effect while its init is parsed! */
		{ finish_init ();
		  finish_decl ($<ttype>5, $6, $2); }
	| declarator maybeasm maybe_attribute
		{ tree d = start_decl ($1, current_declspecs, 0,
				       chainon ($3, all_prefix_attributes));
		  finish_decl (d, NULL_TREE, $2);
                }
	;

notype_initdcl:
	  notype_declarator maybeasm maybe_attribute '='
		{ $<ttype>$ = start_decl ($1, current_declspecs, 1,
					  chainon ($3, all_prefix_attributes));
		  start_init ($<ttype>$, $2, global_bindings_p ()); }
	  init
/* Note how the declaration of the variable is in effect while its init is parsed! */
		{ finish_init ();
		  finish_decl ($<ttype>5, $6, $2); }
	| notype_declarator maybeasm maybe_attribute
		{ tree d = start_decl ($1, current_declspecs, 0,
				       chainon ($3, all_prefix_attributes));
		  finish_decl (d, NULL_TREE, $2); }
	;
/* the * rules are dummies to accept the Apollo extended syntax
   so that the header files compile. */
maybe_attribute:
      /* empty */
		{ $$ = NULL_TREE; }
	| attributes
		{ $$ = $1; }
	;

attributes:
      attribute
		{ $$ = $1; }
	| attributes attribute
		{ $$ = chainon ($1, $2); }
	;

attribute:
      ATTRIBUTE '(' '(' attribute_list ')' ')'
		{ $$ = $4; }
	;

attribute_list:
      attrib
		{ $$ = $1; }
	| attribute_list ',' attrib
		{ $$ = chainon ($1, $3); }
	;

attrib:
    /* empty */
		{ $$ = NULL_TREE; }
	| any_word
		{ $$ = build_tree_list ($1, NULL_TREE); }
	| any_word '(' IDENTIFIER ')'
		{ $$ = build_tree_list ($1, build_tree_list (NULL_TREE, $3)); }
	| any_word '(' IDENTIFIER ',' nonnull_exprlist ')'
		{ $$ = build_tree_list ($1, tree_cons (NULL_TREE, $3, $5)); }
	| any_word '(' exprlist ')'
		{ $$ = build_tree_list ($1, $3); }
	;

/* This still leaves out most reserved keywords,
   shouldn't we include them?  */

any_word:
	  identifier
	| scspec
	| TYPESPEC
	| TYPE_QUAL
	;

scspec:
	  STATIC
	| SCSPEC
	;

/* Initializers.  `init' is the entry point.  */

init:
	expr_no_commas
	| '{'
		{ really_start_incremental_init (NULL_TREE); }
	  initlist_maybe_comma '}'
		{ $$ = pop_init_level (0); }
	| error
		{ $$ = error_mark_node; }
	;

/* `initlist_maybe_comma' is the guts of an initializer in braces.  */
initlist_maybe_comma:
	  /* empty */
		{ if (pedantic)
		    pedwarn ("ISO C forbids empty initializer braces"); }
	| initlist1 maybecomma
	;

initlist1:
	  initelt
	| initlist1 ',' initelt
	;

/* `initelt' is a single element of an initializer.
   It may use braces.  */
initelt:
	  designator_list '=' initval
		{ if (pedantic && ! flag_isoc99)
		    pedwarn ("ISO C90 forbids specifying subobject to initialize"); }
	| designator initval
		{ if (pedantic)
		    pedwarn ("obsolete use of designated initializer without `='"); }
	| identifier ':'
		{ set_init_label ($1);
		  if (pedantic)
		    pedwarn ("obsolete use of designated initializer with `:'"); }
	  initval
		{}
	| initval
	;

initval:
	  '{'
		{ push_init_level (0); }
	  initlist_maybe_comma '}'
		{ process_init_element (pop_init_level (0)); }
	| expr_no_commas
		{ process_init_element ($1); }
	| error
	;

designator_list:
	  designator
	| designator_list designator
	;

designator:
	  '.' identifier
		{ set_init_label ($2); }
	| '[' expr_no_commas ELLIPSIS expr_no_commas ']'
		{ set_init_index ($2, $4);
		  if (pedantic)
		    pedwarn ("ISO C forbids specifying range of elements to initialize"); }
	| '[' expr_no_commas ']'
		{ set_init_index ($2, NULL_TREE); }
	;

nested_function:
	  declarator
		{ if (pedantic)
		    pedwarn ("ISO C forbids nested functions");

		  push_function_context ();
		  if (! start_function (current_declspecs, $1,
					all_prefix_attributes))
		    {
		      pop_function_context ();
		      YYERROR1;
		    }
		  parsing_iso_function_signature = false; /* Don't warn about nested functions.  */
		}
	   old_style_parm_decls save_location
		{ tree decl = current_function_decl;
		  DECL_SOURCE_LOCATION (decl) = $4;
		  store_parm_decls (); }
/* This used to use compstmt_or_error.
   That caused a bug with input `f(g) int g {}',
   where the use of YYERROR1 above caused an error
   which then was handled by compstmt_or_error.
   There followed a repeated execution of that same rule,
   which called YYERROR1 again, and so on.  */
	  compstmt
		{ tree decl = current_function_decl;
		  finish_function ();
		  pop_function_context ();
		  add_decl_stmt (decl); }
	;

notype_nested_function:
	  notype_declarator
		{ if (pedantic)
		    pedwarn ("ISO C forbids nested functions");

		  push_function_context ();
		  if (! start_function (current_declspecs, $1,
					all_prefix_attributes))
		    {
		      pop_function_context ();
		      YYERROR1;
		    }
		  parsing_iso_function_signature = false; /* Don't warn about nested functions.  */
		}
	  old_style_parm_decls save_location
		{ tree decl = current_function_decl;
		  DECL_SOURCE_LOCATION (decl) = $4;
		  store_parm_decls (); }
/* This used to use compstmt_or_error.
   That caused a bug with input `f(g) int g {}',
   where the use of YYERROR1 above caused an error
   which then was handled by compstmt_or_error.
   There followed a repeated execution of that same rule,
   which called YYERROR1 again, and so on.  */
	  compstmt
		{ tree decl = current_function_decl;
		  finish_function ();
		  pop_function_context ();
		  add_decl_stmt (decl); }
	;

/* Any kind of declarator (thus, all declarators allowed
   after an explicit typespec).  */

declarator:
	  after_type_declarator
	| notype_declarator
	;

/* A declarator that is allowed only after an explicit typespec.  */

after_type_declarator:
	  '(' maybe_attribute after_type_declarator ')'
		{ $$ = $2 ? tree_cons ($2, $3, NULL_TREE) : $3; }
	| after_type_declarator '(' parmlist_or_identifiers  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, $3, NULL_TREE); }
/*	| after_type_declarator '(' error ')'  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, NULL_TREE, NULL_TREE);
		  poplevel (0, 0, 0); }  */
	| after_type_declarator array_declarator  %prec '.'
		{ $$ = set_array_declarator_type ($2, $1, 0); }
	| '*' maybe_type_quals_attrs after_type_declarator  %prec UNARY
		{ $$ = make_pointer_declarator ($2, $3); }
	| TYPENAME
	| OBJECTNAME
	;

/* Kinds of declarator that can appear in a parameter list
   in addition to notype_declarator.  This is like after_type_declarator
   but does not allow a typedef name in parentheses as an identifier
   (because it would conflict with a function with that typedef as arg).  */
parm_declarator:
	  parm_declarator_starttypename
	| parm_declarator_nostarttypename
	;

parm_declarator_starttypename:
	  parm_declarator_starttypename '(' parmlist_or_identifiers  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, $3, NULL_TREE); }
/*	| parm_declarator_starttypename '(' error ')'  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, NULL_TREE, NULL_TREE);
		  poplevel (0, 0, 0); }  */
	| parm_declarator_starttypename array_declarator  %prec '.'
		{ $$ = set_array_declarator_type ($2, $1, 0); }
	| TYPENAME
	| OBJECTNAME
	;

parm_declarator_nostarttypename:
	  parm_declarator_nostarttypename '(' parmlist_or_identifiers  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, $3, NULL_TREE); }
/*	| parm_declarator_nostarttypename '(' error ')'  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, NULL_TREE, NULL_TREE);
		  poplevel (0, 0, 0); }  */
	| parm_declarator_nostarttypename array_declarator  %prec '.'
		{ $$ = set_array_declarator_type ($2, $1, 0); }
	| '*' maybe_type_quals_attrs parm_declarator_starttypename  %prec UNARY
		{ $$ = make_pointer_declarator ($2, $3); }
	| '*' maybe_type_quals_attrs parm_declarator_nostarttypename  %prec UNARY
		{ $$ = make_pointer_declarator ($2, $3); }
	| '(' maybe_attribute parm_declarator_nostarttypename ')'
		{ $$ = $2 ? tree_cons ($2, $3, NULL_TREE) : $3; }
	;

/* A declarator allowed whether or not there has been
   an explicit typespec.  These cannot redeclare a typedef-name.  */

notype_declarator:
	  notype_declarator '(' parmlist_or_identifiers  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, $3, NULL_TREE); }
/*	| notype_declarator '(' error ')'  %prec '.'
		{ $$ = build_nt (CALL_EXPR, $1, NULL_TREE, NULL_TREE);
		  poplevel (0, 0, 0); }  */
	| '(' maybe_attribute notype_declarator ')'
		{ $$ = $2 ? tree_cons ($2, $3, NULL_TREE) : $3; }
	| '*' maybe_type_quals_attrs notype_declarator  %prec UNARY
		{ $$ = make_pointer_declarator ($2, $3); }
	| notype_declarator array_declarator  %prec '.'
		{ $$ = set_array_declarator_type ($2, $1, 0); }
	| IDENTIFIER
	;

struct_head:
	  STRUCT
		{ $$ = NULL_TREE; }
	| STRUCT attributes
		{ $$ = $2; }
	;

union_head:
	  UNION
		{ $$ = NULL_TREE; }
	| UNION attributes
		{ $$ = $2; }
	;

enum_head:
	  ENUM
		{ $$ = NULL_TREE; }
	| ENUM attributes
		{ $$ = $2; }
	;

/* structsp_attr: struct/union/enum specifiers that either
   end with attributes, or are such that any following attributes would
   be parsed as part of the struct/union/enum specifier.

   structsp_nonattr: other struct/union/enum specifiers.  */

structsp_attr:
	  struct_head identifier '{'
		{ $$ = start_struct (RECORD_TYPE, $2);
		  /* Start scope of tag before parsing components.  */
		}
	  component_decl_list '}' maybe_attribute
		{ $$ = finish_struct ($<ttype>4, nreverse ($5),
				      chainon ($1, $7)); }
	| struct_head '{' component_decl_list '}' maybe_attribute
		{ $$ = finish_struct (start_struct (RECORD_TYPE, NULL_TREE),
				      nreverse ($3), chainon ($1, $5));
		}
	| union_head identifier '{'
		{ $$ = start_struct (UNION_TYPE, $2); }
	  component_decl_list '}' maybe_attribute
		{ $$ = finish_struct ($<ttype>4, nreverse ($5),
				      chainon ($1, $7)); }
	| union_head '{' component_decl_list '}' maybe_attribute
		{ $$ = finish_struct (start_struct (UNION_TYPE, NULL_TREE),
				      nreverse ($3), chainon ($1, $5));
		}
	| enum_head identifier '{'
		{ $$ = start_enum ($2); }
	  enumlist maybecomma_warn '}' maybe_attribute
		{ $$ = finish_enum ($<ttype>4, nreverse ($5),
				    chainon ($1, $8)); }
	| enum_head '{'
		{ $$ = start_enum (NULL_TREE); }
	  enumlist maybecomma_warn '}' maybe_attribute
		{ $$ = finish_enum ($<ttype>3, nreverse ($4),
				    chainon ($1, $7)); }
	;

structsp_nonattr:
	  struct_head identifier
		{ $$ = xref_tag (RECORD_TYPE, $2); }
	| union_head identifier
		{ $$ = xref_tag (UNION_TYPE, $2); }
	| enum_head identifier
		{ $$ = xref_tag (ENUMERAL_TYPE, $2);
		  /* In ISO C, enumerated types can be referred to
		     only if already defined.  */
		  if (pedantic && !COMPLETE_TYPE_P ($$))
		    pedwarn ("ISO C forbids forward references to `enum' types"); }
	;

maybecomma:
	  /* empty */
	| ','
	;

maybecomma_warn:
	  /* empty */
	| ','
		{ if (pedantic && ! flag_isoc99)
		    pedwarn ("comma at end of enumerator list"); }
	;

/* We chain the components in reverse order.  They are put in forward
   order in structsp_attr.

   Note that component_declarator returns single decls, so components
   and components_notype can use TREE_CHAIN directly, wheras components
   and components_notype return lists (of comma separated decls), so
   component_decl_list and component_decl_list2 must use chainon.

   The theory behind all this is that there will be more semicolon
   separated fields than comma separated fields, and so we'll be
   minimizing the number of node traversals required by chainon.  */

component_decl_list:
	  component_decl_list2
		{ $$ = $1; }
	| component_decl_list2 component_decl
		{ $$ = chainon ($2, $1);
		  pedwarn ("no semicolon at end of struct or union"); }
	;

component_decl_list2:	/* empty */
		{ $$ = NULL_TREE; }
	| component_decl_list2 component_decl ';'
		{ $$ = chainon ($2, $1); }
	| component_decl_list2 ';'
		{ if (pedantic)
		    pedwarn ("extra semicolon in struct or union specified"); }
	/* foo(sizeof(struct{ @defs(ClassName)})); */
	| DEFS '(' CLASSNAME ')'
		{ $$ = nreverse (get_class_ivars_from_name ($3)); }
	;

component_decl:
	  declspecs_nosc_ts setspecs components
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_ts setspecs
		{
		  /* Support for unnamed structs or unions as members of
		     structs or unions (which is [a] useful and [b] supports
		     MS P-SDK).  */
		  if (pedantic)
		    pedwarn ("ISO C doesn't support unnamed structs/unions");

		  $$ = grokfield(NULL, current_declspecs, NULL_TREE);
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_nots setspecs components_notype
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_nots
		{ if (pedantic)
		    pedwarn ("ISO C forbids member declarations with no members");
		  shadow_tag_warned ($1, pedantic);
		  $$ = NULL_TREE; }
	| error
		{ $$ = NULL_TREE; }
	| extension component_decl
		{ $$ = $2;
		  RESTORE_EXT_FLAGS ($1); }
	;

components:
	  component_declarator
	| components ',' maybe_resetattrs component_declarator
		{ TREE_CHAIN ($4) = $1; $$ = $4; }
	;

components_notype:
	  component_notype_declarator
	| components_notype ',' maybe_resetattrs component_notype_declarator
		{ TREE_CHAIN ($4) = $1; $$ = $4; }
	;

component_declarator:
	  declarator maybe_attribute
		{ $$ = grokfield ($1, current_declspecs, NULL_TREE);
		  decl_attributes (&$$,
				   chainon ($2, all_prefix_attributes), 0); }
	| declarator ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, current_declspecs, $3);
		  decl_attributes (&$$,
				   chainon ($4, all_prefix_attributes), 0); }
	| ':' expr_no_commas maybe_attribute
		{ $$ = grokfield (NULL_TREE, current_declspecs, $2);
		  decl_attributes (&$$,
				   chainon ($3, all_prefix_attributes), 0); }
	;

component_notype_declarator:
	  notype_declarator maybe_attribute
		{ $$ = grokfield ($1, current_declspecs, NULL_TREE);
		  decl_attributes (&$$,
				   chainon ($2, all_prefix_attributes), 0); }
	| notype_declarator ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, current_declspecs, $3);
		  decl_attributes (&$$,
				   chainon ($4, all_prefix_attributes), 0); }
	| ':' expr_no_commas maybe_attribute
		{ $$ = grokfield (NULL_TREE, current_declspecs, $2);
		  decl_attributes (&$$,
				   chainon ($3, all_prefix_attributes), 0); }
	;

/* We chain the enumerators in reverse order.
   They are put in forward order in structsp_attr.  */

enumlist:
	  enumerator
	| enumlist ',' enumerator
		{ if ($1 == error_mark_node)
		    $$ = $1;
		  else
		    TREE_CHAIN ($3) = $1, $$ = $3; }
	| error
		{ $$ = error_mark_node; }
	;


enumerator:
	  identifier
		{ $$ = build_enumerator ($1, NULL_TREE); }
	| identifier '=' expr_no_commas
		{ $$ = build_enumerator ($1, $3); }
	;

typename:
	  declspecs_nosc
		{ pending_xref_error ();
		  $<ttype>$ = $1; }
	  absdcl
		{ $$ = build_tree_list ($<ttype>2, $3); }
	;

absdcl:   /* an absolute declarator */
	/* empty */
		{ $$ = NULL_TREE; }
	| absdcl1
	;

absdcl_maybe_attribute:   /* absdcl maybe_attribute, but not just attributes */
	/* empty */
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 NULL_TREE),
					all_prefix_attributes); }
	| absdcl1
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $1),
					all_prefix_attributes); }
	| absdcl1_noea attributes
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $1),
					chainon ($2, all_prefix_attributes)); }
	;

absdcl1:  /* a nonempty absolute declarator */
	  absdcl1_ea
	| absdcl1_noea
	;

absdcl1_noea:
	  direct_absdcl1
	| '*' maybe_type_quals_attrs absdcl1_noea
		{ $$ = make_pointer_declarator ($2, $3); }
	;

absdcl1_ea:
	  '*' maybe_type_quals_attrs
		{ $$ = make_pointer_declarator ($2, NULL_TREE); }
	| '*' maybe_type_quals_attrs absdcl1_ea
		{ $$ = make_pointer_declarator ($2, $3); }
	;

direct_absdcl1:
	  '(' maybe_attribute absdcl1 ')'
		{ $$ = $2 ? tree_cons ($2, $3, NULL_TREE) : $3; }
	| direct_absdcl1 '(' parmlist
		{ $$ = build_nt (CALL_EXPR, $1, $3, NULL_TREE); }
	| direct_absdcl1 array_declarator
		{ $$ = set_array_declarator_type ($2, $1, 1); }
	| '(' parmlist
		{ $$ = build_nt (CALL_EXPR, NULL_TREE, $2, NULL_TREE); }
	| array_declarator
		{ $$ = set_array_declarator_type ($1, NULL_TREE, 1); }
	;

/* The [...] part of a declarator for an array type.  */

array_declarator:
	'[' maybe_type_quals_attrs expr_no_commas ']'
		{ $$ = build_array_declarator ($3, $2, 0, 0); }
	| '[' maybe_type_quals_attrs ']'
		{ $$ = build_array_declarator (NULL_TREE, $2, 0, 0); }
	| '[' maybe_type_quals_attrs '*' ']'
		{ $$ = build_array_declarator (NULL_TREE, $2, 0, 1); }
	| '[' STATIC maybe_type_quals_attrs expr_no_commas ']'
		{ $$ = build_array_declarator ($4, $3, 1, 0); }
	/* declspecs_nosc_nots is a synonym for type_quals_attrs.  */
	| '[' declspecs_nosc_nots STATIC expr_no_commas ']'
		{ $$ = build_array_declarator ($4, $2, 1, 0); }
	;

/* A nonempty series of declarations and statements (possibly followed by
   some labels) that can form the body of a compound statement.
   NOTE: we don't allow labels on declarations; this might seem like a
   natural extension, but there would be a conflict between attributes
   on the label and prefix attributes on the declaration.  */

stmts_and_decls:
	  lineno_stmt_decl_or_labels_ending_stmt
	| lineno_stmt_decl_or_labels_ending_decl
	| lineno_stmt_decl_or_labels_ending_label
		{
		  error ("label at end of compound statement");
		}
	| lineno_stmt_decl_or_labels_ending_error
	;

lineno_stmt_decl_or_labels_ending_stmt:
	  lineno_stmt
	| lineno_stmt_decl_or_labels_ending_stmt lineno_stmt
	| lineno_stmt_decl_or_labels_ending_decl lineno_stmt
	| lineno_stmt_decl_or_labels_ending_label lineno_stmt
	| lineno_stmt_decl_or_labels_ending_error lineno_stmt
	;

lineno_stmt_decl_or_labels_ending_decl:
	  lineno_decl
	| lineno_stmt_decl_or_labels_ending_stmt lineno_decl
		{
		  if ((pedantic && !flag_isoc99)
		      || warn_declaration_after_statement)
		    pedwarn_c90 ("ISO C90 forbids mixed declarations and code");
		}
	| lineno_stmt_decl_or_labels_ending_decl lineno_decl
	| lineno_stmt_decl_or_labels_ending_error lineno_decl
	;

lineno_stmt_decl_or_labels_ending_label:
	  lineno_label
	| lineno_stmt_decl_or_labels_ending_stmt lineno_label
	| lineno_stmt_decl_or_labels_ending_decl lineno_label
	| lineno_stmt_decl_or_labels_ending_label lineno_label
	| lineno_stmt_decl_or_labels_ending_error lineno_label
	;

lineno_stmt_decl_or_labels_ending_error:
	errstmt
	| lineno_stmt_decl_or_labels errstmt
	;

lineno_stmt_decl_or_labels:
	  lineno_stmt_decl_or_labels_ending_stmt
	| lineno_stmt_decl_or_labels_ending_decl
	| lineno_stmt_decl_or_labels_ending_label
	| lineno_stmt_decl_or_labels_ending_error
	;

errstmt:  error ';'
	;

pushlevel:  /* empty */
		{ pushlevel (0);
		  clear_last_expr ();
		  add_scope_stmt (/*begin_p=*/1, /*partial_p=*/0);
		}
	;

poplevel:  /* empty */
                {
		  if (c_dialect_objc ())
		    objc_clear_super_receiver ();
		  $$ = add_scope_stmt (/*begin_p=*/0, /*partial_p=*/0);
		}
        ;

/* Start and end blocks created for the new scopes of C99.  */
c99_block_start: /* empty */
		{ if (flag_isoc99)
		    {
		      $$ = c_begin_compound_stmt ();
		      pushlevel (0);
		      clear_last_expr ();
		      add_scope_stmt (/*begin_p=*/1, /*partial_p=*/0);
		    }
		  else
		    $$ = NULL_TREE;
		}
	;

/* Productions using c99_block_start and c99_block_end will need to do what's
   in compstmt: RECHAIN_STMTS ($1, COMPOUND_BODY ($1)); $$ = $2; where
   $1 is the value of c99_block_start and $2 of c99_block_end.  */
c99_block_end: /* empty */
                { if (flag_isoc99)
		    {
		      tree scope_stmt = add_scope_stmt (/*begin_p=*/0, /*partial_p=*/0);
		      $$ = poplevel (KEEP_MAYBE, 0, 0);
		      SCOPE_STMT_BLOCK (TREE_PURPOSE (scope_stmt))
			= SCOPE_STMT_BLOCK (TREE_VALUE (scope_stmt))
			= $$;
		    }
		  else
		    $$ = NULL_TREE; }
	;

/* Read zero or more forward-declarations for labels
   that nested functions can jump to.  */
maybe_label_decls:
	  /* empty */
	| label_decls
		{ if (pedantic)
		    pedwarn ("ISO C forbids label declarations"); }
	;

label_decls:
	  label_decl
	| label_decls label_decl
	;

label_decl:
	  LABEL identifiers_or_typenames ';'
		{ tree link;
		  for (link = $2; link; link = TREE_CHAIN (link))
		    {
		      tree label = declare_label (TREE_VALUE (link));
		      C_DECLARED_LABEL_FLAG (label) = 1;
		      add_decl_stmt (label);
		    }
		}
	;

/* This is the body of a function definition.
   It causes syntax errors to ignore to the next openbrace.  */
compstmt_or_error:
	  compstmt
		{}
	| error compstmt
	;

compstmt_start: '{' { compstmt_count++;
                      $$ = c_begin_compound_stmt (); }
        ;

compstmt_nostart: '}'
		{ $$ = convert (void_type_node, integer_zero_node); }
	| pushlevel maybe_label_decls compstmt_contents_nonempty '}' poplevel
		{ $$ = poplevel (KEEP_MAYBE, 0, 0);
		  SCOPE_STMT_BLOCK (TREE_PURPOSE ($5))
		    = SCOPE_STMT_BLOCK (TREE_VALUE ($5))
		    = $$; }
	;

compstmt_contents_nonempty:
	  stmts_and_decls
	| error
	;

compstmt_primary_start:
	'(' '{'
		{ if (current_function_decl == 0)
		    {
		      error ("braced-group within expression allowed only inside a function");
		      YYERROR;
		    }
		  /* We must force a BLOCK for this level
		     so that, if it is not expanded later,
		     there is a way to turn off the entire subtree of blocks
		     that are contained in it.  */
		  keep_next_level ();
		  compstmt_count++;
		  $$ = add_stmt (build_stmt (COMPOUND_STMT, last_tree));
		  last_expr_type = NULL_TREE;
		}
        ;

compstmt: compstmt_start compstmt_nostart
		{ RECHAIN_STMTS ($1, COMPOUND_BODY ($1));
		  last_expr_type = NULL_TREE;
                  $$ = $1; }
	;

/* Value is number of statements counted as of the closeparen.  */
simple_if:
	  if_prefix c99_block_lineno_labeled_stmt
                { c_finish_then (); }
/* Make sure c_expand_end_cond is run once
   for each call to c_expand_start_cond.
   Otherwise a crash is likely.  */
	| if_prefix error
	;

if_prefix:
	  /* We must build the IF_STMT node before parsing its
	     condition so that STMT_LINENO refers to the line
	     containing the "if", and not the line containing
	     the close-parenthesis.

	     c_begin_if_stmt returns the IF_STMT node, which
	     we later pass to c_expand_start_cond to fill
	     in the condition and other tidbits.  */
          IF
                { $<ttype>$ = c_begin_if_stmt (); }
            '(' expr ')'
		{ c_expand_start_cond (c_common_truthvalue_conversion ($4),
				       compstmt_count,$<ttype>2);
		  $<itype>$ = stmt_count;
		  if_stmt_locus = $<location>-1; }
        ;

/* This is a subroutine of stmt.
   It is used twice, once for valid DO statements
   and once for catching errors in parsing the end test.  */
do_stmt_start:
	  DO
		{ stmt_count++;
		  compstmt_count++;
		  c_in_iteration_stmt++;
		  $<ttype>$
		    = add_stmt (build_stmt (DO_STMT, NULL_TREE,
					    NULL_TREE));
		  /* In the event that a parse error prevents
		     parsing the complete do-statement, set the
		     condition now.  Otherwise, we can get crashes at
		     RTL-generation time.  */
		  DO_COND ($<ttype>$) = error_mark_node; }
	  c99_block_lineno_labeled_stmt WHILE
		{ $$ = $<ttype>2;
		  RECHAIN_STMTS ($$, DO_BODY ($$));
		  c_in_iteration_stmt--; }
	;

/* The forced readahead in here is because we might be at the end of a
   line, and the line and file won't be bumped until yylex absorbs the
   first token on the next line.  */

save_location:
		{ if (yychar == YYEMPTY)
		    yychar = YYLEX;
		  $$ = input_location; }
	;

lineno_labeled_stmt:
	  lineno_stmt
	| lineno_label lineno_labeled_stmt
	;

/* Like lineno_labeled_stmt, but a block in C99.  */
c99_block_lineno_labeled_stmt:
	  c99_block_start lineno_labeled_stmt c99_block_end
		{ if (flag_isoc99)
		    RECHAIN_STMTS ($1, COMPOUND_BODY ($1)); }
	;

lineno_stmt:
	  save_location stmt
		{ if ($2)
		    {
		      STMT_LINENO ($2) = $1.line;
		      /* ??? We currently have no way of recording
			 the filename for a statement.  This probably
			 matters little in practice at the moment,
			 but I suspect that problems will occur when
			 doing inlining at the tree level.  */
		    }
		}
	;

lineno_label:
	  save_location label
		{ if ($2)
		    {
		      STMT_LINENO ($2) = $1.line;
		    }
		}
	;

select_or_iter_stmt:
	  simple_if ELSE
		{ c_expand_start_else ();
		  $<itype>1 = stmt_count; }
	  c99_block_lineno_labeled_stmt
                { c_finish_else ();
		  c_expand_end_cond ();
		  if (extra_warnings && stmt_count == $<itype>1)
		    warning ("empty body in an else-statement"); }
	| simple_if %prec IF
		{ c_expand_end_cond ();
		  /* This warning is here instead of in simple_if, because we
		     do not want a warning if an empty if is followed by an
		     else statement.  Increment stmt_count so we don't
		     give a second error if this is a nested `if'.  */
		  if (extra_warnings && stmt_count++ == $<itype>1)
		    warning ("%Hempty body in an if-statement",
                             &if_stmt_locus); }
/* Make sure c_expand_end_cond is run once
   for each call to c_expand_start_cond.
   Otherwise a crash is likely.  */
	| simple_if ELSE error
		{ c_expand_end_cond (); }
       /* We must build the WHILE_STMT node before parsing its
	  condition so that STMT_LINENO refers to the line
	  containing the "while", and not the line containing
	  the close-parenthesis.

	  c_begin_while_stmt returns the WHILE_STMT node, which
	  we later pass to c_finish_while_stmt_cond to fill
	  in the condition and other tidbits.  */
	| WHILE
                { stmt_count++;
		  $<ttype>$ = c_begin_while_stmt (); }
	  '(' expr ')'
                { c_in_iteration_stmt++;
		  $4 = c_common_truthvalue_conversion ($4);
		  c_finish_while_stmt_cond
		    (c_common_truthvalue_conversion ($4), $<ttype>2);
		  $<ttype>$ = add_stmt ($<ttype>2); }
	  c99_block_lineno_labeled_stmt
                { c_in_iteration_stmt--;
		  RECHAIN_STMTS ($<ttype>6, WHILE_BODY ($<ttype>6)); }
	| do_stmt_start
	  '(' expr ')' ';'
                { DO_COND ($1) = c_common_truthvalue_conversion ($3); }
	| do_stmt_start error
		{ }
	| FOR
		{ $<ttype>$ = build_stmt (FOR_STMT, NULL_TREE, NULL_TREE,
					  NULL_TREE, NULL_TREE);
		  add_stmt ($<ttype>$); }
	  '(' for_init_stmt
		{ stmt_count++;
		  RECHAIN_STMTS ($<ttype>2, FOR_INIT_STMT ($<ttype>2)); }
	  xexpr ';'
                { if ($6)
		    FOR_COND ($<ttype>2)
		      = c_common_truthvalue_conversion ($6); }
	  xexpr ')'
                { c_in_iteration_stmt++;
		  FOR_EXPR ($<ttype>2) = $9; }
	  c99_block_lineno_labeled_stmt
                { RECHAIN_STMTS ($<ttype>2, FOR_BODY ($<ttype>2));
		  c_in_iteration_stmt--;}
	| SWITCH '(' expr ')'
		{ stmt_count++;
		  $<ttype>$ = c_start_case ($3);
		  c_in_case_stmt++; }
	  c99_block_lineno_labeled_stmt
                { c_finish_case ();
		  c_in_case_stmt--; }
	;

for_init_stmt:
	  xexpr ';'
		{ add_stmt (build_stmt (EXPR_STMT, $1)); }
	| decl
		{ check_for_loop_decls (); }
	;

/* Parse a single real statement, not including any labels.  */
stmt:
	  compstmt
		{ stmt_count++; $$ = $1; }
	| expr ';'
		{ stmt_count++;
		  $$ = c_expand_expr_stmt ($1); }
	| c99_block_start select_or_iter_stmt c99_block_end
		{ if (flag_isoc99)
		    RECHAIN_STMTS ($1, COMPOUND_BODY ($1));
		  $$ = NULL_TREE; }
	| BREAK ';'
	        { stmt_count++;
		if (!(c_in_iteration_stmt || c_in_case_stmt))
		  {
		    error ("break statement not within loop or switch");
		    $$ = NULL_TREE;
		  }
		else
		  $$ = add_stmt (build_break_stmt ()); }
	| CONTINUE ';'
                { stmt_count++;
		if (!c_in_iteration_stmt)
		  {
		    error ("continue statement not within a loop");
		    $$ = NULL_TREE;
		  }
		else
		  $$ = add_stmt (build_continue_stmt ()); }
	| RETURN ';'
                { stmt_count++;
		  $$ = c_expand_return (NULL_TREE); }
	| RETURN expr ';'
                { stmt_count++;
		  $$ = c_expand_return ($2); }
	| ASM_KEYWORD maybe_type_qual '(' expr ')' ';'
		{ stmt_count++;
		  $$ = simple_asm_stmt ($4); }
	/* This is the case with just output operands.  */
	| ASM_KEYWORD maybe_type_qual '(' expr ':' asm_operands ')' ';'
		{ stmt_count++;
		  $$ = build_asm_stmt ($2, $4, $6, NULL_TREE, NULL_TREE); }
	/* This is the case with input operands as well.  */
	| ASM_KEYWORD maybe_type_qual '(' expr ':' asm_operands ':'
	  asm_operands ')' ';'
		{ stmt_count++;
		  $$ = build_asm_stmt ($2, $4, $6, $8, NULL_TREE); }
	/* This is the case with clobbered registers as well.  */
	| ASM_KEYWORD maybe_type_qual '(' expr ':' asm_operands ':'
	  asm_operands ':' asm_clobbers ')' ';'
		{ stmt_count++;
		  $$ = build_asm_stmt ($2, $4, $6, $8, $10); }
	| GOTO identifier ';'
		{ tree decl;
		  stmt_count++;
		  decl = lookup_label ($2);
		  if (decl != 0)
		    {
		      TREE_USED (decl) = 1;
		      $$ = add_stmt (build_stmt (GOTO_STMT, decl));
		    }
		  else
		    $$ = NULL_TREE;
		}
	| GOTO '*' expr ';'
		{ if (pedantic)
		    pedwarn ("ISO C forbids `goto *expr;'");
		  stmt_count++;
		  $3 = convert (ptr_type_node, $3);
		  $$ = add_stmt (build_stmt (GOTO_STMT, $3)); }
	| ';'
		{ $$ = NULL_TREE; }
	| AT_THROW expr ';'
		{ stmt_count++;
		  $$ = objc_build_throw_stmt ($2);
		}
	| AT_THROW ';'
		{ stmt_count++;
		  $$ = objc_build_throw_stmt (NULL_TREE);
		}
	| objc_try_catch_stmt
		{ objc_build_finally_prologue (); }
	  objc_finally_block
		{ $$ = objc_build_try_catch_finally_stmt ($1, $3); }
	| AT_SYNCHRONIZED '(' expr ')'
		{ objc_build_synchronized_prologue ($3); }
	  compstmt
		{ $$ = objc_build_synchronized_epilogue (); }
	;

objc_try_catch_stmt:
	  objc_try_stmt
		{ objc_build_try_epilogue (1); }
	  objc_catch_list
		{ objc_build_catch_epilogue (); $$ = 1; }
	| objc_try_stmt
		{ objc_build_try_epilogue (0); $$ = 0; }
	;


objc_try_stmt:
	  AT_TRY
		{ objc_build_try_prologue (); }
	  compstmt
	;

objc_catch_list:
	  objc_catch_list objc_catch_block
	| objc_catch_block
	;

objc_catch_block:
	  AT_CATCH '(' parm ')'
		{ objc_build_catch_stmt ($3); }
	  compstmt
		{ stmt_count++; }
	;

objc_finally_block:
	  AT_FINALLY compstmt
	    { $$ = 1; }
	| /* NULL */
	    { $$ = 0; }
	;

/* Any kind of label, including jump labels and case labels.
   ANSI C accepts labels only before statements, but we allow them
   also at the end of a compound statement.  */

label:	  CASE expr_no_commas ':'
                { stmt_count++;
		  $$ = do_case ($2, NULL_TREE); }
	| CASE expr_no_commas ELLIPSIS expr_no_commas ':'
                { stmt_count++;
		  $$ = do_case ($2, $4); }
	| DEFAULT ':'
                { stmt_count++;
		  $$ = do_case (NULL_TREE, NULL_TREE); }
	| identifier save_location ':' maybe_attribute
		{ tree label = define_label ($2, $1);
		  stmt_count++;
		  if (label)
		    {
		      decl_attributes (&label, $4, 0);
		      $$ = add_stmt (build_stmt (LABEL_STMT, label));
		    }
		  else
		    $$ = NULL_TREE;
		}
	;

/* Either a type-qualifier or nothing.  First thing in an `asm' statement.  */

maybe_type_qual:
	/* empty */
		{ $$ = NULL_TREE; }
	| TYPE_QUAL
		{ }
	;

xexpr:
	/* empty */
		{ $$ = NULL_TREE; }
	| expr
	;

/* These are the operands other than the first string and colon
   in  asm ("addextend %2,%1": "=dm" (x), "0" (y), "g" (*x))  */
asm_operands: /* empty */
		{ $$ = NULL_TREE; }
	| nonnull_asm_operands
	;

nonnull_asm_operands:
	  asm_operand
	| nonnull_asm_operands ',' asm_operand
		{ $$ = chainon ($1, $3); }
	;

asm_operand:
	  STRING '(' expr ')'
		{ $$ = build_tree_list (build_tree_list (NULL_TREE, $1), $3); }
	| '[' identifier ']' STRING '(' expr ')'
		{ $2 = build_string (IDENTIFIER_LENGTH ($2),
				     IDENTIFIER_POINTER ($2));
		  $$ = build_tree_list (build_tree_list ($2, $4), $6); }
	;

asm_clobbers:
	  STRING
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE); }
	| asm_clobbers ',' STRING
		{ $$ = tree_cons (NULL_TREE, $3, $1); }
	;

/* This is what appears inside the parens in a function declarator.
   Its value is a list of ..._TYPE nodes.  Attributes must appear here
   to avoid a conflict with their appearance after an open parenthesis
   in an abstract declarator, as in
   "void bar (int (__attribute__((__mode__(SI))) int foo));".  */
parmlist:
	  maybe_attribute
		{ pushlevel (0);
		  declare_parm_level (); }
	  parmlist_1
		{ $$ = $3;
		  poplevel (0, 0, 0); }
	;

parmlist_1:
	  parmlist_2 ')'
	| parms ';'
		{ mark_forward_parm_decls (); }
	  maybe_attribute
		{ /* Dummy action so attributes are in known place
		     on parser stack.  */ }
	  parmlist_1
		{ $$ = $6; }
	| error ')'
		{ $$ = tree_cons (NULL_TREE, NULL_TREE, NULL_TREE); }
	;

/* This is what appears inside the parens in a function declarator.
   Is value is represented in the format that grokdeclarator expects.  */
parmlist_2:  /* empty */
		{ $$ = get_parm_info (0); }
	| ELLIPSIS
		{ $$ = get_parm_info (0);
		  /* Gcc used to allow this as an extension.  However, it does
		     not work for all targets, and thus has been disabled.
		     Also, since func (...) and func () are indistinguishable,
		     it caused problems with the code in expand_builtin which
		     tries to verify that BUILT_IN_NEXT_ARG is being used
		     correctly.  */
		  error ("ISO C requires a named argument before `...'");
		  parsing_iso_function_signature = true;
		}
	| parms
		{ $$ = get_parm_info (1);
		  parsing_iso_function_signature = true;
		}
	| parms ',' ELLIPSIS
		{ $$ = get_parm_info (0);
		  parsing_iso_function_signature = true;
		}
	;

parms:
	firstparm
		{ push_parm_decl ($1); }
	| parms ',' parm
		{ push_parm_decl ($3); }
	;

/* A single parameter declaration or parameter type name,
   as found in a parmlist.  */
parm:
	  declspecs_ts setspecs parm_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs notype_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs absdcl_maybe_attribute
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }

	| declspecs_nots setspecs absdcl_maybe_attribute
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	;

/* The first parm, which must suck attributes from off the top of the parser
   stack.  */
firstparm:
	  declspecs_ts_nosa setspecs_fp parm_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }
	| declspecs_ts_nosa setspecs_fp notype_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }
	| declspecs_ts_nosa setspecs_fp absdcl_maybe_attribute
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nots_nosa setspecs_fp notype_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $3),
					chainon ($4, all_prefix_attributes));
		  POP_DECLSPEC_STACK; }

	| declspecs_nots_nosa setspecs_fp absdcl_maybe_attribute
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	;

setspecs_fp:
	  setspecs
		{ prefix_attributes = chainon (prefix_attributes, $<ttype>-2);
		  all_prefix_attributes = prefix_attributes; }
	;

/* This is used in a function definition
   where either a parmlist or an identifier list is ok.
   Its value is a list of ..._TYPE nodes or a list of identifiers.  */
parmlist_or_identifiers:
	  maybe_attribute
		{ pushlevel (0);
		  declare_parm_level (); }
	  parmlist_or_identifiers_1
		{ $$ = $3;
		  poplevel (0, 0, 0); }
	;

parmlist_or_identifiers_1:
	  parmlist_1
	| identifiers ')'
		{ tree t;
		  for (t = $1; t; t = TREE_CHAIN (t))
		    if (TREE_VALUE (t) == NULL_TREE)
		      error ("`...' in old-style identifier list");
		  $$ = tree_cons (NULL_TREE, NULL_TREE, $1);

		  /* Make sure we have a parmlist after attributes.  */
		  if ($<ttype>-1 != 0
		      && (TREE_CODE ($$) != TREE_LIST
			  || TREE_PURPOSE ($$) == 0
			  || TREE_CODE (TREE_PURPOSE ($$)) != PARM_DECL))
		    YYERROR1;
		}
	;

/* A nonempty list of identifiers.  */
identifiers:
	IDENTIFIER
		{ $$ = build_tree_list (NULL_TREE, $1); }
	| identifiers ',' IDENTIFIER
		{ $$ = chainon ($1, build_tree_list (NULL_TREE, $3)); }
	;

/* A nonempty list of identifiers, including typenames.  */
identifiers_or_typenames:
	identifier
		{ $$ = build_tree_list (NULL_TREE, $1); }
	| identifiers_or_typenames ',' identifier
		{ $$ = chainon ($1, build_tree_list (NULL_TREE, $3)); }
	;

extension:
	EXTENSION
		{ $$ = SAVE_EXT_FLAGS();
		  pedantic = 0;
		  warn_pointer_arith = 0;
		  warn_traditional = 0;
		  flag_iso = 0; }
	;

/* Objective-C productions.  */

objcdef:
	  classdef
	| classdecl
	| aliasdecl
	| protocoldef
	| methoddef
	| END
		{
		  if (objc_implementation_context)
                    {
		      finish_class (objc_implementation_context);
		      objc_ivar_chain = NULL_TREE;
		      objc_implementation_context = NULL_TREE;
		    }
		  else
		    warning ("`@end' must appear in an implementation context");
		}
	;

/* A nonempty list of identifiers.  */
identifier_list:
	identifier
		{ $$ = build_tree_list (NULL_TREE, $1); }
	| identifier_list ',' identifier
		{ $$ = chainon ($1, build_tree_list (NULL_TREE, $3)); }
	;

classdecl:
	  CLASS identifier_list ';'
		{
		  objc_declare_class ($2);
		}
	;

aliasdecl:
	  ALIAS identifier identifier ';'
		{
		  objc_declare_alias ($2, $3);
		}
	;

superclass:
	  ':' identifier { $$ = $2; }
	| /* NULL */ %prec HYPERUNARY    { $$ = NULL_TREE; }
	;

class_ivars:
	  '{' ivar_decl_list '}'
	| /* NULL */
	;

classdef:
	  INTERFACE identifier superclass protocolrefs
		{
		  objc_interface_context = objc_ivar_context
		    = start_class (CLASS_INTERFACE_TYPE, $2, $3, $4);
                  objc_public_flag = 0;
		}
	  class_ivars
		{
                  continue_class (objc_interface_context);
		}
	  methodprotolist END
		{
		  finish_class (objc_interface_context);
		  objc_interface_context = NULL_TREE;
		}

	| IMPLEMENTATION identifier superclass
		{
		  objc_implementation_context = objc_ivar_context
		    = start_class (CLASS_IMPLEMENTATION_TYPE, $2, $3, NULL_TREE);
                  objc_public_flag = 0;
		}
	  class_ivars
		{
                  objc_ivar_chain
		    = continue_class (objc_implementation_context);
		}

	| INTERFACE identifier '(' identifier ')' protocolrefs
		{
		  objc_interface_context
		    = start_class (CATEGORY_INTERFACE_TYPE, $2, $4, $6);
                  continue_class (objc_interface_context);
		}
	  methodprotolist END
		{
		  finish_class (objc_interface_context);
		  objc_interface_context = NULL_TREE;
		}

	| IMPLEMENTATION identifier '(' identifier ')'
		{
		  objc_implementation_context
		    = start_class (CATEGORY_IMPLEMENTATION_TYPE, $2, $4, NULL_TREE);
                  objc_ivar_chain
		    = continue_class (objc_implementation_context);
		}
	;

protocoldef:
	  PROTOCOL identifier protocolrefs
		{
		  objc_pq_context = 1;
		  objc_interface_context
		    = start_protocol(PROTOCOL_INTERFACE_TYPE, $2, $3);
		}
	  methodprotolist END
		{
		  objc_pq_context = 0;
		  finish_protocol(objc_interface_context);
		  objc_interface_context = NULL_TREE;
		}
	/* The @protocol forward-declaration production introduces a
	   reduce/reduce conflict on ';', which should be resolved in
	   favor of the production 'identifier_list -> identifier'.  */
	| PROTOCOL identifier_list ';'
		{
		  objc_declare_protocols ($2);
		}
	;

protocolrefs:
	  /* empty */
		{
		  $$ = NULL_TREE;
		}
	| non_empty_protocolrefs
	;

non_empty_protocolrefs:
	  ARITHCOMPARE identifier_list ARITHCOMPARE
		{
		  if ($1 == LT_EXPR && $3 == GT_EXPR)
		    $$ = $2;
		  else
		    YYERROR1;
		}
	;

ivar_decl_list:
          ivar_decl_list visibility_spec ivar_decls
        | ivar_decls
        ;

visibility_spec:
	  PRIVATE { objc_public_flag = 2; }
	| PROTECTED { objc_public_flag = 0; }
	| PUBLIC { objc_public_flag = 1; }
	;

ivar_decls:
          /* empty */
		{
                  $$ = NULL_TREE;
                }
	| ivar_decls ivar_decl ';'
	| ivar_decls ';'
		{
                  if (pedantic)
		    pedwarn ("extra semicolon in struct or union specified");
                }
	;


/* There is a shift-reduce conflict here, because `components' may
   start with a `typename'.  It happens that shifting (the default resolution)
   does the right thing, because it treats the `typename' as part of
   a `typed_typespecs'.

   It is possible that this same technique would allow the distinction
   between `notype_initdecls' and `initdecls' to be eliminated.
   But I am being cautious and not trying it.  */

ivar_decl:
	declspecs_nosc_ts setspecs ivars
	        { $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_nots setspecs ivars
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| error
		{ $$ = NULL_TREE; }
	;

ivars:
	  /* empty */
		{ $$ = NULL_TREE; }
	| ivar_declarator
	| ivars ',' maybe_resetattrs ivar_declarator
	;

ivar_declarator:
	  declarator
		{
		  $$ = add_instance_variable (objc_ivar_context,
					      objc_public_flag,
					      $1, current_declspecs,
					      NULL_TREE);
                }
	| declarator ':' expr_no_commas
		{
		  $$ = add_instance_variable (objc_ivar_context,
					      objc_public_flag,
					      $1, current_declspecs, $3);
                }
	| ':' expr_no_commas
		{
		  $$ = add_instance_variable (objc_ivar_context,
					      objc_public_flag,
					      NULL_TREE,
					      current_declspecs, $2);
                }
	;

methodtype:
	  '+'
		{ objc_inherit_code = CLASS_METHOD_DECL; }
	| '-'
		{ objc_inherit_code = INSTANCE_METHOD_DECL; }
	;

methoddef:
	  methodtype
		{
		  objc_pq_context = 1;
		  if (!objc_implementation_context)
		    fatal_error ("method definition not in class context");
		}
	  methoddecl
		{
		  objc_pq_context = 0;
		  objc_add_method (objc_implementation_context,
				   $3,
				   objc_inherit_code == CLASS_METHOD_DECL);
		  start_method_def ($3);
		}
	  optarglist
		{
		  continue_method_def ();
		}
	  compstmt_or_error
		{
		  finish_method_def ();
		}
	;

/* the reason for the strange actions in this rule
 is so that notype_initdecls when reached via datadef
 can find a valid list of type and sc specs in $0. */

methodprotolist:
	  /* empty  */
	| methodprotolist methodproto
	| methodprotolist { $<ttype>$ = NULL_TREE; } datadef
	;

semi_or_error:
	  ';'
	| error
	;

methodproto:
	  methodtype
		{
		  /* Remember protocol qualifiers in prototypes.  */
		  objc_pq_context = 1;
		}
	  methoddecl
		{
		  /* Forget protocol qualifiers here.  */
		  objc_pq_context = 0;
		  objc_add_method (objc_interface_context,
				   $3,
				   objc_inherit_code == CLASS_METHOD_DECL);
		}
	  semi_or_error
	;

methoddecl:
	  '(' typename ')' unaryselector
		{
		  $$ = build_method_decl (objc_inherit_code, $2, $4, NULL_TREE);
		}

	| unaryselector
		{
		  $$ = build_method_decl (objc_inherit_code, NULL_TREE, $1, NULL_TREE);
		}

	| '(' typename ')' keywordselector optparmlist
		{
		  $$ = build_method_decl (objc_inherit_code, $2, $4, $5);
		}

	| keywordselector optparmlist
		{
		  $$ = build_method_decl (objc_inherit_code, NULL_TREE, $1, $2);
		}
	;

/* "optarglist" assumes that start_method_def has already been called...
   if it is not, the "xdecls" will not be placed in the proper scope */

optarglist:
	  /* empty */
	| ';' myxdecls
	;

/* to get around the following situation: "int foo (int a) int b; {}" that
   is synthesized when parsing "- a:a b:b; id c; id d; { ... }" */

myxdecls:
	  /* empty */
	| mydecls
	;

mydecls:
	mydecl
	| errstmt
	| mydecls mydecl
	| mydecl errstmt
	;

mydecl:
	declspecs_ts setspecs myparms ';'
		{ POP_DECLSPEC_STACK; }
	| declspecs_ts ';'
		{ shadow_tag ($1); }
	| declspecs_nots ';'
		{ pedwarn ("empty declaration"); }
	;

myparms:
	myparm
		{ push_parm_decl ($1); }
	| myparms ',' myparm
		{ push_parm_decl ($3); }
	;

/* A single parameter declaration or parameter type name,
   as found in a parmlist. DOES NOT ALLOW AN INITIALIZER OR ASMSPEC */

myparm:
	  parm_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $1),
					chainon ($2, all_prefix_attributes)); }
	| notype_declarator maybe_attribute
		{ $$ = build_tree_list (build_tree_list (current_declspecs,
							 $1),
					chainon ($2, all_prefix_attributes)); }
	| absdcl_maybe_attribute
		{ $$ = $1; }
	;

optparmlist:
	  /* empty */
		{
		  $$ = NULL_TREE;
		}
	| ',' ELLIPSIS
		{
		  /* oh what a kludge! */
		  $$ = objc_ellipsis_node;
		}
	| ','
		{
		  pushlevel (0);
		}
	  parmlist_2
		{
		  /* returns a tree list node generated by get_parm_info */
		  $$ = $3;
		  poplevel (0, 0, 0);
		}
	;

unaryselector:
	  selector
	;

keywordselector:
	  keyworddecl

	| keywordselector keyworddecl
		{
		  $$ = chainon ($1, $2);
		}
	;

selector:
	  IDENTIFIER
	| TYPENAME
	| CLASSNAME
	| OBJECTNAME
	| reservedwords
	;

reservedwords:
	  ENUM | STRUCT	| UNION	| IF | ELSE | WHILE | DO | FOR
	| SWITCH | CASE | DEFAULT | BREAK | CONTINUE | RETURN
	| GOTO | ASM_KEYWORD | SIZEOF | TYPEOF | ALIGNOF
	| TYPESPEC | TYPE_QUAL
	;

keyworddecl:
	  selector ':' '(' typename ')' identifier
		{
		  $$ = build_keyword_decl ($1, $4, $6);
		}

	| selector ':' identifier
		{
		  $$ = build_keyword_decl ($1, NULL_TREE, $3);
		}

	| ':' '(' typename ')' identifier
		{
		  $$ = build_keyword_decl (NULL_TREE, $3, $5);
		}

	| ':' identifier
		{
		  $$ = build_keyword_decl (NULL_TREE, NULL_TREE, $2);
		}
	;

messageargs:
	  selector
        | keywordarglist
	;

keywordarglist:
	  keywordarg
	| keywordarglist keywordarg
		{
		  $$ = chainon ($1, $2);
		}
	;


keywordexpr:
	  nonnull_exprlist
		{
		  if (TREE_CHAIN ($1) == NULL_TREE)
		    /* just return the expr., remove a level of indirection */
		    $$ = TREE_VALUE ($1);
                  else
		    /* we have a comma expr., we will collapse later */
		    $$ = $1;
		}
	;

keywordarg:
	  selector ':' keywordexpr
		{
		  $$ = build_tree_list ($1, $3);
		}
	| ':' keywordexpr
		{
		  $$ = build_tree_list (NULL_TREE, $2);
		}
	;

receiver:
	  expr
	| CLASSNAME
		{
		  $$ = get_class_reference ($1);
		}
	| TYPENAME
		{
		  $$ = get_class_reference ($1);
		}
	;

objcmessageexpr:
	  '[' receiver messageargs ']'
		{ $$ = build_tree_list ($2, $3); }
	;

selectorarg:
	  selector
        | keywordnamelist
	;

keywordnamelist:
	  keywordname
	| keywordnamelist keywordname
		{
		  $$ = chainon ($1, $2);
		}
	;

keywordname:
	  selector ':'
		{
		  $$ = build_tree_list ($1, NULL_TREE);
		}
	| ':'
		{
		  $$ = build_tree_list (NULL_TREE, NULL_TREE);
		}
	;

objcselectorexpr:
	  SELECTOR '(' selectorarg ')'
		{
		  $$ = $3;
		}
	;

objcprotocolexpr:
	  PROTOCOL '(' identifier ')'
		{
		  $$ = $3;
		}
	;

/* extension to support C-structures in the archiver */

objcencodeexpr:
	  ENCODE '(' typename ')'
		{
		  $$ = groktypename ($3);
		}
	;

%%

/* yylex() is a thin wrapper around c_lex(), all it does is translate
   cpplib.h's token codes into yacc's token codes.  */

static enum cpp_ttype last_token;

/* The reserved keyword table.  */
struct resword
{
  const char *word;
  ENUM_BITFIELD(rid) rid : 16;
  unsigned int disable   : 16;
};

/* Disable mask.  Keywords are disabled if (reswords[i].disable & mask) is
   _true_.  */
#define D_C89	0x01	/* not in C89 */
#define D_EXT	0x02	/* GCC extension */
#define D_EXT89	0x04	/* GCC extension incorporated in C99 */
#define D_OBJC	0x08	/* Objective C only */

static const struct resword reswords[] =
{
  { "_Bool",		RID_BOOL,	0 },
  { "_Complex",		RID_COMPLEX,	0 },
  { "__FUNCTION__",	RID_FUNCTION_NAME, 0 },
  { "__PRETTY_FUNCTION__", RID_PRETTY_FUNCTION_NAME, 0 },
  { "__alignof",	RID_ALIGNOF,	0 },
  { "__alignof__",	RID_ALIGNOF,	0 },
  { "__asm",		RID_ASM,	0 },
  { "__asm__",		RID_ASM,	0 },
  { "__attribute",	RID_ATTRIBUTE,	0 },
  { "__attribute__",	RID_ATTRIBUTE,	0 },
  { "__builtin_choose_expr", RID_CHOOSE_EXPR, 0 },
  { "__builtin_types_compatible_p", RID_TYPES_COMPATIBLE_P, 0 },
  { "__builtin_va_arg",	RID_VA_ARG,	0 },
  { "__complex",	RID_COMPLEX,	0 },
  { "__complex__",	RID_COMPLEX,	0 },
  { "__const",		RID_CONST,	0 },
  { "__const__",	RID_CONST,	0 },
  { "__extension__",	RID_EXTENSION,	0 },
  { "__func__",		RID_C99_FUNCTION_NAME, 0 },
  { "__imag",		RID_IMAGPART,	0 },
  { "__imag__",		RID_IMAGPART,	0 },
  { "__inline",		RID_INLINE,	0 },
  { "__inline__",	RID_INLINE,	0 },
  { "__label__",	RID_LABEL,	0 },
  { "__ptrbase",	RID_PTRBASE,	0 },
  { "__ptrbase__",	RID_PTRBASE,	0 },
  { "__ptrextent",	RID_PTREXTENT,	0 },
  { "__ptrextent__",	RID_PTREXTENT,	0 },
  { "__ptrvalue",	RID_PTRVALUE,	0 },
  { "__ptrvalue__",	RID_PTRVALUE,	0 },
  { "__real",		RID_REALPART,	0 },
  { "__real__",		RID_REALPART,	0 },
  { "__restrict",	RID_RESTRICT,	0 },
  { "__restrict__",	RID_RESTRICT,	0 },
  { "__signed",		RID_SIGNED,	0 },
  { "__signed__",	RID_SIGNED,	0 },
  { "__thread",		RID_THREAD,	0 },
  { "__typeof",		RID_TYPEOF,	0 },
  { "__typeof__",	RID_TYPEOF,	0 },
  { "__volatile",	RID_VOLATILE,	0 },
  { "__volatile__",	RID_VOLATILE,	0 },
  { "asm",		RID_ASM,	D_EXT },
  { "auto",		RID_AUTO,	0 },
  { "break",		RID_BREAK,	0 },
  { "case",		RID_CASE,	0 },
  { "char",		RID_CHAR,	0 },
  { "const",		RID_CONST,	0 },
  { "continue",		RID_CONTINUE,	0 },
  { "default",		RID_DEFAULT,	0 },
  { "do",		RID_DO,		0 },
  { "double",		RID_DOUBLE,	0 },
  { "else",		RID_ELSE,	0 },
  { "enum",		RID_ENUM,	0 },
  { "extern",		RID_EXTERN,	0 },
  { "float",		RID_FLOAT,	0 },
  { "for",		RID_FOR,	0 },
  { "goto",		RID_GOTO,	0 },
  { "if",		RID_IF,		0 },
  { "inline",		RID_INLINE,	D_EXT89 },
  { "int",		RID_INT,	0 },
  { "long",		RID_LONG,	0 },
  { "register",		RID_REGISTER,	0 },
  { "restrict",		RID_RESTRICT,	D_C89 },
  { "return",		RID_RETURN,	0 },
  { "short",		RID_SHORT,	0 },
  { "signed",		RID_SIGNED,	0 },
  { "sizeof",		RID_SIZEOF,	0 },
  { "static",		RID_STATIC,	0 },
  { "struct",		RID_STRUCT,	0 },
  { "switch",		RID_SWITCH,	0 },
  { "typedef",		RID_TYPEDEF,	0 },
  { "typeof",		RID_TYPEOF,	D_EXT },
  { "union",		RID_UNION,	0 },
  { "unsigned",		RID_UNSIGNED,	0 },
  { "void",		RID_VOID,	0 },
  { "volatile",		RID_VOLATILE,	0 },
  { "while",		RID_WHILE,	0 },
  { "id",		RID_ID,			D_OBJC },

  /* These objc keywords are recognized only immediately after
     an '@'.  */
  { "class",		RID_AT_CLASS,		D_OBJC },
  { "compatibility_alias", RID_AT_ALIAS,	D_OBJC },
  { "defs",		RID_AT_DEFS,		D_OBJC },
  { "encode",		RID_AT_ENCODE,		D_OBJC },
  { "end",		RID_AT_END,		D_OBJC },
  { "implementation",	RID_AT_IMPLEMENTATION,	D_OBJC },
  { "interface",	RID_AT_INTERFACE,	D_OBJC },
  { "private",		RID_AT_PRIVATE,		D_OBJC },
  { "protected",	RID_AT_PROTECTED,	D_OBJC },
  { "protocol",		RID_AT_PROTOCOL,	D_OBJC },
  { "public",		RID_AT_PUBLIC,		D_OBJC },
  { "selector",		RID_AT_SELECTOR,	D_OBJC },
  { "throw",		RID_AT_THROW,		D_OBJC },
  { "try",		RID_AT_TRY,		D_OBJC },
  { "catch",		RID_AT_CATCH,		D_OBJC },
  { "finally",		RID_AT_FINALLY,		D_OBJC },
  { "synchronized",	RID_AT_SYNCHRONIZED,	D_OBJC },
  /* These are recognized only in protocol-qualifier context
     (see above) */
  { "bycopy",		RID_BYCOPY,		D_OBJC },
  { "byref",		RID_BYREF,		D_OBJC },
  { "in",		RID_IN,			D_OBJC },
  { "inout",		RID_INOUT,		D_OBJC },
  { "oneway",		RID_ONEWAY,		D_OBJC },
  { "out",		RID_OUT,		D_OBJC },
};
#define N_reswords (sizeof reswords / sizeof (struct resword))

/* Table mapping from RID_* constants to yacc token numbers.
   Unfortunately we have to have entries for all the keywords in all
   three languages.  */
static const short rid_to_yy[RID_MAX] =
{
  /* RID_STATIC */	STATIC,
  /* RID_UNSIGNED */	TYPESPEC,
  /* RID_LONG */	TYPESPEC,
  /* RID_CONST */	TYPE_QUAL,
  /* RID_EXTERN */	SCSPEC,
  /* RID_REGISTER */	SCSPEC,
  /* RID_TYPEDEF */	SCSPEC,
  /* RID_SHORT */	TYPESPEC,
  /* RID_INLINE */	SCSPEC,
  /* RID_VOLATILE */	TYPE_QUAL,
  /* RID_SIGNED */	TYPESPEC,
  /* RID_AUTO */	SCSPEC,
  /* RID_RESTRICT */	TYPE_QUAL,

  /* C extensions */
  /* RID_COMPLEX */	TYPESPEC,
  /* RID_THREAD */	SCSPEC,

  /* C++ */
  /* RID_FRIEND */	0,
  /* RID_VIRTUAL */	0,
  /* RID_EXPLICIT */	0,
  /* RID_EXPORT */	0,
  /* RID_MUTABLE */	0,

  /* ObjC */
  /* RID_IN */		TYPE_QUAL,
  /* RID_OUT */		TYPE_QUAL,
  /* RID_INOUT */	TYPE_QUAL,
  /* RID_BYCOPY */	TYPE_QUAL,
  /* RID_BYREF */	TYPE_QUAL,
  /* RID_ONEWAY */	TYPE_QUAL,

  /* C */
  /* RID_INT */		TYPESPEC,
  /* RID_CHAR */	TYPESPEC,
  /* RID_FLOAT */	TYPESPEC,
  /* RID_DOUBLE */	TYPESPEC,
  /* RID_VOID */	TYPESPEC,
  /* RID_ENUM */	ENUM,
  /* RID_STRUCT */	STRUCT,
  /* RID_UNION */	UNION,
  /* RID_IF */		IF,
  /* RID_ELSE */	ELSE,
  /* RID_WHILE */	WHILE,
  /* RID_DO */		DO,
  /* RID_FOR */		FOR,
  /* RID_SWITCH */	SWITCH,
  /* RID_CASE */	CASE,
  /* RID_DEFAULT */	DEFAULT,
  /* RID_BREAK */	BREAK,
  /* RID_CONTINUE */	CONTINUE,
  /* RID_RETURN */	RETURN,
  /* RID_GOTO */	GOTO,
  /* RID_SIZEOF */	SIZEOF,

  /* C extensions */
  /* RID_ASM */		ASM_KEYWORD,
  /* RID_TYPEOF */	TYPEOF,
  /* RID_ALIGNOF */	ALIGNOF,
  /* RID_ATTRIBUTE */	ATTRIBUTE,
  /* RID_VA_ARG */	VA_ARG,
  /* RID_EXTENSION */	EXTENSION,
  /* RID_IMAGPART */	IMAGPART,
  /* RID_REALPART */	REALPART,
  /* RID_LABEL */	LABEL,
  /* RID_PTRBASE */	PTR_BASE,
  /* RID_PTREXTENT */	PTR_EXTENT,
  /* RID_PTRVALUE */	PTR_VALUE,

  /* RID_CHOOSE_EXPR */			CHOOSE_EXPR,
  /* RID_TYPES_COMPATIBLE_P */		TYPES_COMPATIBLE_P,

  /* RID_FUNCTION_NAME */		FUNC_NAME,
  /* RID_PRETTY_FUNCTION_NAME */	FUNC_NAME,
  /* RID_C99_FUNCTION_NAME */		FUNC_NAME,

  /* C++ */
  /* RID_BOOL */	TYPESPEC,
  /* RID_WCHAR */	0,
  /* RID_CLASS */	0,
  /* RID_PUBLIC */	0,
  /* RID_PRIVATE */	0,
  /* RID_PROTECTED */	0,
  /* RID_TEMPLATE */	0,
  /* RID_NULL */	0,
  /* RID_CATCH */	0,
  /* RID_DELETE */	0,
  /* RID_FALSE */	0,
  /* RID_NAMESPACE */	0,
  /* RID_NEW */		0,
  /* RID_OFFSETOF */    0,
  /* RID_OPERATOR */	0,
  /* RID_THIS */	0,
  /* RID_THROW */	0,
  /* RID_TRUE */	0,
  /* RID_TRY */		0,
  /* RID_TYPENAME */	0,
  /* RID_TYPEID */	0,
  /* RID_USING */	0,

  /* casts */
  /* RID_CONSTCAST */	0,
  /* RID_DYNCAST */	0,
  /* RID_REINTCAST */	0,
  /* RID_STATCAST */	0,

  /* Objective C */
  /* RID_ID */			OBJECTNAME,
  /* RID_AT_ENCODE */		ENCODE,
  /* RID_AT_END */		END,
  /* RID_AT_CLASS */		CLASS,
  /* RID_AT_ALIAS */		ALIAS,
  /* RID_AT_DEFS */		DEFS,
  /* RID_AT_PRIVATE */		PRIVATE,
  /* RID_AT_PROTECTED */	PROTECTED,
  /* RID_AT_PUBLIC */		PUBLIC,
  /* RID_AT_PROTOCOL */		PROTOCOL,
  /* RID_AT_SELECTOR */		SELECTOR,
  /* RID_AT_THROW */		AT_THROW,
  /* RID_AT_TRY */		AT_TRY,
  /* RID_AT_CATCH */		AT_CATCH,
  /* RID_AT_FINALLY */		AT_FINALLY,
  /* RID_AT_SYNCHRONIZED */	AT_SYNCHRONIZED,
  /* RID_AT_INTERFACE */	INTERFACE,
  /* RID_AT_IMPLEMENTATION */	IMPLEMENTATION
};

static void
init_reswords (void)
{
  unsigned int i;
  tree id;
  int mask = (flag_isoc99 ? 0 : D_C89)
	      | (flag_no_asm ? (flag_isoc99 ? D_EXT : D_EXT|D_EXT89) : 0);

  if (!c_dialect_objc ())
     mask |= D_OBJC;

  ridpointers = ggc_calloc ((int) RID_MAX, sizeof (tree));
  for (i = 0; i < N_reswords; i++)
    {
      /* If a keyword is disabled, do not enter it into the table
	 and so create a canonical spelling that isn't a keyword.  */
      if (reswords[i].disable & mask)
	continue;

      id = get_identifier (reswords[i].word);
      C_RID_CODE (id) = reswords[i].rid;
      C_IS_RESERVED_WORD (id) = 1;
      ridpointers [(int) reswords[i].rid] = id;
    }
}

#define NAME(type) cpp_type2name (type)

static void
yyerror (const char *msgid)
{
  c_parse_error (msgid, last_token, yylval.ttype);
}

static int
yylexname (void)
{
  tree decl;

  int objc_force_identifier = objc_need_raw_identifier;
  OBJC_NEED_RAW_IDENTIFIER (0);

  if (C_IS_RESERVED_WORD (yylval.ttype))
    {
      enum rid rid_code = C_RID_CODE (yylval.ttype);

      /* Turn non-typedefed refs to "id" into plain identifiers; this
	 allows constructs like "void foo(id id);" to work.  */
      if (rid_code == RID_ID)
      {
	decl = lookup_name (yylval.ttype);
	if (decl == NULL_TREE || TREE_CODE (decl) != TYPE_DECL)
	  return IDENTIFIER;
      }

      if (!OBJC_IS_AT_KEYWORD (rid_code)
	  && (!OBJC_IS_PQ_KEYWORD (rid_code) || objc_pq_context))
      {
	/* Return the canonical spelling for this keyword.  */
	yylval.ttype = ridpointers[(int) rid_code];
	return rid_to_yy[(int) rid_code];
      }
    }

  decl = lookup_name (yylval.ttype);
  if (decl)
    {
      if (TREE_CODE (decl) == TYPE_DECL)
	return TYPENAME;
    }
  else
    {
      tree objc_interface_decl = is_class_name (yylval.ttype);
      /* ObjC class names are in the same namespace as variables and
	 typedefs, and hence are shadowed by local declarations.  */
      if (objc_interface_decl
	  && (global_bindings_p ()
	      || (!objc_force_identifier && !decl)))
	{
	  yylval.ttype = objc_interface_decl;
	  return CLASSNAME;
	}
    }

  return IDENTIFIER;
}

static inline int
_yylex (void)
{
 get_next:
  last_token = c_lex (&yylval.ttype);
  switch (last_token)
    {
    case CPP_EQ:					return '=';
    case CPP_NOT:					return '!';
    case CPP_GREATER:	yylval.code = GT_EXPR;		return ARITHCOMPARE;
    case CPP_LESS:	yylval.code = LT_EXPR;		return ARITHCOMPARE;
    case CPP_PLUS:	yylval.code = PLUS_EXPR;	return '+';
    case CPP_MINUS:	yylval.code = MINUS_EXPR;	return '-';
    case CPP_MULT:	yylval.code = MULT_EXPR;	return '*';
    case CPP_DIV:	yylval.code = TRUNC_DIV_EXPR;	return '/';
    case CPP_MOD:	yylval.code = TRUNC_MOD_EXPR;	return '%';
    case CPP_AND:	yylval.code = BIT_AND_EXPR;	return '&';
    case CPP_OR:	yylval.code = BIT_IOR_EXPR;	return '|';
    case CPP_XOR:	yylval.code = BIT_XOR_EXPR;	return '^';
    case CPP_RSHIFT:	yylval.code = RSHIFT_EXPR;	return RSHIFT;
    case CPP_LSHIFT:	yylval.code = LSHIFT_EXPR;	return LSHIFT;

    case CPP_COMPL:					return '~';
    case CPP_AND_AND:					return ANDAND;
    case CPP_OR_OR:					return OROR;
    case CPP_QUERY:					return '?';
    case CPP_OPEN_PAREN:				return '(';
    case CPP_EQ_EQ:	yylval.code = EQ_EXPR;		return EQCOMPARE;
    case CPP_NOT_EQ:	yylval.code = NE_EXPR;		return EQCOMPARE;
    case CPP_GREATER_EQ:yylval.code = GE_EXPR;		return ARITHCOMPARE;
    case CPP_LESS_EQ:	yylval.code = LE_EXPR;		return ARITHCOMPARE;

    case CPP_PLUS_EQ:	yylval.code = PLUS_EXPR;	return ASSIGN;
    case CPP_MINUS_EQ:	yylval.code = MINUS_EXPR;	return ASSIGN;
    case CPP_MULT_EQ:	yylval.code = MULT_EXPR;	return ASSIGN;
    case CPP_DIV_EQ:	yylval.code = TRUNC_DIV_EXPR;	return ASSIGN;
    case CPP_MOD_EQ:	yylval.code = TRUNC_MOD_EXPR;	return ASSIGN;
    case CPP_AND_EQ:	yylval.code = BIT_AND_EXPR;	return ASSIGN;
    case CPP_OR_EQ:	yylval.code = BIT_IOR_EXPR;	return ASSIGN;
    case CPP_XOR_EQ:	yylval.code = BIT_XOR_EXPR;	return ASSIGN;
    case CPP_RSHIFT_EQ:	yylval.code = RSHIFT_EXPR;	return ASSIGN;
    case CPP_LSHIFT_EQ:	yylval.code = LSHIFT_EXPR;	return ASSIGN;

    case CPP_OPEN_SQUARE:				return '[';
    case CPP_CLOSE_SQUARE:				return ']';
    case CPP_OPEN_BRACE:				return '{';
    case CPP_CLOSE_BRACE:				return '}';
    case CPP_ELLIPSIS:					return ELLIPSIS;

    case CPP_PLUS_PLUS:					return PLUSPLUS;
    case CPP_MINUS_MINUS:				return MINUSMINUS;
    case CPP_DEREF:					return POINTSAT;
    case CPP_DOT:					return '.';

      /* The following tokens may affect the interpretation of any
	 identifiers following, if doing Objective-C.  */
    case CPP_COLON:		OBJC_NEED_RAW_IDENTIFIER (0);	return ':';
    case CPP_COMMA:		OBJC_NEED_RAW_IDENTIFIER (0);	return ',';
    case CPP_CLOSE_PAREN:	OBJC_NEED_RAW_IDENTIFIER (0);	return ')';
    case CPP_SEMICOLON:		OBJC_NEED_RAW_IDENTIFIER (0);	return ';';

    case CPP_EOF:
      return 0;

    case CPP_NAME:
      return yylexname ();

    case CPP_AT_NAME:
      /* This only happens in Objective-C; it must be a keyword.  */
      return rid_to_yy [(int) C_RID_CODE (yylval.ttype)];

    case CPP_NUMBER:
    case CPP_CHAR:
    case CPP_WCHAR:
      return CONSTANT;

    case CPP_STRING:
    case CPP_WSTRING:
      return STRING;

    case CPP_OBJC_STRING:
      return OBJC_STRING;

      /* These tokens are C++ specific (and will not be generated
         in C mode, but let's be cautious).  */
    case CPP_SCOPE:
    case CPP_DEREF_STAR:
    case CPP_DOT_STAR:
    case CPP_MIN_EQ:
    case CPP_MAX_EQ:
    case CPP_MIN:
    case CPP_MAX:
      /* These tokens should not survive translation phase 4.  */
    case CPP_HASH:
    case CPP_PASTE:
      error ("syntax error at '%s' token", NAME(last_token));
      goto get_next;

    default:
      abort ();
    }
  /* NOTREACHED */
}

static int
yylex (void)
{
  int r;
  timevar_push (TV_LEX);
  r = _yylex();
  timevar_pop (TV_LEX);
  return r;
}

/* Function used when yydebug is set, to print a token in more detail.  */

static void
yyprint (FILE *file, int yychar, YYSTYPE yyl)
{
  tree t = yyl.ttype;

  fprintf (file, " [%s]", NAME(last_token));

  switch (yychar)
    {
    case IDENTIFIER:
    case TYPENAME:
    case OBJECTNAME:
    case TYPESPEC:
    case TYPE_QUAL:
    case SCSPEC:
    case STATIC:
      if (IDENTIFIER_POINTER (t))
	fprintf (file, " `%s'", IDENTIFIER_POINTER (t));
      break;

    case CONSTANT:
      fprintf (file, " %s", GET_MODE_NAME (TYPE_MODE (TREE_TYPE (t))));
      if (TREE_CODE (t) == INTEGER_CST)
	{
	  fputs (" ", file);
	  fprintf (file, HOST_WIDE_INT_PRINT_DOUBLE_HEX,
		   TREE_INT_CST_HIGH (t), TREE_INT_CST_LOW (t));
	}
      break;
    }
}

/* This is not the ideal place to put these, but we have to get them out
   of c-lex.c because cp/lex.c has its own versions.  */

/* Parse the file.  */
void
c_parse_file (void)
{
  yyparse ();
  /* In case there were missing closebraces, get us back to the global
     binding level.  */
  while (! global_bindings_p ())
    poplevel (0, 0, 0);
  /* __FUNCTION__ is defined at file scope ("").  This
     call may not be necessary as my tests indicate it
     still works without it.  */
  finish_fname_decls ();

  if (malloced_yyss)
    {
      free (malloced_yyss);
      free (malloced_yyvs);
      malloced_yyss = 0;
    }
}

#include "gt-c-parse.h"
