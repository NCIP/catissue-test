package edu.wustl.testframework;


import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.util.List;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import junit.textui.TestRunner;
import au.com.bytecode.opencsv.CSVReader;
import edu.wustl.testframework.util.DataObject;
import edu.wustl.testframework.util.TestCaseDataUtil;

/**
 * Test suite
 */


public class StrutsTestAutomation
{
	/**
	 * Default constructor.
	 */
	public StrutsTestAutomation()
	{
		super();
	}

	public static void main(String[] args)
	{
		TestRunner.run(getSuite());
	}

	/**
	 * @return daoSuite.
	 */
	public static Test getSuite()
	{


		TestSuite strutsSuite = new TestSuite("caTissue Junit Test Cases");

		try
		{

		CSVReader reader = null;
		List<String[]> list = null;

		System.getProperty("user.dir");
		String propHome = System.getProperty("strutsProp.home");
		System.out.println("propHome  "+propHome);
		TestCaseDataUtil.loadProperties(propHome+"/strutsTestPaths.properties");
//	    TestCaseDataUtil.loadProperties("E:/Program Files/Eclipse-Galileo/eclipse/workspace/catissuecore_/software/caTissue/test/struts/CaTissue_TestCases/strutsTestPaths.properties");
	    TestCaseDataUtil.createDetailReportFile();
	    System.out.println("found  "+ TestCaseDataUtil.getProperty("data.file.path"));

	    String loginTestClassName = TestCaseDataUtil.getProperty("login.testcaseClass.name");
	    String loginTestCaseName = TestCaseDataUtil.getProperty("login.testcase.name");

	    String logoutTestClassName = TestCaseDataUtil.getProperty("login.testcaseClass.name");
	    String logoutTestCaseName = TestCaseDataUtil.getProperty("logout.testcase.name");

	    String initTestClassName = TestCaseDataUtil.getProperty("init.testcaseclass.name");
		Class testClass1 = Class.forName(initTestClassName);
		Class[] constructorParameters1 = new Class[1];
		constructorParameters1[0] = String.class;

		Constructor constructor1 = testClass1.getDeclaredConstructor(constructorParameters1);
		String methodName = TestCaseDataUtil.getProperty("init.testcase.name");
		strutsSuite.addTest((TestCase)constructor1.newInstance(methodName));
		System.out.println("data.file.path   "+TestCaseDataUtil.getProperty("data.file.path"));
		File file= new File(TestCaseDataUtil.getProperty("data.file.path"));
		InputStream inputStream;

			inputStream = new FileInputStream(file);

			reader = new CSVReader(new InputStreamReader(inputStream));
			list = reader.readAll();
			reader.close();
			int size = list.size();
			if(size>0)
			{
				String[] headers = list.get(0);
			}
			if(size > 1)
			{
				for(int i = 1; i < list.size(); i++)
				{
					DataObject dataObject = new DataObject();
					String[] newValues = new String[list.get(0).length];
					for(int m = 0; m < newValues.length; m++)
					{
						newValues[m] = new String();
					}
					String[] oldValues = list.get(i);
					for(int j = 0; j < oldValues.length; j++)
					{
						newValues[j] = oldValues[j];
					}
					dataObject.addValues(newValues);
					System.out.println("testcaseName : "+dataObject.getClassName());
					Class testLoginClass = Class.forName(loginTestClassName);
					Class[] constructorLoginParameters = new Class[2];
					constructorLoginParameters[0] = String.class;
					constructorLoginParameters[1] = DataObject.class;

					Constructor Loginconstructor = testLoginClass.getDeclaredConstructor(constructorLoginParameters);

					strutsSuite.addTest((TestCase)Loginconstructor.newInstance(loginTestCaseName, dataObject));
					Class testClass = Class.forName(dataObject.getClassName());
					Class[] constructorParameters = new Class[2];
					constructorParameters[0] = String.class;
					constructorParameters[1] = DataObject.class;


					Constructor constructor = testClass.getDeclaredConstructor(constructorParameters);

					strutsSuite.addTest((TestCase)constructor.newInstance(dataObject.getName(), dataObject));

					Class testLogoutClass = Class.forName(logoutTestClassName);
					Class[] constructorLogoutParameters = new Class[1];
					constructorLogoutParameters[0] = String.class;

					Constructor logOutconstructor = testLoginClass.getDeclaredConstructor(constructorLoginParameters);

					strutsSuite.addTest((TestCase)logOutconstructor.newInstance(logoutTestCaseName, dataObject));
				}
			}

		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
//			fail("Application Initilization fail"+e.getMessage());
		}
		strutsSuite.addTestSuite(TearDownSmokeTestCase.class);
		return strutsSuite;
	}


}
