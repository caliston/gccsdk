/* YACC parser for C syntax and for Objective C.  -*-c-*-
   Copyright (C) 1987, 1988, 1989, 1992, 1993, 1994, 1995, 1996,
   1997, 1998, 1999, 2000, 2001 Free Software Foundation, Inc.

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
   ifobjc ... end ifobjc  conditionals contain code for Objective C only.
   ifc ... end ifc  conditionals contain code for C only.
   Sed commands in Makefile.in are used to convert this file into
   c-parse.y and into objc-parse.y.  */

/* To whomever it may concern: I have heard that such a thing was once
   written by AT&T, but I have never seen it.  */

%expect 10 /* shift/reduce conflicts, and no reduce/reduce conflicts.  */

%{
#include "config.h"
#include "system.h"
#include "tree.h"
#include "input.h"
#include "cpplib.h"
#include "intl.h"
#include "timevar.h"
#include "c-lex.h"
#include "c-tree.h"
#include "c-pragma.h"
#include "flags.h"
#include "output.h"
#include "toplev.h"
#include "ggc.h"
  
#ifdef MULTIBYTE_CHARS
#include <locale.h>
#endif


/* Like YYERROR but do call yyerror.  */
#define YYERROR1 { yyerror ("syntax error"); YYERROR; }

/* Cause the "yydebug" variable to be defined.  */
#define YYDEBUG 1

/* Rename the "yyparse" function so that we can override it elsewhere.  */
#define yyparse yyparse_1
%}

%start program

%union {long itype; tree ttype; enum tree_code code;
	const char *filename; int lineno; }

/* All identifiers that are not reserved words
   and are not declared typedefs in the current block */
%token IDENTIFIER

/* All identifiers that are declared typedefs in the current block.
   In some contexts, they are treated just like IDENTIFIER,
   but they can also serve as typespecs in declarations.  */
%token TYPENAME

/* Reserved words that specify storage class.
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token SCSPEC

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
%token REALPART IMAGPART VA_ARG
%token PTR_VALUE PTR_BASE PTR_EXTENT

/* function name can be a string const or a var decl. */
%token STRING_FUNC_NAME VAR_FUNC_NAME

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

%type <code> unop
%type <ttype> ENUM STRUCT UNION IF ELSE WHILE DO FOR SWITCH CASE DEFAULT
%type <ttype> BREAK CONTINUE RETURN GOTO ASM_KEYWORD SIZEOF TYPEOF ALIGNOF

%type <ttype> identifier IDENTIFIER TYPENAME CONSTANT expr nonnull_exprlist exprlist
%type <ttype> expr_no_commas cast_expr unary_expr primary string STRING
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

%type <ttype> SCSPEC TYPESPEC TYPE_QUAL maybe_type_qual
%type <ttype> initdecls notype_initdecls initdcl notype_initdcl
%type <ttype> init maybeasm
%type <ttype> asm_operands nonnull_asm_operands asm_operand asm_clobbers
%type <ttype> maybe_attribute attributes attribute attribute_list attrib
%type <ttype> any_word extension

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

%type <itype> setspecs setspecs_fp

%type <filename> save_filename
%type <lineno> save_lineno


%{
/* Number of statements (loosely speaking) and compound statements 
   seen so far.  */
static int stmt_count;
static int compstmt_count;
  
/* Input file and line number of the end of the body of last simple_if;
   used by the stmt-rule immediately after simple_if returns.  */
static const char *if_stmt_file;
static int if_stmt_line;

/* List of types and structure classes of the current declaration.  */
static tree current_declspecs = NULL_TREE;
static tree prefix_attributes = NULL_TREE;

/* List of all the attributes applying to the identifier currently being
   declared; includes prefix_attributes and possibly some more attributes
   just after a comma.  */
static tree all_prefix_attributes = NULL_TREE;

/* Stack of saved values of current_declspecs, prefix_attributes and
   all_prefix_attributes.  */
static tree declspec_stack;

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
#define SAVE_WARN_FLAGS()	\
	size_int (pedantic | (warn_pointer_arith << 1))
#define RESTORE_WARN_FLAGS(tval) \
  do {                                     \
    int val = tree_low_cst (tval, 0);      \
    pedantic = val & 1;                    \
    warn_pointer_arith = (val >> 1) & 1;   \
  } while (0)


#define OBJC_NEED_RAW_IDENTIFIER(VAL)	/* nothing */

/* Tell yyparse how to print a token's value, if yydebug is set.  */

#define YYPRINT(FILE,YYCHAR,YYLVAL) yyprint(FILE,YYCHAR,YYLVAL)

static void yyprint	  PARAMS ((FILE *, int, YYSTYPE));
static void yyerror	  PARAMS ((const char *));
static int yylexname	  PARAMS ((void));
static inline int _yylex  PARAMS ((void));
static int  yylex	  PARAMS ((void));
static void init_reswords PARAMS ((void));

/* Add GC roots for variables local to this file.  */
void
c_parse_init ()
{
  init_reswords ();

  ggc_add_tree_root (&declspec_stack, 1);
  ggc_add_tree_root (&current_declspecs, 1);
  ggc_add_tree_root (&prefix_attributes, 1);
  ggc_add_tree_root (&all_prefix_attributes, 1);
}

%}

