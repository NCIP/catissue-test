package edu.wustl.testframework;
import java.lang.reflect.Method;

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

		}
		catch (AssertionFailedError e) { //1
			exp=e.getMessage();
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
				System.out.println("resut Object: "+result.toString());
				TestCaseDataUtil.writeToFile(result,getName(),exp,dataObject);
				tearDown();
			}
			catch(Exception e)
			{
				result.addError(this, e);
			}
		}
	}

	public void compareDataSets()
	{
		if(dataObject!=null && isToCompare())
		{
			IDataSet expectedDataSet;
			IDataSet actualDataSet;
			expectedDataSet = DBUnitUtility.getExpectedDataSet(getDataObject().getExpectedDataSetFileName());
			actualDataSet=DBUnitUtility.getActualDataSet(getDataObject().getSqlFileForActualDataSet());
			try
			{
				Assertion.assertEquals(expectedDataSet, actualDataSet);
				dataObject.setDbVerification(true);
			}
			catch (DatabaseUnitException e)
			{
				//assertFalse(e.getMessage(), true);
				dataObject.setDbVerification(false);
				assertFalse(e.getMessage(), true);
				//fail("failed");
				//e.printStackTrace();
			}
		}
	}

	private boolean isToCompare()
	{
		return (getDataObject().getName().equals(TestCaseDataUtil.getProperty("login.testcase.name"))
				||	getDataObject().getName().equals(TestCaseDataUtil.getProperty("logout.testcase.name"))
		        );
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
