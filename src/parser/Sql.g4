grammar Sql;

@header{
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //!!!                                                            !!!
    //!!! THIS CODE IS AUTOMATICALLY GENERATED! DO NOT MODIFY!       !!!
    //!!! Please refer to file Example.g4 for grammar documentation. !!!
    //!!!                                                            !!!
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
import java.util.*;
import java.io.*;
import manageDatabase.*;
import structure.*;
import dbms.*;


}

@parser::members{
	
	private final static int maxTuple = 100;
	private final static int maxAttr = 5;
	private final static DBExecutor executor = new DBExecutor();
	private boolean inValid;
	
	public static void execute(Query query){
		try{
    		if (query != null) {
    			DBMS.outConsole("execute: "+query.queryName);
    			executor.execute(query);
    		}
    		else DBMS.outConsole("query fail\n----------");
    	}
		catch (Error ex)
		{
			System.err.println(ex.getMessage());
			return;
		}
	}   	
	

	public static void pause(){
		DBMS.outConsole("Press Enter to continue.");
		try{
			System.in.read();
		}catch(Exception e){};
	}
	
	
}
start 
	:	(instructions SCOL)* EOF
	;

instructions
	@init{ inValid = false;}
	:	create_table {execute($create_table.query);}
	|	select_from  
	|	insert_into	{execute($insert_into.query);}
	;

create_table returns[Query query] 
 	locals [
	 	String tableName,
		String attrName,
		int lengthToken
	]
	
	:	CREATE TABLE table_name { $tableName = $table_name.value;} 
		LPARSE attribute_list RPARSE 
		{
			//DBMS.outConsole("query: create_table start");
			if(!inValid){
				$query = new Create(
						$tableName, 
						$attribute_list.r_attrList, 
						$attribute_list.r_primaryList, 
						$attribute_list.r_attrPosTable
				);
				$query.queryName = "Create Table";
				DBMS.outConsole("create "+$tableName);
			}
		}
	;


attribute_list returns[
		ArrayList <Attribute> r_attrList,
		Hashtable <String, Integer> r_attrPosTable,
		ArrayList <Integer> r_primaryList
	]
	locals[
		Attribute _attribute,
		ArrayList <Attribute> attrList,
		Hashtable <String, Integer> attrPosTable = new Hashtable <String, Integer>(),
		ArrayList <Integer> primaryList = new ArrayList <Integer> ()
	]
	:	attribute (COMMA attribute )*{
			$r_attrList = $attrList;
			$r_attrPosTable = $attrPosTable;
			$r_primaryList = $primaryList;
		}
	|	(attribute COMMA )* primary_key (COMMA attribute )*
	
	;


attribute 
	@init{
		Attribute _attribute = $attribute_list::_attribute;
	}
	:	colomn_name types {
			String _attrName = $colomn_name.value;
			_attribute = new Attribute(
				$types.type,
				_attrName,
				$types.lengthToken
			);
			
			// check attribute list not empty
			if ($attribute_list::attrList== null) {	
				$attribute_list::attrList = new ArrayList<Attribute>();
			}
			
			if (!$attribute_list::attrList.contains(_attribute)) {
				// add attribute
				$attribute_list::attrPosTable.put(
					_attrName, 
					Integer.valueOf($attribute_list::attrList.size())
				);
				$attribute_list::attrList.add(_attribute);
				DBMS.outConsole("fetch colomn name: " + _attrName+" "+$types.lengthToken);
			}else{
				inValid=true;
				DBMS.outConsole("CREATE TABLE: DUPLICATED ATTRIBUTES");
			}
		}
	;