%%
program: /* empty */
		{ if (pedantic)
		    pedwarn ("ISO C forbids an empty source file");
		  finish_file ();
		}
	| extdefs
		{
		  /* In case there were missing closebraces,
		     get us back to the global binding level.  */
		  while (! global_bindings_p ())
		    poplevel (0, 0, 0);
		  finish_fname_decls ();
                  finish_file ();
		}
	;

/* the reason for the strange actions in this rule
 is so that notype_initdecls when reached via datadef
 can find a valid list of type and sc specs in $0. */

extdefs:
	{$<ttype>$ = NULL_TREE; } extdef
	| extdefs {$<ttype>$ = NULL_TREE; ggc_collect(); } extdef
	;

extdef:
	fndef
	| datadef
	| ASM_KEYWORD '(' expr ')' ';'
		{ STRIP_NOPS ($3);
		  if ((TREE_CODE ($3) == ADDR_EXPR
		       && TREE_CODE (TREE_OPERAND ($3, 0)) == STRING_CST)
		      || TREE_CODE ($3) == STRING_CST)
		    assemble_asm ($3);
		  else
		    error ("argument of `asm' is not a constant string"); }
	| extension extdef
		{ RESTORE_WARN_FLAGS ($1); }
	;

datadef:
	  setspecs notype_initdecls ';'
		{ if (pedantic)
		    error ("ISO C forbids data definition with no type or storage class");
		  else if (!flag_traditional)
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
	  old_style_parm_decls
		{ store_parm_decls (); }
	  save_filename save_lineno compstmt_or_error
		{ DECL_SOURCE_FILE (current_function_decl) = $7;
		  DECL_SOURCE_LINE (current_function_decl) = $8;
		  finish_function (0); 
		  POP_DECLSPEC_STACK; }
	| declspecs_ts setspecs declarator error
		{ POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_declarator
		{ if (! start_function (current_declspecs, $3,
					all_prefix_attributes))
		    YYERROR1;
		}
	  old_style_parm_decls
		{ store_parm_decls (); }
	  save_filename save_lineno compstmt_or_error
		{ DECL_SOURCE_FILE (current_function_decl) = $7;
		  DECL_SOURCE_LINE (current_function_decl) = $8;
		  finish_function (0); 
		  POP_DECLSPEC_STACK; }
	| declspecs_nots setspecs notype_declarator error
		{ POP_DECLSPEC_STACK; }
	| setspecs notype_declarator
		{ if (! start_function (NULL_TREE, $2,
					all_prefix_attributes))
		    YYERROR1;
		}
	  old_style_parm_decls
		{ store_parm_decls (); }
	  save_filename save_lineno compstmt_or_error
		{ DECL_SOURCE_FILE (current_function_decl) = $6;
		  DECL_SOURCE_LINE (current_function_decl) = $7;
		  finish_function (0); 
		  POP_DECLSPEC_STACK; }
	| setspecs notype_declarator error
		{ POP_DECLSPEC_STACK; }
	;

identifier:
	IDENTIFIER
	| TYPENAME
	;

unop:     '&'
		{ $$ = ADDR_EXPR; }
	| '-'
		{ $$ = NEGATE_EXPR; }
	| '+'
		{ $$ = CONVERT_EXPR;
  if (warn_traditional && !in_system_header)
    warning ("traditional C rejects the unary plus operator");
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
		  RESTORE_WARN_FLAGS ($1); }
	| unop cast_expr  %prec UNARY
		{ $$ = build_unary_op ($1, $2, 0);
		  overflow_warning ($$); }
	/* Refer to the address of a label as a pointer.  */
	| ANDAND identifier
		{ $$ = finish_label_address_expr ($2); }
/* This seems to be impossible on some machines, so let's turn it off.
   You can use __builtin_next_arg to find the anonymous stack args.
	| '&' ELLIPSIS
		{ tree types = TYPE_ARG_TYPES (TREE_TYPE (current_function_decl));
		  $$ = error_mark_node;
		  if (TREE_VALUE (tree_last (types)) == void_type_node)
		    error ("`&...' used in function with fixed number of arguments");
		  else
		    {
		      if (pedantic)
			pedwarn ("ISO C forbids `&...'");
		      $$ = tree_last (DECL_ARGUMENTS (current_function_decl));
		      $$ = build_unary_op (ADDR_EXPR, $$, 0);
		    } }
*/
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
		{ $1 = truthvalue_conversion (default_conversion ($1));
		  skip_evaluation += $1 == boolean_false_node; }
	  expr_no_commas
		{ skip_evaluation -= $1 == boolean_false_node;
		  $$ = parser_build_binary_op (TRUTH_ANDIF_EXPR, $1, $4); }
	| expr_no_commas OROR
		{ $1 = truthvalue_conversion (default_conversion ($1));
		  skip_evaluation += $1 == boolean_true_node; }
	  expr_no_commas
		{ skip_evaluation -= $1 == boolean_true_node;
		  $$ = parser_build_binary_op (TRUTH_ORIF_EXPR, $1, $4); }
	| expr_no_commas '?'
		{ $1 = truthvalue_conversion (default_conversion ($1));
		  skip_evaluation += $1 == boolean_false_node; }
          expr ':'
		{ skip_evaluation += (($1 == boolean_true_node)
				      - ($1 == boolean_false_node)); }
	  expr_no_commas
		{ skip_evaluation -= $1 == boolean_true_node;
		  $$ = build_conditional_expr ($1, $4, $7); }
	| expr_no_commas '?'
		{ if (pedantic)
		    pedwarn ("ISO C forbids omitting the middle term of a ?: expression");
		  /* Make sure first operand is calculated only once.  */
		  $<ttype>2 = save_expr ($1);
		  $1 = truthvalue_conversion (default_conversion ($<ttype>2));
		  skip_evaluation += $1 == boolean_true_node; }
	  ':' expr_no_commas
		{ skip_evaluation -= $1 == boolean_true_node;
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
		  /* This inhibits warnings in truthvalue_conversion.  */
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
	| string
		{ $$ = combine_strings ($1); }
	| VAR_FUNC_NAME
		{ $$ = fname_decl (C_RID_CODE ($$), $$); }
	| '(' typename ')' '{' 
		{ start_init (NULL_TREE, NULL, 0);
		  $2 = groktypename ($2);
		  really_start_incremental_init ($2); }
	  initlist_maybe_comma '}'  %prec UNARY
		{ const char *name;
		  tree result = pop_init_level (0);
		  tree type = $2;
		  finish_init ();

		  if (pedantic && ! flag_isoc99)
		    pedwarn ("ISO C89 forbids compound literals");
		  if (TYPE_NAME (type) != 0)
		    {
		      if (TREE_CODE (TYPE_NAME (type)) == IDENTIFIER_NODE)
			name = IDENTIFIER_POINTER (TYPE_NAME (type));
		      else
			name = IDENTIFIER_POINTER (DECL_NAME (TYPE_NAME (type)));
		    }
		  else
		    name = "";
		  $$ = result;
		  if (TREE_CODE (type) == ARRAY_TYPE && !COMPLETE_TYPE_P (type))
		    {
		      int failure = complete_array_type (type, $$, 1);
		      if (failure)
			abort ();
		    }
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
		  pop_label_level ();

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
		  pop_label_level ();
		  last_tree = COMPOUND_BODY ($1);
		  TREE_CHAIN (last_tree) = NULL_TREE;
		  $$ = error_mark_node;
		}
	| primary '(' exprlist ')'   %prec '.'
		{ $$ = build_function_call ($1, $3); }
	| VA_ARG '(' expr_no_commas ',' typename ')'
		{ $$ = build_va_arg ($3, groktypename ($5)); }
	| primary '[' expr ']'   %prec '.'
		{ $$ = build_array_ref ($1, $3); }
	| primary '.' identifier
		{
		      $$ = build_component_ref ($1, $3);
		}
	| primary POINTSAT identifier
		{
                  tree expr = build_indirect_ref ($1, "->");

			$$ = build_component_ref (expr, $3);
		}
	| primary PLUSPLUS
		{ $$ = build_unary_op (POSTINCREMENT_EXPR, $1, 0); }
	| primary MINUSMINUS
		{ $$ = build_unary_op (POSTDECREMENT_EXPR, $1, 0); }
	;

/* Produces a STRING_CST with perhaps more STRING_CSTs chained onto it.  */
string:
	  STRING
	| string STRING
		{
                  static int last_lineno = 0;
                  static const char *last_input_filename = 0;
                  $$ = chainon ($1, $2);
		  if (warn_traditional && !in_system_header
		      && (lineno != last_lineno || !last_input_filename ||
			  strcmp (last_input_filename, input_filename)))
		    {
		      warning ("traditional C rejects string concatenation");
		      last_lineno = lineno;
		      last_input_filename = input_filename;
		    }
		}
	;


old_style_parm_decls:
	/* empty */
	| datadecls
	| datadecls ELLIPSIS
		/* ... is used here to indicate a varargs function.  */
		{ c_mark_varargs ();
		  if (pedantic)
		    pedwarn ("ISO C does not permit use of `varargs.h'"); }
	;

/* The following are analogous to lineno_decl, decls and decl
   except that they do not allow nested functions.
   They are used for old-style parm decls.  */
lineno_datadecl:
	  save_filename save_lineno datadecl
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
	  save_filename save_lineno decl
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
		{ RESTORE_WARN_FLAGS ($1); }
	;

/* A list of declaration specifiers.  These are:

   - Storage class specifiers (SCSPEC), which for GCC currently include
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
	  SCSPEC
		{ $$ = tree_cons (NULL_TREE, $1, NULL_TREE);
		  TREE_STATIC ($$) = 0; }
	| declspecs_sc_nots_nosa_noea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_sc_nots_nosa_ea TYPE_QUAL
		{ $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = 1; }
	| declspecs_nosc_nots_nosa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_nots_nosa_ea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_nosa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_nosa_ea SCSPEC
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
	| declspecs_nosc_nots_sa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_nots_sa_ea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_sa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_nots_sa_ea SCSPEC
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
	| declspecs_nosc_ts_nosa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_nosa_ea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_nosa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_nosa_ea SCSPEC
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
	| declspecs_nosc_ts_sa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_nosc_ts_sa_ea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_sa_noea SCSPEC
		{ if (extra_warnings && TREE_STATIC ($1))
		    warning ("`%s' is not at beginning of declaration",
			     IDENTIFIER_POINTER ($2));
		  $$ = tree_cons (NULL_TREE, $2, $1);
		  TREE_STATIC ($$) = TREE_STATIC ($1); }
	| declspecs_sc_ts_sa_ea SCSPEC
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
	| TYPEOF '(' expr ')'
		{ $$ = TREE_TYPE ($3); }
	| TYPEOF '(' typename ')'
		{ $$ = groktypename ($3); }
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
	| ASM_KEYWORD '(' string ')'
		{ if (TREE_CHAIN ($3)) $3 = combine_strings ($3);
		  $$ = $3;
		}
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
	| SCSPEC
	| TYPESPEC
	| TYPE_QUAL
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
		    pedwarn ("ISO C89 forbids specifying subobject to initialize"); }
	| designator initval
		{ if (pedantic)
		    pedwarn ("obsolete use of designated initializer without `='"); }
	| identifier ':'
		{ set_init_label ($1);
		  if (pedantic)
		    pedwarn ("obsolete use of designated initializer with `:'"); }
	  initval
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
	/* These are for labeled elements.  The syntax for an array element
	   initializer conflicts with the syntax for an Objective-C message,
	   so don't include these productions in the Objective-C grammar.  */
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
		}
	   old_style_parm_decls
		{ store_parm_decls (); }
/* This used to use compstmt_or_error.
   That caused a bug with input `f(g) int g {}',
   where the use of YYERROR1 above caused an error
   which then was handled by compstmt_or_error.
   There followed a repeated execution of that same rule,
   which called YYERROR1 again, and so on.  */
	  save_filename save_lineno compstmt
		{ tree decl = current_function_decl;
		  DECL_SOURCE_FILE (decl) = $5;
		  DECL_SOURCE_LINE (decl) = $6;
		  finish_function (1);
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
		}
	  old_style_parm_decls
		{ store_parm_decls (); }
/* This used to use compstmt_or_error.
   That caused a bug with input `f(g) int g {}',
   where the use of YYERROR1 above caused an error
   which then was handled by compstmt_or_error.
   There followed a repeated execution of that same rule,
   which called YYERROR1 again, and so on.  */
	  save_filename save_lineno compstmt
		{ tree decl = current_function_decl;
		  DECL_SOURCE_FILE (decl) = $5;
		  DECL_SOURCE_LINE (decl) = $6;
		  finish_function (1);
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
		{ $$ = finish_struct ($<ttype>4, $5, chainon ($1, $7)); }
	| struct_head '{' component_decl_list '}' maybe_attribute
		{ $$ = finish_struct (start_struct (RECORD_TYPE, NULL_TREE),
				      $3, chainon ($1, $5));
		}
	| union_head identifier '{'
		{ $$ = start_struct (UNION_TYPE, $2); }
	  component_decl_list '}' maybe_attribute
		{ $$ = finish_struct ($<ttype>4, $5, chainon ($1, $7)); }
	| union_head '{' component_decl_list '}' maybe_attribute
		{ $$ = finish_struct (start_struct (UNION_TYPE, NULL_TREE),
				      $3, chainon ($1, $5));
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

component_decl_list:
	  component_decl_list2
		{ $$ = $1; }
	| component_decl_list2 component_decl
		{ $$ = chainon ($1, $2);
		  pedwarn ("no semicolon at end of struct or union"); }
	;

component_decl_list2:	/* empty */
		{ $$ = NULL_TREE; }
	| component_decl_list2 component_decl ';'
		{ $$ = chainon ($1, $2); }
	| component_decl_list2 ';'
		{ if (pedantic)
		    pedwarn ("extra semicolon in struct or union specified"); }
	;

component_decl:
	  declspecs_nosc_ts setspecs components
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_ts setspecs save_filename save_lineno
		{
		  /* Support for unnamed structs or unions as members of 
		     structs or unions (which is [a] useful and [b] supports 
		     MS P-SDK).  */
		  if (pedantic)
		    pedwarn ("ISO C doesn't support unnamed structs/unions");

		  $$ = grokfield($3, $4, NULL, current_declspecs, NULL_TREE);
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_nots setspecs components_notype
		{ $$ = $3;
		  POP_DECLSPEC_STACK; }
	| declspecs_nosc_nots
		{ if (pedantic)
		    pedwarn ("ISO C forbids member declarations with no members");
		  shadow_tag($1);
		  $$ = NULL_TREE; }
	| error
		{ $$ = NULL_TREE; }
	| extension component_decl
		{ $$ = $2;
		  RESTORE_WARN_FLAGS ($1); }
	;

components:
	  component_declarator
	| components ',' maybe_resetattrs component_declarator
		{ $$ = chainon ($1, $4); }
	;

components_notype:
	  component_notype_declarator
	| components_notype ',' maybe_resetattrs component_notype_declarator
		{ $$ = chainon ($1, $4); }
	;

component_declarator:
	  save_filename save_lineno declarator maybe_attribute
		{ $$ = grokfield ($1, $2, $3, current_declspecs, NULL_TREE);
		  decl_attributes (&$$, chainon ($4, all_prefix_attributes), 0); }
	| save_filename save_lineno
	  declarator ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, $2, $3, current_declspecs, $5);
		  decl_attributes (&$$, chainon ($6, all_prefix_attributes), 0); }
	| save_filename save_lineno ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, $2, NULL_TREE, current_declspecs, $4);
		  decl_attributes (&$$, chainon ($5, all_prefix_attributes), 0); }
	;

component_notype_declarator:
	  save_filename save_lineno notype_declarator maybe_attribute
		{ $$ = grokfield ($1, $2, $3, current_declspecs, NULL_TREE);
		  decl_attributes (&$$, chainon ($4, all_prefix_attributes), 0); }
	| save_filename save_lineno
	  notype_declarator ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, $2, $3, current_declspecs, $5);
		  decl_attributes (&$$, chainon ($6, all_prefix_attributes), 0); }
	| save_filename save_lineno ':' expr_no_commas maybe_attribute
		{ $$ = grokfield ($1, $2, NULL_TREE, current_declspecs, $4);
		  decl_attributes (&$$, chainon ($5, all_prefix_attributes), 0); }
	;

