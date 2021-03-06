package manageDatabase;

import java.util.ArrayList;
import java.util.Hashtable;

import structure.Attribute;
import structure.Table;

public class Create extends Query{
	private ArrayList <Attribute> attributes;
	private ArrayList <Integer> primary;
	private Hashtable <String, Integer> attrPosTable; //used for attribute position in attributes
	private String tableName;
	
	public Create(String tableName, ArrayList <Attribute> attrList, ArrayList<Integer> primary, 
				  Hashtable <String, Integer> attrPosTable) {
		this.queryName = "Create";
		this.tableName = tableName;
		this.attributes = attrList;
		this.primary = primary;
		this.attrPosTable = attrPosTable;
	}
	
	public String getTableName(){
		return tableName;
	}
	public ArrayList <Attribute> getAttributes(){
		return this.attributes;
	}
	public ArrayList<Integer> getPrimary(){
		return this.primary;
	}
	
	public Table getTable(){
		return new Table(this.tableName, this.attributes, this.primary);
	}

	public int getAttrPos(String valueName){
		if(this.attrPosTable.containsKey(valueName)){
			return this.attrPosTable.get(valueName).intValue();
		}else{
			return -1;
		}	
	}
}