primary_key 
	@init{
		Attribute _attribute = $attribute_list::_attribute;
	}		
	:	colomn_name types PRIMARY KEY {
		String _attrName = $colomn_name.value;
		_attribute = new Attribute($types.type, $colomn_name.value);
		//DBMS.outConsole("Primary key colomn_name is "+ $colomn_name.value);
		
		// check attribute list not empty
		if ($attribute_list::attrList== null) {	
			$attribute_list::attrList = new ArrayList<Attribute>();
		}
		
		if (! $attribute_list::attrList.contains(_attribute)) {
			$attribute_list::attrList.add(_attribute);
			//save position of attribute name 
			$attribute_list::attrPosTable.put(
				_attrName,
				Integer.valueOf($attribute_list::attrList.size())
			);
		}
		else{
			inValid = true;
			DBMS.outConsole("CREATE TABLE: DUPLICATED ATTRIBUTES");
		}
		if (!$attribute_list::primaryList.contains(_attrName)) {
			//save position of attribute in primary list
			$attribute_list::primaryList.add(
				$attribute_list::attrPosTable.get(_attrName)
			);
		}
		else throw new Error ("CREATE TABLE: INVALID PRIMARY KEY " + $colomn_name.value);
		
		DBMS.outConsole("fetch colomn name: " + _attrName+" "+$types.lengthToken+"| PrimaryKey");
	}
	;

types returns[
		Attribute.Type type,
		int lengthToken
	]
	:	INT {
			$type = Attribute.Type.INT;
			$lengthToken = 0;
		}  
	|	VARCHAR length {
			$type = Attribute.Type.CHAR;
			if($length.lengthToken >0)
				$lengthToken = $length.lengthToken;
		}
	;
	
length returns [int lengthToken]
	:	LPARSE INT_IDENTI { $lengthToken = $INT_IDENTI.int;} RPARSE
	;


insert_into returns [Query query]
	@init {int i = 0;
		   int tempPosition;
		   } //iterator for List <int> attrPosition 
	:/*
	 *insert tuples columns need to be in order 
	 */
		INSERT INTO 
		{
			String tableName;
			ArrayList <String> valueList = new ArrayList <String>();
		}
		table_name {tableName = $table_name.value;}
		VALUES LPARSE consts {valueList.add((String)$consts.value);} 
		(COMMA consts {valueList.add((String)$consts.value); } )* RPARSE
		{$query = new Insert(tableName, valueList); }
		
		|  
		/*
		 * Insert into specific column, use List<Integer> attrPostion to track column index
		 */
		INSERT INTO 
		{
			String tableName;
			ArrayList <String> valueList = new ArrayList <String>();
		}
		table_name {tableName = $table_name.value;} colomn_declare
		VALUES LPARSE consts 
		{	
			tempPosition = $colomn_declare.attrPosition.remove(i++);
			if( tempPosition <= valueList.size())
				valueList.add(tempPosition,(String)$consts.value); 
				//add at specific index, after that index(include)
				// would shift
			else valueList.add((String)$consts.value);//just add at end
		}
		(COMMA consts {
			valueList.add((String)$consts.value); 
			if( tempPosition <= valueList.size())
				valueList.add(tempPosition,(String)$consts.value); 
			else valueList.add((String)$consts.value);

		} )* RPARSE
		{$query = new Insert(tableName, valueList); }
	;



colomn_declare returns[List <Integer> attrPosition] //return manual input position of values
@init{Hashtable <String, Integer> attrPosTable = $attribute_list::attrPosTable;}		   
	:	LPARSE colomn_name {$attrPosition.add(attrPosTable.get($colomn_name.value));}
	 (COMMA colomn_name {$attrPosition.add(attrPosTable.get($colomn_name.value));} )* RPARSE
	;

select_from
	:	SELECT colomns (COMMA colomns)* 
		FROM tables (COMMA tables)*
		where_clause?
	;

colomns
    :	(table_name|table_alias_name DOT)? colomn_tail
    ;
    
colomn_tail returns [Object value]
	:	x = colomn_name {$value = $x.value;}
	|	y = STAR {$value = $y.text;}
	;

tables
	:	table_name (AS table_alias_name)?
	;
	
where_clause
	:	WHERE bool_expr (logical_op bool_expr)?
	;
	
logical_op returns [String value]
	:	x=(AND|OR) {$value = new String($x.text);}
	;

bool_expr
	:	operand (compare operand)?
    ;
    
operand
	:	(table_alias_name DOT)? colomn_name
	|	consts
	;

consts returns [Object value]
	:	x = type_int {$value = $x.value; }
	|	z = type_varchar {$value = $z.value;}
	;

compare
	:	LT
	|	GT
	|	EQ
	|	NOT_EQ
	;
	
op
	:	PLUS
	|	MINUS
	|	STAR
	|	DIV
	;