/* We chain the enumerators in reverse order.
   They are put in forward order where enumlist is used.
   (The order used to be significant, but no longer is so.
   However, we still maintain the order, just to be clean.)  */

enumlist:
	  enumerator
	| enumlist ',' enumerator
		{ if ($1 == error_mark_node)
		    $$ = $1;
		  else
		    $$ = chainon ($3, $1); }
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
		{ tree specs, attrs;
		  pending_xref_error ();
		  split_specs_attrs ($1, &specs, &attrs);
		  /* We don't yet support attributes here.  */
		  if (attrs != NULL_TREE)
		    warning ("attributes on type name ignored");
		  $<ttype>$ = specs; }
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
	  '[' expr ']'
		{ $$ = build_array_declarator ($2, NULL_TREE, 0, 0); }
	| '[' declspecs_nosc expr ']'
		{ $$ = build_array_declarator ($3, $2, 0, 0); }
	| '[' ']'
		{ $$ = build_array_declarator (NULL_TREE, NULL_TREE, 0, 0); }
	| '[' declspecs_nosc ']'
		{ $$ = build_array_declarator (NULL_TREE, $2, 0, 0); }
	| '[' '*' ']'
		{ $$ = build_array_declarator (NULL_TREE, NULL_TREE, 0, 1); }
	| '[' declspecs_nosc '*' ']'
		{ $$ = build_array_declarator (NULL_TREE, $2, 0, 1); }
	| '[' SCSPEC expr ']'
		{ if (C_RID_CODE ($2) != RID_STATIC)
		    error ("storage class specifier in array declarator");
		  $$ = build_array_declarator ($3, NULL_TREE, 1, 0); }
	| '[' SCSPEC declspecs_nosc expr ']'
		{ if (C_RID_CODE ($2) != RID_STATIC)
		    error ("storage class specifier in array declarator");
		  $$ = build_array_declarator ($4, $3, 1, 0); }
	| '[' declspecs_nosc SCSPEC expr ']'
		{ if (C_RID_CODE ($3) != RID_STATIC)
		    error ("storage class specifier in array declarator");
		  $$ = build_array_declarator ($4, $2, 1, 0); }
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
		  pedwarn ("deprecated use of label at end of compound statement");
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
		{ if (pedantic && !flag_isoc99)
		    pedwarn ("ISO C89 forbids mixed declarations and code"); }
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
                { $$ = add_scope_stmt (/*begin_p=*/0, /*partial_p=*/0); }

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
		      $$ = poplevel (kept_level_p (), 0, 0); 
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
		      tree label = shadow_label (TREE_VALUE (link));
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

