/*L
 *  Copyright Washington University in St. Louis
 *  Copyright SemanticBits
 *  Copyright Persistent Systems
 *  Copyright Krishagni
 *
 *  Distributed under the OSI-approved BSD 3-Clause License.
 *  See http://ncip.github.com/catissue-test/LICENSE.txt for details.
 */

import edu.wustl.catissuecore.client.CaTissueSuiteClient;
import edu.wustl.catissuecore.domain.CollectionProtocol;
import gov.nih.nci.cagrid.cqlquery.Attribute;
import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlquery.Predicate;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.utilities.CQLQueryResultsIterator;
import gov.nih.nci.common.util.XMLUtility;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;



public class CollectionProtocolQuery
{
	public List<CollectionProtocol> getCollectionProtocolList(CaTissueSuiteClient client) throws Exception
	{
		CQLQuery query = new CQLQuery(); 
		gov.nih.nci.cagrid.cqlquery.Object target = new gov.nih.nci.cagrid.cqlquery.Object(); 
		target.setName("edu.wustl.catissuecore.domain.CollectionProtocol");
		
		Attribute activityStatus = new Attribute();
		activityStatus.setPredicate(Predicate.NOT_EQUAL_TO);
		activityStatus.setName("activityStatus");
		activityStatus.setValue("Disabled");
		target.setAttribute(activityStatus);
		
		query.setTarget(target);
		
		CQLQueryResults cqlQueryResult = client.query(query);
		
		CQLQueryResultsIterator iter = new CQLQueryResultsIterator(cqlQueryResult, true);
		int count=0;
		List results = new ArrayList();
		while(iter.hasNext())
		{
			FileWriter fw = new FileWriter("temp.xml");
			fw.write((String)iter.next());
			fw.close();
			CollectionProtocol cp = (CollectionProtocol )XMLUtility.fromXML(new File("temp.xml"));
			results.add(cp);
		}
		return results;
	}
}
