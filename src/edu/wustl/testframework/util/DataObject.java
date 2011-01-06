package edu.wustl.testframework.util;


import java.util.StringTokenizer;

public class DataObject
{
	private String id;
	private String name;
	private String values[];
	private String username;
	private String password;
	private String className;
	private String expectedDataSetFileName;
	private String sqlFileForActualDataSet;
	private boolean dbVerification;


	public boolean isDbVerification()
	{
		return dbVerification;
	}

	public void setDbVerification(boolean dbVerification)
	{
		this.dbVerification = dbVerification;
	}
	public String getClassName() {
		return className;
	}
	public void setClassName(String className) {
		this.className = className;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getId()
	{
		return id;
	}
	public void setId(String id)
	{
		this.id = id;
	}
	public String getName()
	{
		return name;
	}
	public void setName(String name)
	{
		this.name = name;
	}
	public String[] getValues()
	{
		return values;
	}
	public void setValues(String[] values)
	{
		this.values = values;
	}

	public String getExpectedDataSetFileName()
	{
		return expectedDataSetFileName;
	}

	public void setExpectedDataSetFileName(String expectedDataSetFileName)
	{
		this.expectedDataSetFileName = expectedDataSetFileName;
	}

	public String getSqlFileForActualDataSet()
	{
		return sqlFileForActualDataSet;
	}

	public void setSqlFileForActualDataSet(String sqlFileForActualDataSet)
	{
		this.sqlFileForActualDataSet = sqlFileForActualDataSet;
	}

	public void addValues(String [] values)
	{

		this.setId(values[0]);
		this.setName(values[1]);
		this.setClassName(values[2]);
		this.setUsername(values[3]);
		this.setPassword(values[4]);
		StringTokenizer st = new StringTokenizer(values[5], "|");
		String arr[] = new String[st.countTokens()];
		int i=0;
		while (st.hasMoreTokens())
		{
			arr[i] = new String();
			arr[i] = st.nextElement().toString();
			i++;
		}
		this.setExpectedDataSetFileName(values[6]);
		this.setSqlFileForActualDataSet(values[7]);
		this.values = arr;
	}



}
