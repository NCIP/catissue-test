import java.util.Map;


public class caGRIDAutomationClient
{

	public static Map<String, String> ConfFileMap;
	
	public static void main(String args[])
	{	
		/*
		 * Initializing variables
		 */
		String conf_file = "./Conf/caGrid_TestSuite.conf";
		//String caGrid_report_dir = "./caGRID_Logs";
		/*
		 * Reading conf file
		 */
		ConfFileMap = caGRID_Utility.read_bo_conf_file(conf_file);
		System.out.println("\n------"+ConfFileMap.get("Query.Suite"));
		/*
		 *  Read Query suite file and sequentially execute the queries
		 */
		
		caGRID_Utility.initial_setup(ConfFileMap.get("Detail.Report"), ConfFileMap.get("Summary.Report"));
		/*
		 * Execute Query
		 */
		caGRID_Utility.executeQuery("./"+ConfFileMap.get("Query.Suite"));
	}
}
