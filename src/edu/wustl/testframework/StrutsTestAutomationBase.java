package edu.wustl.testframework;
import java.lang.reflect.Method;

import edu.wustl.testframework.util.DataObject;
import edu.wustl.testframework.util.TestCaseDataUtil;

import junit.framework.AssertionFailedError;
import junit.framework.TestResult;
import servletunit.struts.MockStrutsTestCase;


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
	    }
	    catch (AssertionFailedError e) { //1
	    	exp=e.getMessage();
	        result.addFailure(this, e);
	    }

	    catch (Throwable e) { // 2
	    	exp=e.getCause().getMessage();
	    	if(exp == null)
	    	{
	    		exp = e.toString();
	    	}
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
