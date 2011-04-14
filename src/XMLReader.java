import java.io.File;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

public class XMLReader 
{

 public static void main(String argv[]) 
 {

  try
	 {
	/*DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
	DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
	Document doc = docBuilder.parse (new File("d:/Nitesh/coverage.xml")); // normalize text representation
	doc.getDocumentElement ().normalize ();
	System.out.println ("Root element of the doc is" + doc.getDocumentElement().getNodeName()); 
	//NodeList listOfPersons = doc.getElementsByTagName("coverage line-rate");
	*/
	  File file = new File("d:\\Nitesh\\coverage.xml");
	  DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

	  dbf.setValidating(false);
	  dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);

	 
	  DocumentBuilder db = dbf.newDocumentBuilder();
	  Document doc = db.parse(file);
	  doc.getDocumentElement().normalize();
	  System.out.println("Root element " + doc.getDocumentElement().getNodeName());
	  /*NodeList nodeLst = doc.getElementsByTagName("employee");
	  System.out.println("Information of all employees");*/
	 }
   catch (Exception e) 
   {
    e.printStackTrace();
  }
 }
}