compstmt_nostart: '}'
		{ $$ = convert (void_type_node, integer_zero_node); }
	| pushlevel maybe_label_decls compstmt_contents_nonempty '}' poplevel
		{ $$ = poplevel (kept_level_p (), 1, 0); 
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
		  push_label_level ();
		  compstmt_count++;
		  $$ = add_stmt (build_stmt (COMPOUND_STMT, last_tree));
		}

compstmt: compstmt_start compstmt_nostart
		{ RECHAIN_STMTS ($1, COMPOUND_BODY ($1)); 
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
	  IF '(' expr ')'
		{ c_expand_start_cond (truthvalue_conversion ($3), 
				       compstmt_count);
		  $<itype>$ = stmt_count;
		  if_stmt_file = $<filename>-2;
		  if_stmt_line = $<lineno>-1; }
	;

/* This is a subroutine of stmt.
   It is used twice, once for valid DO statements
   and once for catching errors in parsing the end test.  */
do_stmt_start:
	  DO
		{ stmt_count++;
		  compstmt_count++;
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
		  RECHAIN_STMTS ($$, DO_BODY ($$)); }
	;

/* The forced readahead in here is because we might be at the end of a
   line, and the line and file won't be bumped until yylex absorbs the
   first token on the next line.  */
save_filename:
		{ if (yychar == YYEMPTY)
		    yychar = YYLEX;
		  $$ = input_filename; }
	;

save_lineno:
		{ if (yychar == YYEMPTY)
		    yychar = YYLEX;
		  $$ = lineno; }
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
	  save_filename save_lineno stmt
		{ if ($3)
		    {
		      STMT_LINENO ($3) = $2;
		      /* ??? We currently have no way of recording
			 the filename for a statement.  This probably
			 matters little in practice at the moment,
			 but I suspect that problems will occur when
			 doing inlining at the tree level.  */
		    }
		}
	;

lineno_label:
	  save_filename save_lineno label
		{ if ($3)
		    {
		      STMT_LINENO ($3) = $2;
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
		    warning_with_file_and_line (if_stmt_file, if_stmt_line,
						"empty body in an if-statement"); }
/* Make sure c_expand_end_cond is run once
   for each call to c_expand_start_cond.
   Otherwise a crash is likely.  */
	| simple_if ELSE error
		{ c_expand_end_cond (); }
	| WHILE
                { stmt_count++; }
	  '(' expr ')'
                { $4 = truthvalue_conversion ($4);
		  $<ttype>$ 
		    = add_stmt (build_stmt (WHILE_STMT, $4, NULL_TREE)); }
	  c99_block_lineno_labeled_stmt
		{ RECHAIN_STMTS ($<ttype>6, WHILE_BODY ($<ttype>6)); }
	| do_stmt_start
	  '(' expr ')' ';'
                { DO_COND ($1) = truthvalue_conversion ($3); }
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
		    FOR_COND ($<ttype>2) = truthvalue_conversion ($6); }
	  xexpr ')'
		{ FOR_EXPR ($<ttype>2) = $9; }
	  c99_block_lineno_labeled_stmt
                { RECHAIN_STMTS ($<ttype>2, FOR_BODY ($<ttype>2)); }
	| SWITCH '(' expr ')'
		{ stmt_count++;
		  $<ttype>$ = c_start_case ($3); }
	  c99_block_lineno_labeled_stmt
                { c_finish_case (); }
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
		  $$ = add_stmt (build_break_stmt ()); }
	| CONTINUE ';'
                { stmt_count++;
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
	| identifier save_filename save_lineno ':' maybe_attribute
		{ tree label = define_label ($2, $3, $1);
		  stmt_count++;
		  if (label)
		    {
		      decl_attributes (&label, $5, 0);
		      $$ = add_stmt (build_stmt (LABEL_STMT, label));
		    }
		  else
		    $$ = NULL_TREE;
		}
	;

/* Either a type-qualifier or nothing.  First thing in an `asm' statement.  */

maybe_type_qual:
	/* empty */
		{ emit_line_note (input_filename, lineno);
		  $$ = NULL_TREE; }
	| TYPE_QUAL
		{ emit_line_note (input_filename, lineno); }
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
		{ $$ = build_tree_list (build_tree_list ($2, $4), $6); }
	;

asm_clobbers:
	  string
		{ $$ = tree_cons (NULL_TREE, combine_strings ($1), NULL_TREE); }
	| asm_clobbers ',' string
		{ $$ = tree_cons (NULL_TREE, combine_strings ($3), $1); }
	;

/* This is what appears inside the parens in a function declarator.
   Its value is a list of ..._TYPE nodes.  Attributes must appear here
   to avoid a conflict with their appearance after an open parenthesis
   in an abstract declarator, as in
   "void bar (int (__attribute__((__mode__(SI))) int foo));".  */
parmlist:
	  maybe_attribute
		{ pushlevel (0);
		  clear_parm_order ();
		  declare_parm_level (0); }
	  parmlist_1
		{ $$ = $3;
		  parmlist_tags_warning ();
		  poplevel (0, 0, 0); }
	;

parmlist_1:
	  parmlist_2 ')'
	| parms ';'
		{ tree parm;
		  if (pedantic)
		    pedwarn ("ISO C forbids forward parameter declarations");
		  /* Mark the forward decls as such.  */
		  for (parm = getdecls (); parm; parm = TREE_CHAIN (parm))
		    TREE_ASM_WRITTEN (parm) = 1;
		  clear_parm_order (); }
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
		}
	| parms
		{ $$ = get_parm_info (1); }
	| parms ',' ELLIPSIS
		{ $$ = get_parm_info (0); }
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
		{ pushlevel (0);
		  clear_parm_order ();
		  declare_parm_level (1); }
	  parmlist_or_identifiers_1
		{ $$ = $2;
		  parmlist_tags_warning ();
		  poplevel (0, 0, 0); }
	;

