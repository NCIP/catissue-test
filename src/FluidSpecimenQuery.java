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
import edu.wustl.catissuecore.domain.CollectionProtocolRegistration;
import edu.wustl.catissuecore.domain.FluidSpecimen;
import edu.wustl.catissuecore.domain.SpecimenCollectionGroup;
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

import javax.xml.namespace.QName;



public class FluidSpecimenQuery
{
	public int getFluidSpecimen(CaTissueSuiteClient client,String registrationId, String[] specimenSampleType) throws Exception
	{
		int count=0;
		CQLQuery query = new CQLQuery(); 
		gov.nih.nci.cagrid.cqlquery.Object target = new gov.nih.nci.cagrid.cqlquery.Object();
				
		target.setName(FluidSpecimen.class.getName());
		
		Group group = new Group();
		group.setLogicRelation(LogicalOperator.AND);
		
		Attribute activityStatus = new Attribute();
		activityStatus.setPredicate(Predicate.NOT_EQUAL_TO);
		activityStatus.setName("activityStatus");
		activityStatus.setValue("Disabled");
		
		Attribute collectionStatus = new Attribute();
		collectionStatus.setPredicate(Predicate.NOT_EQUAL_TO);
		collectionStatus.setName("collectionStatus");
		collectionStatus.setValue("Collected");
		
		Attribute[] samples = new Attribute[specimenSampleType.length+2];
		samples[specimenSampleType.length]=activityStatus;
		samples[specimenSampleType.length+1]=collectionStatus;
		
		for(int i =0;i<samples.length-2;i++)
		{
			samples[i] = new Attribute();
			samples[i].setName("specimenType");
			samples[i].setPredicate(Predicate.EQUAL_TO);
			samples[i].setValue(specimenSampleType[i]);
		}
		group.setAttribute(samples);
		
		Association scgAssociation = new Association();
		scgAssociation.setRoleName("specimenCollectionGroup");
		scgAssociation.setName(SpecimenCollectionGroup.class.getName());
		group.setAssociation(new Association[]{scgAssociation});
		
		Group scgGroup = new Group();
		scgGroup.setLogicRelation(LogicalOperator.AND);
		scgAssociation.setGroup(scgGroup);
		
		Attribute scgactivityStatus = new Attribute();
		scgactivityStatus.setPredicate(Predicate.NOT_EQUAL_TO);
		scgactivityStatus.setName("activityStatus");
		scgactivityStatus.setValue("Disabled");
		
		scgGroup.setAttribute(new Attribute[]{scgactivityStatus}); 
		
		Association cprAssociation = new Association();
		cprAssociation.setRoleName("collectionProtocolRegistration");
		cprAssociation.setName(CollectionProtocolRegistration.class.getName());
		Attribute cprId = new Attribute();
		cprId.setPredicate(Predicate.EQUAL_TO);
		cprId.setName("id");
		cprId.setValue(registrationId);
		cprAssociation.setAttribute(cprId);
		//scgAssociation.setAssociation(cprAssociation);
		
		Association[] cprAssotions = new Association[]{cprAssociation};
		scgGroup.setAssociation(cprAssotions);
		//group.setAssociation(new Association[]{scgAssociation});
		//group.setGroup(new Group[]{scgGroup});
		//target.setAssociation(scgAssociation);
		target.setGroup(group);
		query.setTarget(target);
		
		Utils.serializeDocument("my.caml", query, new QName("http://CQL.caBIG/1/gov.nih.nci.cagrid.CQLQuery"));
		
		CQLQueryResults cqlQueryResult = client.query(query);
		CQLQueryResultsIterator iter = new CQLQueryResultsIterator(cqlQueryResult, true);
		while(iter.hasNext())
		{
			FileWriter fw = new FileWriter("temp.xml");
			fw.write((String)iter.next());
			fw.close();
			FluidSpecimen specimen = (FluidSpecimen)XMLUtility.fromXML(new File("temp.xml"));
			
			System.out.println("FluidSpecimen id "+specimen.getId());
			count++;
		}
		return count;
	}
}
