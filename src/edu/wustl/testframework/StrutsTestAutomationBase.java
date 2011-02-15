package edu.wustl.testframework;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.Statement;

import junit.framework.AssertionFailedError;
import junit.framework.TestResult;

import org.dbunit.Assertion;
import org.dbunit.DatabaseUnitException;
import org.dbunit.dataset.IDataSet;

import servletunit.struts.MockStrutsTestCase;
import edu.wustl.testframework.util.DBUnitUtility;
import edu.wustl.testframework.util.DataObject;
import edu.wustl.testframework.util.TestCaseDataUtil;


public class StrutsTestAutomationBase extends MockStrutsTestCase
{
	DataObject dataObject;

	public DataObject getDataObject()
	{
		return dataObject;
	}
	public StrutsTestAutomationBase()
	{
		super();
	}

	public StrutsTestAutomationBase(String name)
	{
		super(name);
	}

	public StrutsTestAutomationBase(String name, DataObject dataObject)
	{
		super(name);
		this.dataObject = dataObject;
	}

	public void run(TestResult result) {
		String exp = "";
		result.startTest(this);

		try {
			setUp();
			runTest();
			compareDataSets();
			truncateAuditTables();
		}
		catch (AssertionFailedError e) { //1
			exp=e.getMessage();
			e.printStackTrace();
			result.addFailure(this, e);
		}

		catch (Throwable e) { // 2
			exp=e.getMessage();
			/*if(exp == null)
			{
				exp = e.toString();
			}*/
			result.addError(this, e);
		}
		finally {
			try
			{
				System.out.println("result Object: "+result.toString());
				TestCaseDataUtil.writeToFile(result,getName(),exp,dataObject);
				tearDown();
			}
			catch(Exception e)
			{
				result.addError(this, e);
			}
		}
	}

	private void truncateAuditTables()
	{
		FileInputStream auditSQL;
		Connection conn=null;
		Statement stmt =null;
		try
		{
			auditSQL=new FileInputStream(new File(TestCaseDataUtil.getProperty("truncate.tables.file.path")));
			DataInputStream in = new DataInputStream(auditSQL);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			conn= DBUnitUtility.getConnection();
			stmt = conn.createStatement();
			while ((strLine = br.readLine()) != null)
			{
				stmt.addBatch(strLine);
			}
			stmt.executeBatch();
		}
		catch (Exception e)
		{
			System.out.println("Unable to truncate audit tables.");
			e.printStackTrace();
		}
	}

	public void compareDataSets()
	{
		if(dataObject!=null && isToCompare())
		{
			IDataSet expectedDataSet;
			IDataSet actualDataSet;
			if(getDataObject().getExpectedDataSetFileName()!=null &&
					getDataObject().getSqlFileForActualDataSet()!=null &&
					!getDataObject().getExpectedDataSetFileName().equalsIgnoreCase("") &&
					!getDataObject().getSqlFileForActualDataSet().equalsIgnoreCase(""))
			{
				expectedDataSet = DBUnitUtility.getExpectedDataSet(getDataObject().getExpectedDataSetFileName());
				actualDataSet=DBUnitUtility.getActualDataSet(getDataObject().getSqlFileForActualDataSet());
				/*try
			{
				FlatXmlDataSet.write(expectedDataSet, new FileOutputStream("expectedDataSet.xml"));
				FlatXmlDataSet.write(actualDataSet, new FileOutputStream("actualDataSet.xml"));
			}
			catch (Exception e1)
			{
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}*/
				try
				{
					Assertion.assertEquals(expectedDataSet, actualDataSet);
					dataObject.setDbVerification(true);
				}
				catch (DatabaseUnitException e)
				{
					dataObject.setDbVerification(false);
					assertFalse(e.getMessage(), true);
				}
			}
		}
	}

	private boolean isToCompare()
	{
		boolean flag=false;
		if(getName().equals(TestCaseDataUtil.getProperty("login.testcase.name"))||
				getName().equals(TestCaseDataUtil.getProperty("logout.testcase.name"))||
				getName().equals(TestCaseDataUtil.getProperty("init.testcase.name")))
		{
			flag=false;
		}
		else
		{
			flag=true;
		}
		return flag;
	}

	public TestResult run() {
		TestResult result= createResult();
		run(result);
		return result;
	}
	//
	protected void runTest() throws Throwable {
		Method runMethod= null;
		try {
			runMethod= getClass().getMethod(getName(), new Class[0]);
		} catch (NoSuchMethodException e) {
			assertTrue("Method \""+getName()+"\" not found", false);
		}
		finally {
			System.out.println("method name: "+ runMethod);
			runMethod.invoke(this, new Class[0]);
		}
		// catch InvocationTargetException and IllegalAccessException
	}
}