parmlist_or_identifiers_1:
	  parmlist_1
	| identifiers ')'
		{ tree t;
		  for (t = $1; t; t = TREE_CHAIN (t))
		    if (TREE_VALUE (t) == NULL_TREE)
		      error ("`...' in old-style identifier list");
		  $$ = tree_cons (NULL_TREE, NULL_TREE, $1); }
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
		{ $$ = SAVE_WARN_FLAGS();
		  pedantic = 0;
		  warn_pointer_arith = 0; }
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
#define D_TRAD	0x01	/* not in traditional C */
#define D_C89	0x02	/* not in C89 */
#define D_EXT	0x04	/* GCC extension */
#define D_EXT89	0x08	/* GCC extension incorporated in C99 */
#define D_OBJC	0x10	/* Objective C only */

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
  { "__bounded",	RID_BOUNDED,	0 },
  { "__bounded__",	RID_BOUNDED,	0 },
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
  { "__typeof",		RID_TYPEOF,	0 },
  { "__typeof__",	RID_TYPEOF,	0 },
  { "__unbounded",	RID_UNBOUNDED,	0 },
  { "__unbounded__",	RID_UNBOUNDED,	0 },
  { "__volatile",	RID_VOLATILE,	0 },
  { "__volatile__",	RID_VOLATILE,	0 },
  { "asm",		RID_ASM,	D_EXT },
  { "auto",		RID_AUTO,	0 },
  { "break",		RID_BREAK,	0 },
  { "case",		RID_CASE,	0 },
  { "char",		RID_CHAR,	0 },
  { "const",		RID_CONST,	D_TRAD },
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
  { "inline",		RID_INLINE,	D_TRAD|D_EXT89 },
  { "int",		RID_INT,	0 },
  { "long",		RID_LONG,	0 },
  { "register",		RID_REGISTER,	0 },
  { "restrict",		RID_RESTRICT,	D_TRAD|D_C89 },
  { "return",		RID_RETURN,	0 },
  { "short",		RID_SHORT,	0 },
  { "signed",		RID_SIGNED,	D_TRAD },
  { "sizeof",		RID_SIZEOF,	0 },
  { "static",		RID_STATIC,	0 },
  { "struct",		RID_STRUCT,	0 },
  { "switch",		RID_SWITCH,	0 },
  { "typedef",		RID_TYPEDEF,	0 },
  { "typeof",		RID_TYPEOF,	D_TRAD|D_EXT },
  { "union",		RID_UNION,	0 },
  { "unsigned",		RID_UNSIGNED,	0 },
  { "void",		RID_VOID,	0 },
  { "volatile",		RID_VOLATILE,	D_TRAD },
  { "while",		RID_WHILE,	0 },
};
#define N_reswords (sizeof reswords / sizeof (struct resword))

