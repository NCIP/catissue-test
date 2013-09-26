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
import edu.wustl.catissuecore.domain.CollectionProtocolRegistration;
import gov.nih.nci.cagrid.common.Utils;
import gov.nih.nci.cagrid.cqlquery.Association;
import gov.nih.nci.cagrid.cqlquery.Attribute;
import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlquery.Group;
import gov.nih.nci.cagrid.cqlquery.LogicalOperator;
import gov.nih.nci.cagrid.cqlquery.Predicate;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.utilities.CQLQueryResultsIterator;
import gov.nih.nci.common.util.XMLUtility;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

import javax.xml.namespace.QName;



public class CollectionProtocolRegistrationQuery
{
	public static List<CollectionProtocolRegistration> getRegisteredParticipantCount(CaTissueSuiteClient client,String collectionProtocolid) throws Exception
	{
		List<CollectionProtocolRegistration> results = new ArrayList<CollectionProtocolRegistration>();
		CQLQuery query = new CQLQuery(); 
		gov.nih.nci.cagrid.cqlquery.Object target = new gov.nih.nci.cagrid.cqlquery.Object();
		target.setName(CollectionProtocolRegistration.class.getName());

		Group group = new Group();
		group.setLogicRelation(LogicalOperator.AND);
		Attribute activityStatus = new Attribute();
		activityStatus.setPredicate(Predicate.NOT_EQUAL_TO);
		activityStatus.setName("activityStatus");
		activityStatus.setValue("Disabled");
		
		Attribute attributes[] = new Attribute[]{activityStatus};
		group.setAttribute(attributes);
		target.setGroup(group);

		 
		Association association = new Association();
		association.setRoleName("collectionProtocol");
		association.setName(CollectionProtocol.class.getName());
		
				
		Attribute cpIdentifier = new Attribute();
		cpIdentifier.setPredicate(Predicate.EQUAL_TO);
		cpIdentifier.setName("id");
		cpIdentifier.setValue(collectionProtocolid);
		association.setAttribute(cpIdentifier);
//		target.setAssociation(association);
		Association[] associations = new Association[]{association};
		group.setAssociation(associations);
		query.setTarget(target);
		
		Utils.serializeDocument("my.caml", query, new QName("http://CQL.caBIG/1/gov.nih.nci.cagrid.CQLQuery"));
		CQLQueryResults cqlQueryResult = client.query(query);
		CQLQueryResultsIterator iter = new CQLQueryResultsIterator(cqlQueryResult, true);
		while(iter.hasNext())
		{
			FileWriter fw = new FileWriter("temp.xml");
			fw.write((String)iter.next());
			fw.close();
			CollectionProtocolRegistration cp = (CollectionProtocolRegistration)XMLUtility.fromXML(new File("temp.xml"));
			results.add(cp);
		}
		return results;
	}
}
