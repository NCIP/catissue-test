
import gov.nih.nci.cagrid.common.security.ProxyUtil;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import org.apache.log4j.Logger;
import org.globus.gsi.GlobusCredential;

/*
 *  
 */

public class caGridLogin
{
	public static GlobusCredential globusCredential = null;
    private static final Logger logger = Logger.getLogger("");

    public static Object Authentication(String UserName , String Password) throws IOException 
    {
    	try
        {
            if (UserName == null || UserName.length()== 0 || Password == null || Password.length()== 0)
            {
                return "Please enter the User name and Password";
            }
            else
            {
            	System.out.println("\n In caGrid Login else");
                
				try
				{
					globusCredential = new caGridAuthenticator(UserName).validateUser(Password);
					System.out.println(globusCredential.getIdentity());
					//ProxyUtil.saveProxy(credentails, getPropert(DEFAULT_PROXY_FILENAME));
                }
				catch (Exception e)
                {
                    logger.error(e.getMessage());
                }
				return globusCredential;
            }
        }
    	catch (Exception e)
        {
            logger.error(e.getMessage());
         }
    	return "";
     }
    
    
    private void getPropert()
    {
    	Map<String, String> allProp = System.getenv();
    	Set<Entry<String, String>> prop = allProp.entrySet();
    	for (Entry<String, String> entry : prop) {
			System.out.println("Property : " + entry.getKey() + " Value : " + entry.getValue());
			
		}
    }
}