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
import gov.nih.nci.cagrid.authentication.bean.BasicAuthenticationCredential;
import gov.nih.nci.cagrid.authentication.bean.Credential;
import gov.nih.nci.cagrid.authentication.client.AuthenticationClient;
import gov.nih.nci.cagrid.common.Utils;
import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.utilities.CQLQueryResultsIterator;
import gov.nih.nci.cagrid.dorian.client.IFSUserClient;
import gov.nih.nci.cagrid.dorian.ifs.bean.DelegationPathLength;
import gov.nih.nci.cagrid.dorian.ifs.bean.ProxyLifetime;
import gov.nih.nci.system.applicationservice.ApplicationService;
import gov.nih.nci.system.applicationservice.ApplicationServiceProvider;
import gov.nih.nci.system.comm.client.ClientSession;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.sql.Connection;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.StringTokenizer;

import org.apache.log4j.PropertyConfigurator;
import org.globus.gsi.GlobusCredential;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.mapping.Property;


public class CaTissueClient
{
	static ApplicationService appService;
	//static List<StringBuffer> resultList = new ArrayList<StringBuffer>();
	static String gridURL;
	static Properties prop = new Properties();
	static StringBuffer str;
	static Hashtable<String, String> classAndTableName = new Hashtable<String, String>();
	static Connection conn;
	static Session session;
	static Configuration cfg;

