import java.io.PrintStream;

import junit.framework.TestResult;


public class ResultPrinter extends junit.textui.ResultPrinter{

	public ResultPrinter(PrintStream writer) {
		super(writer);
		// TODO Auto-generated constructor stub
	}
	
	synchronized void print(TestResult result, long runTime) {
		printHeader(runTime);
	    printErrors(result);
	    printFailures(result);
	    printFooter(result);
	}

}
