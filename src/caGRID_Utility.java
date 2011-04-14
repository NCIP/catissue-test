import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;

import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;

import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.Map.Entry;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;
import au.com.bytecode.opencsv.CSVReader;

import org.custommonkey.xmlunit.DetailedDiff;
import org.custommonkey.xmlunit.XMLUnit;
import static org.custommonkey.xmlunit.XMLAssert.*;


public class caGRID_Utility  {

	private static String query_result_status;
	private static int totalPass , totalFail, totalTc;

	public static Map<String , String > read_bo_conf_file(String conf_file)
	{
		Map<String , String > confPropertyMap = new HashMap();
		Map.Entry<Object, Object> entry = null;
		try {
			
						
			final InputStream inpurStream = new FileInputStream(new File(conf_file));

			Properties confFileProperties = new Properties();

			confFileProperties.load(inpurStream);
		
			  Set<Entry<Object, Object>> contactValues  = confFileProperties.entrySet();
			  Iterator<Entry<Object, Object>> contactIterator = contactValues.iterator();
			  while (contactIterator.hasNext())
			  {
				  entry = contactIterator.next();
				  
				  if(entry.getValue()!= null && entry.getValue().toString()!= "")
				  {
					  System.out.println("\n"+entry.getValue());	
					  confPropertyMap.put(entry.getKey().toString(), entry.getValue().toString());
				  }
			  }
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return confPropertyMap;
	}

	public static void executeQuery(String csvFileName)
	{
		DataList csvDataList= read_caGrid_Queries(csvFileName);
		int size = csvDataList.size();
		String queryxmlname, detail_report_row, summary_report_row;
		double tc_percentage;
		
		try
		{
			if(size>0)
			{
					
				for(int i = 0; i < size; i++)
				{
					Hashtable<String,String> queryRow = new Hashtable<String, String>(); 
					queryRow = csvDataList.getValue(i);
					System.out.println("++++++++++="+queryRow.get("TestId"));
					if(!queryRow.get("TestId").startsWith("#"))
					{
						System.out.println("before login");
						// caGrid Login
						//caGridLogin.Authentication(queryRow.get("username"), queryRow.get("password"));
						
						System.out.println("after login");
						// Get the Query Name
						queryxmlname = "Query3.xml";//queryRow.get("queryxmlname");
						//System.out.println("service URL: "+caGRIDAutomationClient.ConfFileMap.get("Service.Url"));
						
						// Excute the query
						CaTissueSuiteClient.executeQuery(caGRIDAutomationClient.ConfFileMap.get("Service.Url"),queryxmlname);
						
						// Compare the result XML file
						compareQueryOutput("./Query_Base/"+queryxmlname , "./Query_Output/"+queryxmlname);
						
						detail_report_row = create_report_row(queryRow, query_result_status);
						System.out.println("++++detail_report_row==="+detail_report_row);
						write_report(caGRIDAutomationClient.ConfFileMap.get("Detail.Report"),detail_report_row );
					}
				}
				tc_percentage = get_tc_percentage(totalTc , totalPass, totalFail);
				System.out.println("++++tc_percentage==="+tc_percentage);
				summary_report_row = create_report_row(totalTc , totalPass, totalFail , tc_percentage);
				System.out.println("++++summary_report_row==="+summary_report_row);
				write_report(caGRIDAutomationClient.ConfFileMap.get("Summary.Report"), summary_report_row );
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	/*
	 * Function Name: caGrid_Queries Description : Reading queries from
	 * caGrid_Queries file and execute them sequentially Arguments : File name
	 */
	public static DataList read_caGrid_Queries(String caGRIDQuerySuite)
	{
	
		String[] keys = {};
		CSVReader reader = null;
		List<String[]> list = null;
		DataList dataList = new DataList();
		
		System.out.println("caGRIDQuerySuite========"+caGRIDQuerySuite);
			
		try
		{
			File fileName = new File(caGRIDQuerySuite);
			
			InputStream inputStream = new FileInputStream(fileName);
			reader = new CSVReader(new InputStreamReader(inputStream));
			list = reader.readAll();
			reader.close();		
			int size = list.size();
			if(size>0)
			{
				String[] headers = list.get(0);				
				for(int i=0;i<headers.length;i++)
				{
					System.out.println("headers[i]=="+headers[i]);
						dataList.addHeader(headers[i].trim());
				}
			}
			if(size > 1)
			{	
				for(int i = 1; i < list.size(); i++)
				{
					String[] newValues = new String[list.get(0).length];// + 2];
					for(int m = 0; m < newValues.length; m++)
					{
						newValues[m] = new String();
					}
					String[] oldValues = list.get(i);
					for(int j = 0; j < oldValues.length; j++)
					{
						newValues[j] = oldValues[j]; 
					}
						dataList.addNewValue(newValues);
					}
				}
			else if(size > 0)
			{
				String[] values = new String[list.get(0).length ]; //+ 2];
				for(int i = 0; i < (list.get(0).length ); i++)
				{
					values[i] = "";
				}
				for(int i = 0;i < (list.get(0).length); i++)
				{					 
					dataList.addNewValue(values);
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
			
		return dataList;
	}
	
	/*
	 *  Function : compareQueryOutput
	 *  
	 */
	public static void compareQueryOutput(String queryBaseFile , String queryOutputFile)
	{
		try 
		{
			System.out.println("queryBaseFile :"+queryBaseFile);
			System.out.println("queryOutputFile:"+queryOutputFile);
			
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			dbf.setNamespaceAware(true);
			dbf.setCoalescing(true);
			dbf.setIgnoringElementContentWhitespace(true);
			dbf.setIgnoringComments(true);
			DocumentBuilder db;
			
			db = dbf.newDocumentBuilder();
						
			org.w3c.dom.Document doc1 = db.parse(new File(queryBaseFile));
			((org.w3c.dom.Document) doc1).normalizeDocument();
	
			org.w3c.dom.Document doc2 = db.parse(new File(queryOutputFile));
			((org.w3c.dom.Document) doc2).normalizeDocument();
			System.out.println("COmparision of two xml :");
		
			DetailedDiff myDiff = new DetailedDiff(XMLUnit.compareXML(doc1, doc2));
	        List allDifferences = myDiff.getAllDifferences();
	        System.out.println("Expected message : "+myDiff.toString());
	        System.out.println("allDifferences.size() : "+allDifferences.size());
	        assertEquals(myDiff.toString(), 0, allDifferences.size());
	        
	        if(allDifferences.size() ==  0)
	        {
	        	query_result_status = "Pass";
	        	totalPass++;
	        	System.out.println("Query Result is correct"+totalPass);
	        }
	        else
	        {
	        	query_result_status = "Fail";
	        	totalFail++;
	        	System.out.println("Query Result is incorrect"+totalFail);
	        }
	        
	        totalTc++;
		}
		catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/*
	 * Funcation Name	: initial_setup
	 * Description		:
	 * Arguments		: caGrid_report_dir, detail_report, summary_report
	 * Return Values	: -
	 */
	
	public static void initial_setup(String caGrid_detail_report, String caGrid_summary_report)
	{
	    String detail_csv_header = "Test Id , QueryName , Query Summary, Query Execution Status," +
	    				 "Result Verification, Logs";
	    String summary_csv_header = "Scenario, Total Test cases Executed, Passed, Failed, Percent Passed(%)";
       
	    // Writing initial Headers in Report (csv) file
	    write_report(caGrid_detail_report, detail_csv_header);
	      
	    write_report(caGrid_summary_report, summary_csv_header);
	}
	
	/*
	 * Funcation Name : write_report
	 * Description    :
	 * Arguments	  : caGrid Detail report file / caGrid Summary report file
	 * Return Values  : -
	 */

	public static void write_report(String caGrid_report_file, String csv_row)
	{
	    
	    PrintWriter pw = null;
	    
	    System.out.println("report_file =====>"+caGrid_report_file);
	    System.out.println("report_file =====>"+csv_row);
	    try
	    {
	      // created as a separate variable to emphasize that I'm appending to this file
	      boolean append = true;
	      pw = new PrintWriter(new FileWriter(new File(caGrid_report_file), append));
	      pw.println(csv_row);
	    }
	    catch (IOException e)
	    {
	      e.printStackTrace();
	      // deal with the exception
	    }
	    finally
	    {
	    // close file 
	      pw.close();
	    }
	}
	
	public static String create_report_row(Hashtable<String, String> queryRow, String query_result_status)
	{
		String seperator = ", ";
		String query_detail_row = queryRow.get("TestId")+seperator+queryRow.get("queryxmlname")+
								  seperator+ queryRow.get("QuerySummary")+seperator+" "+seperator+
								  query_result_status+seperator;
		
		return query_detail_row;
	}

	/*
	 * Funcation Name	: get_tc_percentage
	 * Description		: Calculating percentage
	 * Arguments		: $total_tc,$total_tc_pass,$total_tc_fail
	 * Return Values	: Percentage value
	 */
	
	private static double get_tc_percentage(int testTotal, int testPass, int testFail) 
	{

	    double result = ( 100 * testPass ) / testTotal;
		// Rounding to 2 digits
		DecimalFormat df = new DecimalFormat("0.00");

		result = new Double(df.format(result)).doubleValue();
		
	    return result;
	}
	
	/*
	 * Funcation Name	: create_report_row
	 * Description		: 
	 * Arguments		: totalTc, totalPass, totalFail
	 * Return Values	: Percentage value
	 */
	
	private static String create_report_row(int testTotal, int testPass,
	int testFail, double tc_percentage) 
	{
		String seperator = ", ";
		String query_summary_row = " "+seperator+testTotal+seperator+testPass+
								  seperator+testFail+seperator+tc_percentage;
		
		return query_summary_row;
	}
}