/* Table mapping from RID_* constants to yacc token numbers.
   Unfortunately we have to have entries for all the keywords in all
   three languages.  */
static const short rid_to_yy[RID_MAX] =
{
  /* RID_STATIC */	SCSPEC,
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
  /* RID_BOUNDED */	TYPE_QUAL,
  /* RID_UNBOUNDED */	TYPE_QUAL,
  /* RID_COMPLEX */	TYPESPEC,

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

  /* RID_FUNCTION_NAME */		STRING_FUNC_NAME,
  /* RID_PRETTY_FUNCTION_NAME */	STRING_FUNC_NAME,
  /* RID_C99_FUNCTION_NAME */		VAR_FUNC_NAME,

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

  /* alternate spellings */
  /* RID_AND */		0,
  /* RID_AND_EQ */	0,
  /* RID_NOT */		0,
  /* RID_NOT_EQ */	0,
  /* RID_OR */		0,
  /* RID_OR_EQ */	0,
  /* RID_XOR */		0,
  /* RID_XOR_EQ */	0,
  /* RID_BITAND */	0,
  /* RID_BITOR */	0,
  /* RID_COMPL */	0,
  
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
  /* RID_AT_INTERFACE */	INTERFACE,
  /* RID_AT_IMPLEMENTATION */	IMPLEMENTATION
};

