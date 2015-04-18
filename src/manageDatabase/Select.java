import java.util.*;

public class Select extends Query{

	private ArrayList<String> attrList;
	private ArrayList<String> tableNames;
	private boolean selectAll;

	public Select(ArrayList<String> attrList, ArrayList<String> tableNames){
		this.queryName = "SELECT";
		this.tableNames = tableNames;
	}

	public Select(ArrayList<String> tableNames, boolean selectAll){
		this.queryName = "SELECT";
		this.tableNames = tableNames;
		this.selectAll = true;
	}

	public ArrayList<String> getTableNames(){
		return this.tableNames;
	}

	public ArrayList<String> getAttrStrList(){
		return this.attrList;
	}


	public boolean isSelectAll(){
		return this.selectAll;
	}



}
