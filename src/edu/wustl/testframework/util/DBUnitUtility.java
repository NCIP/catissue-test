package edu.wustl.testframework.util;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.logging.Logger;

import org.dbunit.database.AmbiguousTableNameException;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.database.QueryDataSet;
import org.dbunit.dataset.DataSetException;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.xml.FlatXmlDataSet;


public class DBUnitUtility
{

	static Logger logger = Logger.getLogger("DBUnitUtility");

	private static FlatXmlDataSet loadedDataSet;
	static IDatabaseConnection connection = null;
	/*static File expectedDataSetsDir;
	static File sqlFilesDir;
	static Properties expectedDataSetProp;
	static Properties sqlFilesProp;*/

	/*public static void init()
	{
		expectedDataSetsDir = new File(TestCaseDataUtil.getProperty("expecteddataset.dir.path"));
		sqlFilesDir = new File(TestCaseDataUtil.getProperty("actualDataset.sql.dir.path"));
		expectedDataSetProp= new Properties();
		sqlFilesProp= new Properties();
		try
		{
			expectedDataSetProp.load(new FileInputStream(expectedDataSetsDir));
			sqlFilesProp.load(new FileInputStream(sqlFilesDir));
		}
		catch (FileNotFoundException e)
		{
			logger.info("expectedDataSets.properties file not found.");
			e.printStackTrace();
		}
		catch (IOException e)
		{
			logger.info("Unable to read expectedDataSets.properties file.");
			e.printStackTrace();
		}
	}*/

	private static IDatabaseConnection getConnection() throws Exception
	{
		String driver = null;
		String URL=null;
		if(connection==null)
		{
			if(DataSourceFinder.databaseType.equals("mysql"))
			{
				driver="com.mysql.jdbc.Driver";
				URL="jdbc:mysql://"+DataSourceFinder.databaseHost+":"+DataSourceFinder.port+"/"+DataSourceFinder.databaseName;
			}
			else if(DataSourceFinder.databaseType.equals("oracle"))
			{
				driver="oracle.jdbc.driver.OracleDriver";
				URL="jdbc:oracle:thin:@"+DataSourceFinder.databaseHost+":"+DataSourceFinder.port+":"+DataSourceFinder.databaseName;
			}
			Class driverClass = Class.forName(driver);
			Connection jdbcConnection =DriverManager.getConnection(URL,DataSourceFinder.databaseUser, DataSourceFinder.databasePassword);
			connection=new DatabaseConnection(jdbcConnection);
		}
		return connection;
	}

	public static IDataSet getExpectedDataSet(String expectedDataSetFileName)
	{
		try
		{
			//loadedDataSet =new FlatXmlDataSet(new FileInputStream(new File("F:/Test_caTissue/caTISSUE_Suite_v2.0_Installable/CaTissue_TestCases/expectedDepartment.xml")));
			System.out.println(TestCaseDataUtil.getProperty("expecteddataset.dir.path")+File.separator+expectedDataSetFileName);
			loadedDataSet =new FlatXmlDataSet(new FileInputStream(new File(TestCaseDataUtil.getProperty("expecteddataset.dir.path")+File.separator+expectedDataSetFileName)));
		}
		catch (DataSetException e)
		{
			logger.info("DataSetException");
			e.printStackTrace();
		}
		catch (FileNotFoundException e)
		{
			logger.info("Expected DataSet not found.");
			e.printStackTrace();
		}
		catch (IOException e)
		{
			logger.info("Error while reading Expected DataSet.");
			e.printStackTrace();
		}
		return loadedDataSet;
	}


	public static IDataSet getActualDataSet(String sqlFileName)
	{
		QueryDataSet partialDataSet = null;
		FileInputStream fstream;
		try
		{
			System.out.println(TestCaseDataUtil.getProperty("actualDataset.sql.dir.path")+File.separator+sqlFileName);
			fstream = new FileInputStream(new File(TestCaseDataUtil.getProperty("actualDataset.sql.dir.path")+File.separator+sqlFileName));
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));


			String strLine;
			//StringTokenizer queries=new StringTokenizer(queriesProp.getProperty(testCaseName),"|");

			while ((strLine = br.readLine()) != null)
			{
				if(partialDataSet==null)
				{
					partialDataSet = new QueryDataSet(getConnection());
				}
				String[] tableAndQuery=strLine.split(";");
				String tableName=tableAndQuery[0];
				String query=tableAndQuery[1];
				try
				{
					partialDataSet.addTable(tableName,query);
				}
				catch (AmbiguousTableNameException e)
				{
					logger.info("Exception while creating Actual DataSet." +e.getMessage());
					e.printStackTrace();
				}
			}
		}
		catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		/*	if(queries!= null)
		{
			try
			{
				partialDataSet = new QueryDataSet(getConnection());
			}
			catch (Exception e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			while(queries.hasMoreTokens())
			{
				String queryData=queries.nextToken();
				String[] tableAndQuery=queryData.split(";");
				String tableName=tableAndQuery[0];
				String query=tableAndQuery[1];
				try
				{
					partialDataSet.addTable(tableName, query);
				}
				catch (AmbiguousTableNameException e)
				{
					logger.info("Exception while creating Actual DataSet." +e.getMessage());
					e.printStackTrace();
				}
			}
		}*/
		return partialDataSet;
	}

}

