package dbms;

import java.io.*;
import java.util.*;

import manageDatabase.*;
import structure.*;

/**
 * This class performs the major part of DBMS.<br>
 * 
 * 
 */

public class DBExecutor{
	/**
	 * Database Defined URL:<br>
	 * .......
	 */
	private static final String databaseDefUrl = "databaseDef.dat";
	
	
	public DBExecutor(){
		// clear databaseDefUrl
		File tableFile = new File(databaseDefUrl);
		tableFile.delete();
	}
	
	/**
	 *     While an SQL query has be parsed, DBExecutor gets
	 * the query information and execute it.<br>
	 *     The Executor first recognizing the SQL and execute
	 * it by the corresponding class.<br>
	 * 
	 * @param query
	 * : the SQL queries informations.
	 */
	public void execute(Query query)
	{
		try{
			if (query instanceof Create) {
				create((Create)query);
			}
			else if (query instanceof Insert){ 
				insert((Insert)query);
			}
		}catch(IOException ex){
			System.err.println(ex.getMessage());
		}catch(ClassNotFoundException ex){
			System.err.println(ex.getMessage());
		}catch(Error ex){
			System.err.println(ex.getMessage());
		}
	}

	/**
	 * The operation to perform SQL : Create<br>
	 * 
	 * @param query
	 * : the object obtains the informations to be created.
	 * @throws IOException
	 * @throws Error
	 * @throws ClassNotFoundException
	 * check if table is already exit in hash table
	 * if not put tableName in hash
	 * and write hash tables in file
	 */
	private void create(Create query)
		throws IOException, Error, ClassNotFoundException 
	{
		// built hashTable by tableName as hash key
		Hashtable<String, Table> tables = null;
		
		// save table as a file
		File tableFile = new File(databaseDefUrl);
		
		//
		if (tableFile.exists()) {
			tables = this.getTableDef();
		}else{
			tables = new Hashtable<String, Table>();
		}
		
		//
		if (!tables.containsKey(query.getTableName())) {
			//store table in hash table
			tables.put(query.getTableName(), query.getTable());
			//write tables in tablefiles
			this.writeTableDef(tableFile, tables);
			
			//dump message
			System.out.println("Table is created");
			
		}else{
			//DBMS.outConsole("get "+tables.get(query.getTableName()).getTableName());
			throw new Error("CREATE Table:" + query.getTableName()+ " fail, already exist");
		}
		
	}

	/**
	 * The operation to perform SQL: INSERT.<br>
	 * @param query
	 * :The object contains the informations to be inserted.
	 * @throws IOException
	 * @throws Error
	 * @throws ClassNotFoundException
	 * 
	 * get tuple list from file
	 * convert new tuple in string to new tuple in types
	 * check primary whether is repeated
	 * if not store new added tuple list to typle file
	 */
	public void insert (Insert query)
			throws IOException, Error, ClassNotFoundException
	{
		Hashtable <String, Table> tables = null;
		ArrayList <Value> valueList = null;
		ArrayList <ArrayList <Value>> tupleList;
		Table table;
		/**
		 * get table from tableFile
		 */
		
		File tableFile = new File(databaseDefUrl);
		if (tableFile.exists()) {
			tables = this.getTableDef();
		}else{
			throw new Error("INSERT: No database defined");
		}
		
		//do the hash
		if ((table = tables.get(query.getTableName()))!= null ) {
			//exist table
			//check values integrity and input in valuelist
			valueList = this.convertInsertValueType(table, query.getValueList());
			File tupleFile = new File(query.getTableName() + ".db");
			if (tupleFile.exists()) {
				tupleList = this.getTupleList(tupleFile);
			}
			else
				tupleList = new ArrayList <ArrayList <Value>> ();
			if (tupleList != null && valueList != null) {
				boolean primarykeysNotRepeat = this.checkPrimarys(table.getPrimaryList(), tupleList, valueList);

				if (primarykeysNotRepeat) {
					tupleList.add(valueList);
				}else{
					throw new Error ("INSERT: primary key is repeated or null");
				}

			}
			//see if we can just save one tuple instead of all tuples
			this.saveTupleList(tupleFile, tupleList);
			System.out.println("Tuple inserted successfully");

		}else{
			throw new Error ("INSERT: No Table "+ query.getTableName() + " Found");
		}


	}
	
	
	//cannot be null is not yet implemented
	//primary key cannot be null or repeated!!!!
	/**
	 * 
	 * @param primaryList
	 * store primary attribute position in table
	 * @param tupleList
	 * old tuple list
	 * @param newValueList
	 * new tuple list to check if primary repeated in old
	 * @return
	 */
	private boolean checkPrimarys(ArrayList <Integer> primaryList, ArrayList <ArrayList <Value>> tupleList, ArrayList <Value> newValueList)
	{
		//check every tuple
		for (ArrayList <Value> tuple: tupleList ) {
			boolean isCorrect = false; //the flag is set to false every time
			// in each tuple check primary key in newvaluelist whether is repeated  
			for (Integer primaryPos : primaryList) {
				if (!newValueList.get(primaryPos).equals(tuple.get(primaryPos))) {
					isCorrect = true;
				}
			}
			if (isCorrect == false) { //end the loop no need to check each
				return false;
			}

		}
		return true;

	}
	