	static GlobusCredential proxy;
	public static void init(String fileName,boolean onlyCQL) throws Exception
	{
		
		if(!onlyCQL)
		{
			appService = ApplicationServiceProvider.getRemoteInstance(prop.getProperty("cacoreServiceURL"));
			ClientSession cs = ClientSession.getInstance();
			cs.startSession(prop.getProperty("cacoreUser"), prop.getProperty("cacorePassword"));
			
			PropertyConfigurator.configure("./my_hib/ApplicationResources.properties");
			cfg = new Configuration();
			File file = new File("./my_hib/hibernate.cfg.xml");
			cfg.configure(file);
			
			SessionFactory sf = cfg.buildSessionFactory();
			session = sf.openSession();
		}
		
		gridURL=prop.getProperty("cagridServiceURL");
		initGridCredentials();
		
		
		
	}
	public static void main(String[] args)
	{
		try
		{
			prop.load(new FileInputStream(args[0]));
			
			String multipleInstance = prop.getProperty("runCQLOnMultipleInstance");
			System.out.println(multipleInstance);
			boolean isOnlyCQL = Boolean.valueOf(multipleInstance).booleanValue();
//			if(Boolean.valueOf(multipleInstance).booleanValue())
//			{
//				init(args[0],true);
//				testCQLWithMultipleInstance();
//			}
				init(args[0],isOnlyCQL);
				/**
				 * cannot query known objects
				 * AbstractPosition,AbstractSpecimen,AbstractSpecimenCollectionGroup,ReportedProblem,ReturnEventParameters
				 * ReviewEventParameters,SpecimenArrayOrderItem,SpecimenEventParameters,SpecimenProtocol
				 */
				//String completeDomainClassName[] = new String[]{"edu.wustl.catissuecore.domain.Address","edu.wustl.catissuecore.domain.Biohazard","edu.wustl.catissuecore.domain.CancerResearchGroup","edu.wustl.catissuecore.domain.Capacity","edu.wustl.catissuecore.domain.CellSpecimen","edu.wustl.catissuecore.domain.CellSpecimenRequirement","edu.wustl.catissuecore.domain.CellSpecimenReviewParameters","edu.wustl.catissuecore.domain.CheckInCheckOutEventParameter","edu.wustl.catissuecore.domain.CollectionEventParameters","edu.wustl.catissuecore.domain.CollectionProtocol","edu.wustl.catissuecore.domain.CollectionProtocolEvent","edu.wustl.catissuecore.domain.CollectionProtocolRegistration","edu.wustl.catissuecore.domain.ConsentTier","edu.wustl.catissuecore.domain.ConsentTierResponse","edu.wustl.catissuecore.domain.ConsentTierStatus","edu.wustl.catissuecore.domain.Container","edu.wustl.catissuecore.domain.ContainerPosition","edu.wustl.catissuecore.domain.ContainerType","edu.wustl.catissuecore.domain.Department","edu.wustl.catissuecore.domain.DerivedSpecimenOrderItem","edu.wustl.catissuecore.domain.DisposalEventParameters","edu.wustl.catissuecore.domain.DistributedItem","edu.wustl.catissuecore.domain.Distribution","edu.wustl.catissuecore.domain.DistributionProtocol","edu.wustl.catissuecore.domain.DistributionSpecimenRequirement","edu.wustl.catissuecore.domain.EmbeddedEventParameters","edu.wustl.catissuecore.domain.ExistingSpecimenArrayOrderItem","edu.wustl.catissuecore.domain.ExistingSpecimenOrderItem","edu.wustl.catissuecore.domain.ExternalIdentifier","edu.wustl.catissuecore.domain.FixedEventParameters","edu.wustl.catissuecore.domain.FluidSpecimen","edu.wustl.catissuecore.domain.FluidSpecimenRequirement","edu.wustl.catissuecore.domain.FluidSpecimenReviewEventParameters","edu.wustl.catissuecore.domain.FrozenEventParameters","edu.wustl.catissuecore.domain.Institution","edu.wustl.catissuecore.domain.MolecularSpecimen","edu.wustl.catissuecore.domain.MolecularSpecimenRequirement","edu.wustl.catissuecore.domain.MolecularSpecimenReviewParameters","edu.wustl.catissuecore.domain.NewSpecimenArrayOrderItem","edu.wustl.catissuecore.domain.NewSpecimenOrderItem","edu.wustl.catissuecore.domain.OrderDetails","edu.wustl.catissuecore.domain.OrderItem","edu.wustl.catissuecore.domain.Participant","edu.wustl.catissuecore.domain.ParticipantMedicalIdentifier","edu.wustl.catissuecore.domain.Password","edu.wustl.catissuecore.domain.PathologicalCaseOrderItem","edu.wustl.catissuecore.domain.ProcedureEventParameters","edu.wustl.catissuecore.domain.Race","edu.wustl.catissuecore.domain.ReceivedEventParameters","edu.wustl.catissuecore.domain.Site","edu.wustl.catissuecore.domain.Specimen","edu.wustl.catissuecore.domain.SpecimenArray","edu.wustl.catissuecore.domain.SpecimenArrayContent","edu.wustl.catissuecore.domain.SpecimenArrayType","edu.wustl.catissuecore.domain.SpecimenCharacteristics","edu.wustl.catissuecore.domain.SpecimenCollectionGroup","edu.wustl.catissuecore.domain.SpecimenOrderItem","edu.wustl.catissuecore.domain.SpecimenPosition","edu.wustl.catissuecore.domain.SpecimenRequirement","edu.wustl.catissuecore.domain.SpunEventParameters","edu.wustl.catissuecore.domain.StorageContainer","edu.wustl.catissuecore.domain.StorageType","edu.wustl.catissuecore.domain.ThawEventParameters","edu.wustl.catissuecore.domain.TissueSpecimen","edu.wustl.catissuecore.domain.TissueSpecimenRequirement","edu.wustl.catissuecore.domain.TissueSpecimenReviewEventParameters","edu.wustl.catissuecore.domain.TransferEventParameters","edu.wustl.catissuecore.domain.User","edu.wustl.catissuecore.domain.pathology.BinaryContent","edu.wustl.catissuecore.domain.pathology.Concept","edu.wustl.catissuecore.domain.pathology.ConceptReferent","edu.wustl.catissuecore.domain.pathology.ConceptReferentClassification","edu.wustl.catissuecore.domain.pathology.DeidentifiedSurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.IdentifiedSurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.PathologyReportReviewParameter","edu.wustl.catissuecore.domain.pathology.QuarantineEventParameter","edu.wustl.catissuecore.domain.pathology.ReportContent","edu.wustl.catissuecore.domain.pathology.ReportSection","edu.wustl.catissuecore.domain.pathology.SemanticType","edu.wustl.catissuecore.domain.pathology.SurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.TextContent","edu.wustl.catissuecore.domain.pathology.XMLContent"};
				//String completeDomainClassName[] = new String[]{"edu.wustl.catissuecore.domain.Address","edu.wustl.catissuecore.domain.Biohazard"};
				String classToQuery=prop.getProperty("classToQuery");
				StringTokenizer strTokens= new StringTokenizer(classToQuery,",");
				/**
	//			 * Cannot query known patholgy classes 
	//			 * ReportLoaderQueue
	//			 */
				str = new StringBuffer();
				if(isOnlyCQL)
				{
					str.append("Date,Class Name,Grid URL,CQL Count,CQL execution time(ms)\n");
					while(strTokens.hasMoreTokens())
					{
						String className = strTokens.nextToken();
						testCQLWithMultipleInstance(className);
						System.out.println(str);
					}	
				}
				else
				{
					str.append("Class Name,API Count,API execution time(ms),CQL Count,CQL execution time(ms),HQL Count,HQL execution time(ms)\n");
					//for (int i = 0; i < completeDomainClassName.length; i++)
					while(strTokens.hasMoreTokens())
					{
						String className = strTokens.nextToken();
						testSearchDomain(className);
						testSearchCQL(className,gridURL,false);
						testSearchHQL(className);
						
					}
				}
				FileWriter fw = new FileWriter("result.csv");
				fw.write(str.toString());
				fw.close();
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public static void testCQLWithMultipleInstance(String className) throws Exception
	{
		String gridUrls = prop.getProperty("cagridServiceURL");
		StringTokenizer tokens = new StringTokenizer(gridUrls,",");

		while(tokens.hasMoreTokens())
		{
			String url = tokens.nextToken();
			System.out.println(url);
			str.append(new Date().toString()+","+className+","+url+",");
			try
			{
				testSearchCQL(className, url,true);
			}
			catch(Exception e)
			{
				e.printStackTrace();
				str.append("Exception"+","+""+",");
			}
			str.replace(str.length()-1, str.length(),"\n");
			
		}
	}
	
	public static void testSearchDomain(String className) throws Exception
	{
		
		Class klass = Class.forName(className);
		//System.out.println("Class: "+klass.getName());
		Object abstractDomainObject = klass.newInstance();
		if (abstractDomainObject instanceof CollectionProtocol)
		{
			CollectionProtocol cp = (CollectionProtocol) abstractDomainObject;
			cp.setConsentsWaived(null);
			
		}
		long st = System.currentTimeMillis();
		List l = appService.search(klass, abstractDomainObject);
		long et = System.currentTimeMillis();
		long timeTaken = (et-st);
		System.out.println(className);
		System.out.println("List size for API:"+l.size());
		//printResults(l);
		str.append(className+","+l.size()+","+timeTaken+",");
		//resultList.add(str);
		System.out.println("---------------------------------------");
	}
	public static void  testSearchCQL(String className,String url, boolean isMultipleInstance) throws Exception
	{
		StringBuffer cql = new StringBuffer();
		String cqlFilename = null;
//		if(!isMultipleInstance)
		{
			cql.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			cql.append("<CQLQuery xmlns=\"http://CQL.caBIG/1/gov.nih.nci.cagrid.CQLQuery\">\n");
			cql.append("<Target name="+"\""+className+"\">");
			cql.append("</Target>\n</CQLQuery>");
			
			FileWriter fw = new FileWriter("temp.cql");
			fw.write(cql.toString());
			fw.close();
			
		}
//		else if(isMultipleInstance)
//		{
//			cqlFilename = prop.getProperty("CQLFilePath"); 
//		}
		System.out.println(className);
		CQLQuery query = (CQLQuery) Utils.deserializeDocument("temp.cql",CQLQuery.class);
		CaTissueSuiteClient client = new CaTissueSuiteClient(url,proxy);
		long st = System.currentTimeMillis();
		CQLQueryResults cqlQueryResult = client.query(query);
		long et = System.currentTimeMillis();
		long timeTaken = (et-st);
		
		CQLQueryResultsIterator iter = new CQLQueryResultsIterator(cqlQueryResult, true);
		int count=0;
		while(iter.hasNext())
		{
			iter.next();
			count++;
		}
		System.out.println("List size for CQL:"+count);
		if(str!=null)
		{
			str.append(count+","+timeTaken+",");
		}
		System.out.println("---------------------------------------");


	}

	static void initGridCredentials() throws Exception
	{
		Credential credential = new Credential();
        BasicAuthenticationCredential basicCredentials = new BasicAuthenticationCredential();
       
        basicCredentials.setUserId(prop.getProperty("dorainUser"));
        basicCredentials.setPassword(prop.getProperty("dorainPassword"));
        credential.setBasicAuthenticationCredential(basicCredentials);
        ProxyLifetime lifetime = new ProxyLifetime();
        lifetime.setHours(12);
        lifetime.setMinutes(0);
        lifetime.setSeconds(0);
        int delegationLifetime = 0;

        DelegationPathLength length = new DelegationPathLength();
        length.setLength(1);
        System.out.println("authenticating.....");
        
        AuthenticationClient authClient = new AuthenticationClient(prop.getProperty("dorainServiceURL"), credential);
        //System.out.println("getting saml....");
        gov.nih.nci.cagrid.opensaml.SAMLAssertion saml = authClient.authenticate();
       
        IFSUserClient dorian = new IFSUserClient(prop.getProperty("dorainServiceURL"));
        System.out.println("creating proxy....");
        proxy = dorian.createProxy(saml, lifetime, delegationLifetime);
	}
	
	static void testSearchHQL(String className) throws Exception
	{
		StringBuffer hql = new StringBuffer();
		hql.append("select distinct(cp) from "+className+" as cp");
		boolean isactivityStatusPresent = false;
//		try
//		{
//			Method f = Class.forName(className).getMethod("getActivityStatus", null);
//		}
//		catch(NoSuchMethodException met)
//		{
//			isactivityStatusPresent=false;
//		}
		Class classObj = Class.forName(className);
		Property property;
		for (Iterator it = cfg.getClassMapping(classObj.getName()).getPropertyClosureIterator(); it
				.hasNext();)
		{
			property = (Property) it.next();
			if (property != null && property.getName().equals("activityStatus"))
			{
				isactivityStatusPresent=true;
				
			}
		}
		//System.out.println("isactivityStatusPresent: "+isactivityStatusPresent);
		if(isactivityStatusPresent)
		{
			hql.append(" where activityStatus != 'Disabled'");
		}
		//System.out.println(hql.toString());
		Query query = session.createQuery(hql.toString());
		long st = System.currentTimeMillis();
		List list = query.list();
		long et = System.currentTimeMillis();
		long timeTaken = (et-st);
		System.out.println(className);
		System.out.println("List size for HQL:"+list.size());
		str.append(list.size()+","+timeTaken+"\n");
		//printResults(list);
	}
	
	static void prepareClassTableMap()
	{
		String completeDomainClassName[] = new String[]{"edu.wustl.catissuecore.domain.Address","edu.wustl.catissuecore.domain.Biohazard","edu.wustl.catissuecore.domain.CancerResearchGroup","edu.wustl.catissuecore.domain.Capacity","edu.wustl.catissuecore.domain.CellSpecimen","edu.wustl.catissuecore.domain.CellSpecimenRequirement","edu.wustl.catissuecore.domain.CellSpecimenReviewParameters","edu.wustl.catissuecore.domain.CheckInCheckOutEventParameter","edu.wustl.catissuecore.domain.CollectionEventParameters","edu.wustl.catissuecore.domain.CollectionProtocol","edu.wustl.catissuecore.domain.CollectionProtocolEvent","edu.wustl.catissuecore.domain.CollectionProtocolRegistration","edu.wustl.catissuecore.domain.ConsentTier","edu.wustl.catissuecore.domain.ConsentTierResponse","edu.wustl.catissuecore.domain.ConsentTierStatus","edu.wustl.catissuecore.domain.Container","edu.wustl.catissuecore.domain.ContainerPosition","edu.wustl.catissuecore.domain.ContainerType","edu.wustl.catissuecore.domain.Department","edu.wustl.catissuecore.domain.DerivedSpecimenOrderItem","edu.wustl.catissuecore.domain.DisposalEventParameters","edu.wustl.catissuecore.domain.DistributedItem","edu.wustl.catissuecore.domain.Distribution","edu.wustl.catissuecore.domain.DistributionProtocol","edu.wustl.catissuecore.domain.DistributionSpecimenRequirement","edu.wustl.catissuecore.domain.EmbeddedEventParameters","edu.wustl.catissuecore.domain.ExistingSpecimenArrayOrderItem","edu.wustl.catissuecore.domain.ExistingSpecimenOrderItem","edu.wustl.catissuecore.domain.ExternalIdentifier","edu.wustl.catissuecore.domain.FixedEventParameters","edu.wustl.catissuecore.domain.FluidSpecimen","edu.wustl.catissuecore.domain.FluidSpecimenRequirement","edu.wustl.catissuecore.domain.FluidSpecimenReviewEventParameters","edu.wustl.catissuecore.domain.FrozenEventParameters","edu.wustl.catissuecore.domain.Institution","edu.wustl.catissuecore.domain.MolecularSpecimen","edu.wustl.catissuecore.domain.MolecularSpecimenRequirement","edu.wustl.catissuecore.domain.MolecularSpecimenReviewParameters","edu.wustl.catissuecore.domain.NewSpecimenArrayOrderItem","edu.wustl.catissuecore.domain.NewSpecimenOrderItem","edu.wustl.catissuecore.domain.OrderDetails","edu.wustl.catissuecore.domain.OrderItem","edu.wustl.catissuecore.domain.Participant","edu.wustl.catissuecore.domain.ParticipantMedicalIdentifier","edu.wustl.catissuecore.domain.Password","edu.wustl.catissuecore.domain.PathologicalCaseOrderItem","edu.wustl.catissuecore.domain.ProcedureEventParameters","edu.wustl.catissuecore.domain.Race","edu.wustl.catissuecore.domain.ReceivedEventParameters","edu.wustl.catissuecore.domain.Site","edu.wustl.catissuecore.domain.Specimen","edu.wustl.catissuecore.domain.SpecimenArray","edu.wustl.catissuecore.domain.SpecimenArrayContent","edu.wustl.catissuecore.domain.SpecimenArrayType","edu.wustl.catissuecore.domain.SpecimenCharacteristics","edu.wustl.catissuecore.domain.SpecimenCollectionGroup","edu.wustl.catissuecore.domain.SpecimenOrderItem","edu.wustl.catissuecore.domain.SpecimenPosition","edu.wustl.catissuecore.domain.SpecimenRequirement","edu.wustl.catissuecore.domain.SpunEventParameters","edu.wustl.catissuecore.domain.StorageContainer","edu.wustl.catissuecore.domain.StorageType","edu.wustl.catissuecore.domain.ThawEventParameters","edu.wustl.catissuecore.domain.TissueSpecimen","edu.wustl.catissuecore.domain.TissueSpecimenRequirement","edu.wustl.catissuecore.domain.TissueSpecimenReviewEventParameters","edu.wustl.catissuecore.domain.TransferEventParameters","edu.wustl.catissuecore.domain.User","edu.wustl.catissuecore.domain.pathology.BinaryContent","edu.wustl.catissuecore.domain.pathology.Concept","edu.wustl.catissuecore.domain.pathology.ConceptReferent","edu.wustl.catissuecore.domain.pathology.ConceptReferentClassification","edu.wustl.catissuecore.domain.pathology.DeidentifiedSurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.IdentifiedSurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.PathologyReportReviewParameter","edu.wustl.catissuecore.domain.pathology.QuarantineEventParameter","edu.wustl.catissuecore.domain.pathology.ReportContent","edu.wustl.catissuecore.domain.pathology.ReportSection","edu.wustl.catissuecore.domain.pathology.SemanticType","edu.wustl.catissuecore.domain.pathology.SurgicalPathologyReport","edu.wustl.catissuecore.domain.pathology.TextContent","edu.wustl.catissuecore.domain.pathology.XMLContent"};
		String completeTableName[] = new String[]{"CATISSUE_ADDRESS","CATISSUE_BIOHAZARD","CATISSUE_CANCER_RESEARCH_GROUP","CATISSUE_CAPACITY","catissue_cell_specimen","catissue_cell_req_specimen","CATISSUE_CELL_SPE_REVIEW_PARAM","CATISSUE_IN_OUT_EVENT_PARAM","CATISSUE_COLL_EVENT_PARAM","CATISSUE_COLLECTION_PROTOCOL","CATISSUE_COLL_PROT_EVENT","CATISSUE_COLL_PROT_REG","CATISSUE_CONSENT_TIER","CATISSUE_CONSENT_TIER_RESPONSE","CATISSUE_CONSENT_TIER_STATUS","CATISSUE_CONTAINER","CATISSUE_CONTAINER_POSITION","CATISSUE_CONTAINER_TYPE","CATISSUE_DEPARTMENT","CATISSUE_DERIEVED_SP_ORD_ITEM","CATISSUE_DISPOSAL_EVENT_PARAM","CATISSUE_DISTRIBUTED_ITEM","CATISSUE_DISTRIBUTION","CATISSUE_DISTRIBUTION_PROTOCOL","CATISSUE_DISTRIBUTION_SPEC_REQ","CATISSUE_EMBEDDED_EVENT_PARAM","CATISSUE_EXIST_SP_AR_ORD_ITEM","CATISSUE_EXISTING_SP_ORD_ITEM","CATISSUE_EXTERNAL_IDENTIFIER","CATISSUE_FIXED_EVENT_PARAM","catissue_fluid_specimen","catissue_fluid_req_specimen","CATISSUE_FLUID_SPE_EVENT_PARAM","CATISSUE_FROZEN_EVENT_PARAM","CATISSUE_INSTITUTION","catissue_molecular_specimen","catissue_mol_req_specimen","CATISSUE_MOL_SPE_REVIEW_PARAM","CATISSUE_NEW_SP_AR_ORDER_ITEM","CATISSUE_NEW_SPEC_ORD_ITEM","CATISSUE_ORDER","CATISSUE_ORDER_ITEM","CATISSUE_PARTICIPANT","CATISSUE_PART_MEDICAL_ID","CATISSUE_PASSWORD","CATISSUE_PATH_CASE_ORDER_ITEM","CATISSUE_PROCEDURE_EVENT_PARAM","CATISSUE_RACE","CATISSUE_RECEIVED_EVENT_PARAM","CATISSUE_SITE","CATISSUE_SPECIMEN","CATISSUE_SPECIMEN_ARRAY","CATISSUE_SPECI_ARRAY_CONTENT","CATISSUE_SPECIMEN_ARRAY_TYPE","CATISSUE_SPECIMEN_CHAR","CATISSUE_SPECIMEN_COLL_GROUP","CATISSUE_SPECIMEN_ORDER_ITEM","CATISSUE_SPECIMEN_POSITION","CATISSUE_CP_REQ_SPECIMEN","CATISSUE_SPUN_EVENT_PARAMETERS","CATISSUE_STORAGE_CONTAINER","CATISSUE_STORAGE_TYPE","CATISSUE_THAW_EVENT_PARAMETERS","catissue_tissue_specimen","catissue_tissue_req_specimen","CATISSUE_TIS_SPE_EVENT_PARAM","CATISSUE_TRANSFER_EVENT_PARAM","CATISSUE_USER","CATISSUE_REPORT_BICONTENT","CATISSUE_CONCEPT","CATISSUE_CONCEPT_REFERENT","CATISSUE_CONCEPT_CLASSIFICATN","CATISSUE_DEIDENTIFIED_REPORT","CATISSUE_IDENTIFIED_REPORT","CATISSUE_REVIEW_PARAMS","CATISSUE_QUARANTINE_PARAMS","CATISSUE_REPORT_CONTENT","CATISSUE_REPORT_SECTION","CATISSUE_SEMANTIC_TYPE","CATISSUE_PATHOLOGY_REPORT","CATISSUE_REPORT_TEXTCONTENT","CATISSUE_REPORT_XMLCONTENT"};
		for(int i=0;i<completeDomainClassName.length;i++)
		{
			classAndTableName.put(completeDomainClassName[i],completeTableName[i]);
		}
	}
	
//	static void printResults(List l)
//	{
//		System.out.println("------------------------------------");
//		for(int i=0;i<l.size();i++)
//		{
//			Participant cp = (Participant)l.get(i);
//			System.out.println(cp.getId()+","+cp.getId()+","+cp.getActivityStatus());
//		}
//	}
}
