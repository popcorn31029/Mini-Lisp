%{
#include "y.tab.h"
#include<iostream>
#include <stdio.h>
%}
separator   [\t\n\r ]
letter      [a-z]
digit       [0-9]
number      0|[1-9]{digit}*|[-][1-9]{digit}*
ID          {letter}({letter}|{digit}|"-")*

%%
{separator}	            { /* do nothing */ }
{number}	            { yylval.val = atoi(yytext); return(NUMBER); }
"#t"|"#f"               {
                          if(strcmp(yytext,"#t")==0)
				            yylval.boolval=1;
			              else
				            yylval.boolval=0;
			              return(BOOL);}

"print-num"             { return(PRINT_NUM); }
"print-bool"            { return(PRINT_BOOL); }
"+"|"-"|"*"|"/"|"("|")"	{ return(yytext[0]); }
"mod"                   { return(MOD); }
"if"	                { return (IF);}
">"|"<"|"="             { return(yytext[0]); }
"and"	                { return (AND);}
"or"	                { return (OR);}
"not"	                { return (NOT);}
"define"                { return (DEFINE);}
"fun"                   { return (FUN);}
{ID}	                { yylval.strval=strdup(yytext); return(ID);}
.	                    { return(yytext[0]); }
%%
