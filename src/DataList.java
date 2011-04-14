
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;



public class DataList
{
	/**
	 * logger Logger - Generic logger.
	 */
	private List<String>headerList = new ArrayList<String>();
	private List<Hashtable<String, String>>valueList = new ArrayList<Hashtable<String,String>>();
	private static final String STATUS_KEY="Status";
	private static final String MESSAGE_KEY="Message";
	public void setHeaderList(List<String>list)
	{
		headerList = list;
	}
	public List<String> getHeaderList()
	{
		return headerList;
	}
	public void setHeaderList(String[] headers)
	{
		for(int i=0;i<headers.length;i++)
		{
			addHeader(headers[i]);
		}
	}
	public void addHeader(String header)
	{
		headerList.add(header);
	}
	public void addNewValue(String[] values)
	{
		Hashtable<String,String> valueTable = new Hashtable<String, String>(); 
		valueList.add(valueTable);
		int lastIndex = valueList.size()-1;
		for(int i=0;i<headerList.size();i++)
		{
			String value = null; 
			if(values[i] == null)
			{
				value = "";
			}
			value = values[i].trim();
			setValue(headerList.get(i),value, lastIndex);
		}
	}
	public void setValue(String header, String value, int index)
	{
		Hashtable<String,String> valueTable = valueList.get(index);
		valueTable.put(header, value);
	}
	public Hashtable<String, String>getValue(int index)
	{
		return valueList.get(index);
	}
	
	public int size()
	{
		return  valueList.size();
	}
	
	public boolean checkIfColumnExists(String headerName)
	{
		return headerList.contains(headerName);
	}
	public boolean checkIfColumnHasAValue(int index,String headerName)
	{
		boolean hasValue = false;
		Hashtable<String,String> valueTable = valueList.get(index);
		Object value = valueTable.get(headerName);
		if(value!=null && !"".equals(value.toString()))
		{
			hasValue = true;
		}
		return hasValue;
	}
	public boolean checkIfAtLeastOneColumnHasAValue(int index,List<String> attributeList)
	{
		boolean hasValue = false;
		if(!attributeList.isEmpty())
		{
			for(int i=0;i<attributeList.size();i++)
			{
				hasValue = checkIfColumnHasAValue(index,attributeList.get(i));
				if(hasValue)
				{
					break;
				}
			}
		}
		return hasValue;
	}
	public void addStatusMessage(int index,String status,String message)
	{
		Hashtable<String,String> valueTable = valueList.get(index);
		valueTable.put(STATUS_KEY, status);
		valueTable.put(MESSAGE_KEY, message);
	}
	
	public boolean isEmpty()
	{
		return valueList.isEmpty();
	}
}
