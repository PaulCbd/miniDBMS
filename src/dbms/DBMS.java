package dbms;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.*;

import parser.*;

/**
 * CS4710 Introducing to Database, Team 6<br>
 * Project 1: MiniDBMS - Current stage: 2nd.<br>
 * <br>
 *     In this project, we use the tool : ANTLR
 * (vertion 4.5) to generate the lexer & parser.<br>
 * input the ".sql" file as the program argument
 * and our DBMS will start process the SQL queries.
 * use absolute path of test.sql <br> 
 */
public class DBMS {
	public final static Boolean dumpParsingMsg = true;
	public final static Boolean consoleMsg = true;
	public final static String dumpFile = "Output.txt";
	private static BufferedWriter os;
	private static String inputFile;
	
	public static void dump(String s){
		if(DBMS.dumpParsingMsg){
			
			try{
				os.write(s);
				os.flush();
			}catch(Exception e){}
			
		}
	}
	
	public static void outConsole(String s){
		if(DBMS.consoleMsg){
			System.out.println(s);
		}
	}
	
    public static void main(String[] args) throws Exception {
        // create a CharStream that reads from standard input
    	
    	
		if ( args.length>0 ){
			
			inputFile = args[0];
			
			
			InputStream is;
			
			if ( inputFile!=null ) {
				is = new FileInputStream(inputFile);
				System.out.println("File name:"+inputFile);
				try{
					os = new BufferedWriter(new FileWriter(dumpFile));
				}catch(IOException e){}
				
				System.out.println("----------Create Parser-----------");
				ANTLRInputStream input = new ANTLRInputStream(is);
				
		        // create a lexer that feeds off of input CharStream
		        SqlLexer lexer = new SqlLexer(input);
		
		        // create a buffer of tokens pulled from the lexer
		        CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		        // create a parser that feeds off the tokens buffer
		        SqlParser parser = new SqlParser(tokens);
		
		        // start parse SQL
		        System.out.println("----------Start Parsing-------------");
		        parser.start();

		        //ParseTree tree = parser.start(); // begin parsing at start rule
		        //System.out.println(tree.toStringTree(parser)); // print LISP-style tree
		        os.close();
		        System.out.println("-----------End Parsing--------------");
		        
			}else{
				System.out.println("Fail to open SQL file");
				throw new Error ("DBMS: fail to fetch the SQL queries.");
			}
		}
        
    }

	
}