	/**
	 * @param tableDef table from the table file
	 * @param values valueList from the query
	 * 
	 * check insert value list's columns numbers whether the same with tables
	 * convert strings in values to different types of object in valueList
	 * based on  attribute list 
	 */
	private ArrayList <Value> convertInsertValueType(Table tableDef, ArrayList <String> values) throws Error
	{
		  ArrayList <Value> valueList = new ArrayList <Value> ();
		  ArrayList <Attribute> attrList = tableDef.getAttrList();
		  String tableName = tableDef.getTableName();
		  int attrSize = attrList.size();
		  if (attrSize != valueList.size()) {
		  		throw new Error("INSERT: The number of Values is not matched, Table"
		  				+ tableName + "has " +attrSize + "Values");
		  }

		  //converting values and input valueList
		  for (int i = 0; i < attrSize; ++i) {
		  	Attribute attribute = attrList.get(i);
		  	String strValue = values.get(i);

		  	try{
		  		Attribute.Type type = attribute.getType();

		  		if (type == Attribute.Type.INT) {
		  			int intValue = Integer.parseInt(strValue);
		  			Value value = new Value(intValue);
		  			valueList.add(value);
		  		}
		  		/**
		  		 * need to check if varchar type string length exceed the create scheme defined
		  		 */
		  		else if(type == Attribute.Type.CHAR){
		  			//check type and length  //' ' +length of string
		  			if (attribute.getLength() +2 < strValue.length()|| strValue.charAt(0)!= '\'') {
		  				throw new NumberFormatException();
		  			}
		  			Value charValue = new Value(strValue);
		  			valueList.add(charValue);
		  		}

		  	}
		  	catch(NumberFormatException ex){
		  		throw new Error("INSERT: Value " + strValue + "is wrong type or exceed length");
		  	}

		  }
		  return valueList;

	}
	
	/**
	 * used for creation<br>
	 * read in table from file
	 * 
	 * @return
	 * @throws IOException
	 * @throws ClassNotFoundException
	 */
	private Hashtable <String, Table> getTableDef()
			throws IOException, ClassNotFoundException
	{
		Hashtable <String, Table> tables = null;
		File tableFile = new File(databaseDefUrl);
		
		FileInputStream fileIn = new FileInputStream(tableFile);
		ObjectInputStream in = new ObjectInputStream(fileIn);
		tables = (Hashtable<String, Table>) in.readObject();
		
		in.close();
		fileIn.close();

		return tables;
	}
	/*
	 * write table into file
	 */
	
	private void writeTableDef(File tableFile, Hashtable<String, Table>tables)throws IOException
	{
		FileOutputStream outFile = new FileOutputStream(tableFile);
		ObjectOutputStream out = new ObjectOutputStream(outFile);
		out.writeObject(tables);
		out.close();
		outFile.close();
	}

	/*
	 * get tuple from tuplefile(tupples)
	 * used for insertion 
	 */
	

	@SuppressWarnings("unchecked")
	private ArrayList <ArrayList <Value>>  getTupleList(File tupleFile)throws IOException, ClassNotFoundException{
		ArrayList <ArrayList <Value>>  tupleList = null;
		FileInputStream fileIn = new FileInputStream(tupleFile);
		ObjectInputStream in = new ObjectInputStream(fileIn);
		tupleList = (ArrayList <ArrayList <Value>> ) in.readObject();
		in.close();
		fileIn.close();

		return tupleList;
	}

	private void saveTupleList(File tupleFile, ArrayList <ArrayList <Value>> tupleList)throws IOException
	{
		FileOutputStream outFile = new FileOutputStream(tupleFile);
		ObjectOutputStream out = new ObjectOutputStream(outFile);
		out.writeObject(tupleList);
		out.close();
		outFile.close();
	}


}//end DBExecutor

