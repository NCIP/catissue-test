package edu.wustl.testframework.util;


import java.util.StringTokenizer;

public class DataObject
{
	String id;
	String name;
	String values[];
	String username;
	String password;
	String className;

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
	public void addValues(String [] values)
	{

			id = values[0];
			name = values[1];
			className = values[2];
			username = values[3];
			password = values[4];
			StringTokenizer st = new StringTokenizer(values[5], "|");
			String arr[] = new String[st.countTokens()];
			int i=0;
			while (st.hasMoreElements())
			{
				arr[i] = new String();
				arr[i] = st.nextElement().toString();
				i++;
			}
			this.values = arr;
	}
}