colomn_name returns [String value]
	:	x=IDENTIFIER {
		$value = new String($x.text);
		DBMS.dump($x.text);
	};
  
colomn_alias_name returns [String value]
	:	x=IDENTIFIER {
		$value = new String($x.text);
		DBMS.dump($x.text);
	};
  
table_name returns [String value]
	:	x=IDENTIFIER {
		$value = new String($x.text);
		DBMS.dump($x.text);
	};
  
table_alias_name returns [String value]
	:	x=IDENTIFIER {
		$value = new String($x.text);
		DBMS.dump($x.text);
	};
  
type_int returns [Integer value] 
	:	x=INT_IDENTI {
		$value = new Integer($x.text);
		DBMS.dump($x.text);
	};
  
type_varchar returns [String value] 
	:	x=VARCHAR_IDENTI {
		$value = new String($x.text);
		DBMS.dump($x.text);
	};

ALTER   : A L T E R;
AS      : A S              { DBMS.dump("AS");};
CREATE  : C R E A T E      { 
	DBMS.dump("CREATE");
	


};
DATABASE: D A T A B A S E;
DELETE  : D E L E T E;
DOUBLE  : D O U B L E;
DROP    : D R O P;
EXISTS  : E X I S T S;
FOREIGN : F O R E I G N;
FROM    : F R O M          { DBMS.dump("FROM");};
IF      : I F;
IN      : I N;
INSERT  : I N S E R T      { DBMS.dump("INSERT");};
INT     : I N T            { DBMS.dump("INT");};
INTO    : I N T O          { DBMS.dump("INTO");};
KEY     : K E Y            { DBMS.dump("KEY");};
NOT     : N O T;
NULL    : N U L L;
ON      : O N;
PRIMARY : P R I M A R Y    { DBMS.dump("PRIMARY");};
REFERENCES: R E F E R E N C E S;
SELECT  : S E L E C T      { DBMS.dump("SELECT");};
SET     : S E T;
VARCHAR : V A R C H A R    { DBMS.dump("VARCHAR");};
TABLE   : T A B L E        { DBMS.dump("TABLE");};
UPDATE  : U P D A T E;
USE     : U S E;
VALUES  : V A L U E S      { DBMS.dump("VALUES");};
WHERE   : W H E R E        { DBMS.dump("WHERE");};
AND 	: A N D            { DBMS.dump("AND");};
OR  	: O R              { DBMS.dump("OR");};


IDENTIFIER
	: [a-zA-Z_][a-zA-Z_0-9]*;
	
INT_IDENTI
    : DIGIT+;
    
DOUBLE_IDENTI
    :	(DIGIT+('.'DIGIT)?)
    |	((DIGIT)*'.'DIGIT);
    
VARCHAR_IDENTI
    : ('\'')~[\r\n]*('\'');

SINGLE_LINE_COMMENT
	: '--' ~[\r\n]* -> channel(HIDDEN);

MULTILINE_COMMENT
	: '/*' .*? ( '*/' | EOF ) -> channel(HIDDEN);

TABS
	: [\t\u000B] {DBMS.dump("\t");} -> channel(HIDDEN);
	
SPACE
	: [ ] {DBMS.dump(" ");} -> channel(HIDDEN);
	
NEWLINE
	: '\r'?'\n'  {DBMS.dump("\n");} -> channel(HIDDEN);

fragment DIGIT : [0-9];
fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];

SCOL   : ';' {DBMS.dump(";");};
DOT    : '.' {DBMS.dump(".");};
LPARSE : '(' {DBMS.dump("(");};
RPARSE : ')' {DBMS.dump(")");};
COMMA  : ',' {DBMS.dump(",");};
STAR   : '*' {DBMS.dump("*");};
PLUS   : '+';
MINUS  : '-';
TILDE  : '~';
PIPE2  : '||';
DIV    : '/';
MOD    : '%';
LSHIFT : '<<';
RSHIFT : '>>';
AMP    : '&';
PIPE   : '|';
LT     : '<' {DBMS.dump("<");};
LT_EQ  : '<=';
GT     : '>' {DBMS.dump(">");};
GT_EQ  : '>=';
EQ     : '=' {DBMS.dump("=");};
NOT_EQ : '<>' {DBMS.dump("<>");};
