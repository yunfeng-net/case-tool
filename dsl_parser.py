# -*- coding: gbk -*-
tokens = (  
        'NAME', 'STRING',  'NUMBER',
        'IF', 'WHILE', 'FOR', 'ELSE', 'DOC', 'METHOD',
        'OBJECT', 'ATTR', 'IN', 'OUT'
)  

reserved = {
    'if':'IF', 'while':'WHILE', 'for':'FOR',
    'else':'ELSE', 'doc':'DOC', 'method':'METHOD',
    'class':'OBJECT', 'attr':'ATTR', 'in':'IN', 'out':'OUT',
    'aspect':'OBJECT'
}
literals = ',=(){}.'

def t_STRING(t):
    r'\"[^\"]*\"'
    t.value = t.value[1:len(t.value)-1]
    return t
def t_NAME(t):
    r'[^ \t\r\n\.#,=\(\)\{\}]+'
    if t.value in reserved:
        t.type = reserved[t.value]
    return t
def t_NUMBER(t):
    r'\d+'
    return t

# Ignored characters
t_ignore = " \t\r"
t_ignore_COMMENT = r'\#[^\n]*'
def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")
   
def t_error(t):
    print("Illegal character '%s' at line %d" % (t.value[0], t.lexer.lineno))
    t.lexer.skip(1)
   
# Build the lexer
import ply.lex as lex

data = u"""   # first comment\nobject 第一 {doc mission=\"\nexample\"
\n attr haha \n method miss(in g, out p, q){ g.daddy()\n
if _not_() {} else { while is() { for a in b {}}}
}}
"""
lexer = lex.lex()  
##lexer.input(data)  
##for token in lexer:
##    print(token)

def p_object_list(p):
    ''' object_list : 
    | object_list object '''
    if len(p)==1:
        p[0] = []
    else:
        p[0] = p[1]
        p[0].append(p[2])
def p_object(p):
    ' object : OBJECT NAME "{" decl_list "}"'
    p[0] = (p[1], p[2], p[4])
def p_decl_list(p):
    ''' decl_list : 
    | decl_list decl '''
    if len(p)==1:
        p[0] = []
    else:
        p[1].append(p[2])
        p[0] = p[1]
def p_decl(p):
    ''' decl : doc_stmt
    | attr_stmt
    | method_stmt '''
    p[0] = p[1]
def p_stmt_list(p):
    ''' stmt_list : 
    | stmt_list stmt '''
    if len(p)==1:
        p[0] = []
    else:
        p[1].append(p[2])
        p[0] = p[1]
def p_stmt(p):    
    ''' stmt : if_stmt
    | while_stmt
    | for_stmt
    | doc_stmt
    | call '''
    p[0] = p[1]
def p_if(p):
    ''' if_stmt : if_then
    | if_then else_stmt '''
    if len(p)==2:
        p[0] = p[1]
    else:
        p[0] = ('IF', p[1][0], p[1][1], p[2])
def p_if_then(p):
    ' if_then : IF call  "{" stmt_list "}" '
    p[0] = ('IF', p[2], p[4])
def p_else_stmt(p):
    ' else_stmt : ELSE "{" stmt_list "}" '
    p[0] = p[3]
def p_while_stmt(p):
    ' while_stmt : WHILE call "{" stmt_list "}" '
    p[0] = ('WHILE', p[2], p[4])
def p_for_stmt(p):
    ' for_stmt : FOR NAME IN NAME "{" stmt_list "}" '
    p[0] = ('FOR', p[2], p[4], p[6])
def p_doc_stmt(p):
    ''' doc_stmt : DOC NAME "=" STRING
    | DOC NAME "=" NAME '''
    p[0] = ('DOC', p[2], p[4])
def p_attr_stmt(p):
    ' attr_stmt : ATTR '
    p[0] = ('ATTR', p[2])
def p_call(p):
    ' call : ref_name "(" opt_value_list ")" '
    p[0] = ('call', p[1], p[3])
def p_ref_name(p):
    ''' ref_name : NAME
    | ref_name "." NAME '''
    if len(p)==2:
        p[0]= [p[1]]
    else:
        p[1].append(p[3])
        p[0] = p[1]

def p_opt_value_list(p):
    ''' opt_value_list :
    | value_list '''
    if len(p)==1:
        p[0]= []
    else:
        p[0] = p[1]
def p_value_list(p):
    ''' value_list : value
    | value_list "," value '''
    if len(p)==2:
        p[0] = [p[1]]
    else:
        p[1].append(p[3])
        p[0] = p[1]
def p_value(p):
    ''' value : ref_name
    | NUMBER
    | STRING '''
    p[0] = p[1]
def p_opt_arg_list(p):
    ''' opt_arg_list :
    | arg_list '''
    if len(p)>1:
        p[0] = p[1]
def p_arg_list(p):
    ''' arg_list : arg
    | arg_list "," arg'''
    if len(p)==2:
        p[0] = [p[1]]
    else:
        p[1].append(p[3])
        p[0] = p[1]
def p_arg(p):
    ''' arg : NAME
    | IN NAME
    | OUT NAME
    | NUMBER '''
    if len(p)==2:
        p[0] = ('IO', p[1])
    else:
        p[0] = (p[1], p[2])
def p_method_stmt(p):
    ' method_stmt : METHOD NAME "(" opt_arg_list ")" "{" stmt_list "}" '
    p[0] = (p[1], p[2], p[4], p[7])
def p_error(p):  
    if p:  
        print("Syntax error at '%s'" % p.value, p)
    else:  
        print("Syntax error at EOF")  
import ply.yacc as yacc  
yacc.yacc()
fw = open("Z:/qa/adc/assert.txt", 'r', -1, 'utf-8')
data = fw.read()
print(data)
a = yacc.parse(data)
print(a)