static void
init_reswords ()
{
  unsigned int i;
  tree id;
  int mask = (flag_isoc99 ? 0 : D_C89)
	      | (flag_traditional ? D_TRAD : 0)
	      | (flag_no_asm ? (flag_isoc99 ? D_EXT : D_EXT|D_EXT89) : 0);

  if (c_language != clk_objective_c)
     mask |= D_OBJC;

  /* It is not necessary to register ridpointers as a GC root, because
     all the trees it points to are permanently interned in the
     get_identifier hash anyway.  */
  ridpointers = (tree *) xcalloc ((int) RID_MAX, sizeof (tree));
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
yyerror (msgid)
     const char *msgid;
{
  const char *string = _(msgid);

  if (last_token == CPP_EOF)
    error ("%s at end of input", string);
  else if (last_token == CPP_CHAR || last_token == CPP_WCHAR)
    {
      unsigned int val = TREE_INT_CST_LOW (yylval.ttype);
      const char *const ell = (last_token == CPP_CHAR) ? "" : "L";
      if (val <= UCHAR_MAX && ISGRAPH (val))
	error ("%s before %s'%c'", string, ell, val);
      else
	error ("%s before %s'\\x%x'", string, ell, val);
    }
  else if (last_token == CPP_STRING
	   || last_token == CPP_WSTRING)
    error ("%s before string constant", string);
  else if (last_token == CPP_NUMBER)
    error ("%s before numeric constant", string);
  else if (last_token == CPP_NAME)
    error ("%s before \"%s\"", string, IDENTIFIER_POINTER (yylval.ttype));
  else
    error ("%s before '%s' token", string, NAME(last_token));
}

static int
yylexname ()
{
  tree decl;
  
  
  if (C_IS_RESERVED_WORD (yylval.ttype))
    {
      enum rid rid_code = C_RID_CODE (yylval.ttype);

      {
	int yycode = rid_to_yy[(int) rid_code];
	if (yycode == STRING_FUNC_NAME)
	  {
	    /* __FUNCTION__ and __PRETTY_FUNCTION__ get converted
	       to string constants.  */
	    const char *name = fname_string (rid_code);
	  
	    yylval.ttype = build_string (strlen (name) + 1, name);
	    last_token = CPP_STRING;  /* so yyerror won't choke */
	    return STRING;
	  }
      
	/* Return the canonical spelling for this keyword.  */
	yylval.ttype = ridpointers[(int) rid_code];
	return yycode;
      }
    }

  decl = lookup_name (yylval.ttype);
  if (decl)
    {
      if (TREE_CODE (decl) == TYPE_DECL)
	return TYPENAME;
    }

  return IDENTIFIER;
}


static inline int
_yylex ()
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

    case CPP_NUMBER:
    case CPP_CHAR:
    case CPP_WCHAR:
      return CONSTANT;

    case CPP_STRING:
    case CPP_WSTRING:
      return STRING;
      
      /* This token is Objective-C specific.  It gives the next token
	 special significance.  */
    case CPP_ATSIGN:

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
yylex()
{
  int r;
  timevar_push (TV_LEX);
  r = _yylex();
  timevar_pop (TV_LEX);
  return r;
}

/* Sets the value of the 'yydebug' variable to VALUE.
   This is a function so we don't have to have YYDEBUG defined
   in order to build the compiler.  */

void
c_set_yydebug (value)
     int value;
{
#if YYDEBUG != 0
  yydebug = value;
#else
  warning ("YYDEBUG not defined.");
#endif
}

/* Function used when yydebug is set, to print a token in more detail.  */

static void
yyprint (file, yychar, yyl)
     FILE *file;
     int yychar;
     YYSTYPE yyl;
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
      if (IDENTIFIER_POINTER (t))
	fprintf (file, " `%s'", IDENTIFIER_POINTER (t));
      break;

    case CONSTANT:
      fprintf (file, " %s", GET_MODE_NAME (TYPE_MODE (TREE_TYPE (t))));
      if (TREE_CODE (t) == INTEGER_CST)
	fprintf (file,
#if HOST_BITS_PER_WIDE_INT == 64
#if HOST_BITS_PER_WIDE_INT == HOST_BITS_PER_INT
		 " 0x%x%016x",
#else
#if HOST_BITS_PER_WIDE_INT == HOST_BITS_PER_LONG
		 " 0x%lx%016lx",
#else
		 " 0x%llx%016llx",
#endif
#endif
#else
#if HOST_BITS_PER_WIDE_INT != HOST_BITS_PER_INT
		 " 0x%lx%08lx",
#else
		 " 0x%x%08x",
#endif
#endif
		 TREE_INT_CST_HIGH (t), TREE_INT_CST_LOW (t));
      break;
    }
}

/* This is not the ideal place to put these, but we have to get them out
   of c-lex.c because cp/lex.c has its own versions.  */

/* Return something to represent absolute declarators containing a *.
   TARGET is the absolute declarator that the * contains.
   TYPE_QUALS_ATTRS is a list of modifiers such as const or volatile
   to apply to the pointer type, represented as identifiers, possible mixed
   with attributes.

   We return an INDIRECT_REF whose "contents" are TARGET (inside a TREE_LIST,
   if attributes are present) and whose type is the modifier list.  */

tree
make_pointer_declarator (type_quals_attrs, target)
     tree type_quals_attrs, target;
{
  tree quals, attrs;
  tree itarget = target;
  split_specs_attrs (type_quals_attrs, &quals, &attrs);
  if (attrs != NULL_TREE)
    itarget = tree_cons (attrs, target, NULL_TREE);
  return build1 (INDIRECT_REF, quals, itarget);
}
