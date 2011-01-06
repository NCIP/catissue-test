package edu.wustl.testframework.util;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;

import junit.framework.TestResult;

public class TestCaseDataUtil
{
	private static Properties properties = new Properties();

	public static void loadProperties(String path) throws FileNotFoundException, IOException
	{
		properties.load(new FileInputStream(path));
	}

	public static String getProperty(String propName)
	{
		return properties.getProperty(propName);
	}

	public static void writeToFile(TestResult result,String name,String err, DataObject dataObject)
	{
		File file = null;
		FileWriter writer = null;
		try
		{
			System.out.println("getProperty :"+ getProperty("detailed.report.file.dir"));
			file = new File(getProperty("detailed.report.file.dir"));
			writer = new FileWriter(file,true);
			StringBuffer line = new StringBuffer();
//			for(int i=0;i<valueListSize;i++)
//			{
				line.setLength(0);
//				DataObject dataObject = getDataObject(name);
//				for(int i=0;i<valueListSize;i++)
//				{
				String testResult;
				if (result.wasSuccessful())
				{
					testResult = "Success";
				}
				else
				{
					testResult = "Failure";
				}
				System.out.println("dataObject :"+dataObject);
				if(dataObject == null)
				{
					line.append(1+","+name+","+testResult+",,,"+Boolean.toString(false)+",,"+err);
				}
				else
				{
					line.append(dataObject.getId()+","+name+","+testResult+",,,"+dataObject.isDbVerification()+",,"+err);
				}
//				}
				line.deleteCharAt(line.length()-1);
				line.append("\n");
				writer.append(line.toString());
//			}
		}
		catch (IOException ioExp)
		{

			ioExp.printStackTrace();
		}
		finally
		{
			try
			{
				writer.close();
			}
			catch (IOException exp)
			{
				exp.printStackTrace();
			}
		}
	}

	public static void createSummaryReport(TestResult result)
	{
		System.out.println("summary.report.file.dir : "+getProperty("summary.report.file.dir"));
		String fileName= getProperty("summary.report.file.dir");
		FileWriter writer = null;
		try
		{
		File file= new File(fileName);
		if(file.exists())
			file.delete();
		file.createNewFile();
		writer = new FileWriter(file,true);
		int valueListSize = 8;
		StringBuffer line = new StringBuffer();
			line.setLength(0);

			line.append("Scenario,Total Test cases Executed,Passed,Failed,Percent Passed(%)");
			line.deleteCharAt(line.length()-1);
			line.append("\n");
			int failedTestCount = result.errorCount()+result.failureCount();
			int passedTestCount = result.runCount()-failedTestCount;
			int totalTestCount = result.runCount();
			double passedPercent = (double)(passedTestCount*100)/(double)totalTestCount;
			line.append("Fresh,"+result.runCount()+","+passedTestCount+","+failedTestCount+","+passedPercent);
			writer.append(line.toString());
	}
	catch (IOException ioExp)
	{

		ioExp.printStackTrace();
	}
	finally
	{
		try
		{
			writer.close();
		}
		catch (IOException exp)
		{
			exp.printStackTrace();
		}
	}

	}

	public static void createDetailReportFile()
	{
		File file = null;
		FileWriter writer = null;
		try
		{
			System.out.println("getProperty :"+ getProperty("detailed.report.file.dir"));
			file = new File(getProperty("detailed.report.file.dir"));
			if(file.exists())
				file.delete();
			file.createNewFile();
			writer = new FileWriter(file,true);
			StringBuffer line = new StringBuffer();
			line.setLength(0);

			line.append("TMT_TestCase_Id,Test Summary,Test Execution Status,Time Taken(sec),Report Verification,DataBase Verification,Audit Event Verification,Log");
			line.deleteCharAt(line.length()-1);
			line.append("\n");
			writer.append(line.toString());
		}
		catch (IOException ioExp)
		{
			ioExp.printStackTrace();
		}
		finally
		{
			try
			{
				writer.close();
			}
			catch (IOException exp)
			{
				exp.printStackTrace();
			}
		}
	}
}
