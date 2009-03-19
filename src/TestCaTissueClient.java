import edu.wustl.catissuecore.client.CaTissueSuiteClient;
import edu.wustl.catissuecore.domain.CollectionProtocol;
import edu.wustl.catissuecore.domain.CollectionProtocolRegistration;
import edu.wustl.catissuecore.domain.FluidSpecimen;
import edu.wustl.catissuecore.domain.MolecularSpecimen;
import edu.wustl.catissuecore.domain.SpecimenCollectionGroup;
import edu.wustl.catissuecore.domain.User;
import gov.nih.nci.cagrid.authentication.bean.BasicAuthenticationCredential;
import gov.nih.nci.cagrid.authentication.bean.Credential;
import gov.nih.nci.cagrid.authentication.client.AuthenticationClient;
import gov.nih.nci.cagrid.common.Utils;
import gov.nih.nci.cagrid.cqlquery.Association;
import gov.nih.nci.cagrid.cqlquery.Attribute;
import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlquery.Group;
import gov.nih.nci.cagrid.cqlquery.LogicalOperator;
import gov.nih.nci.cagrid.cqlquery.Predicate;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.utilities.CQLQueryResultsIterator;
import gov.nih.nci.cagrid.dorian.client.IFSUserClient;
import gov.nih.nci.cagrid.dorian.ifs.bean.DelegationPathLength;
import gov.nih.nci.cagrid.dorian.ifs.bean.ProxyLifetime;
import gov.nih.nci.cagrid.metadata.MetadataUtils;
import gov.nih.nci.cagrid.metadata.ServiceMetadata;
import gov.nih.nci.common.util.XMLUtility;
import gov.nih.nci.system.applicationservice.ApplicationService;
import gov.nih.nci.system.applicationservice.ApplicationServiceProvider;
import gov.nih.nci.system.comm.client.ClientSession;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.StringTokenizer;

import javax.xml.namespace.QName;

import org.apache.axis.message.addressing.EndpointReferenceType;
import org.apache.log4j.PropertyConfigurator;
import org.globus.gsi.GlobusCredential;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.mapping.Property;


public class TestCaTissueClient
{
	static String gridURL;
	static Properties prop = new Properties();
	static GlobusCredential proxy;
	static CaTissueSuiteClient client;
	static StringBuffer str = null;
	static List<Map>resultList = new ArrayList<Map>();
	final  static String HEADER_CP_NAME="HEADER_CP_NAME";
	final  static String HEADER_PI_NAME="HEADER_PI_NAME";
	final  static String HEADER_PART_REG="HEADER_PART_REG";
	final  static String HEADER_WHOLE_BLOOD="HEADER_WHOLE_BLOOD";
	final  static String HEADER_PLASMA="HEADER_PLASMA";
	final  static String HEADER_SERUM="HEADER_SERUM";
	final  static String HEADER_OTHER_FLUID="HEADER_OTHER_FLUID";
	final  static String HEADER_DNA="HEADER_DNA";
	final  static String HEADER_RNA="HEADER_RNA";
	final  static String HEADER_OTHER_MOLECULAR="HEADER_OTHER_MOLECULAR";
	final  static String HEADER_CELL="HEADER_CELL";
		
	
	
	public static void init(String fileName,boolean onlyCQL) throws Exception
	{
		
		
	}
	public static void main(String[] args)
	{
		try
		{
			
			prop.load(new FileInputStream(args[0]));
			
			initGridCredentials();
			
			String gridUrls = prop.getProperty("cagridServiceURL");
			
			StringTokenizer tokens = new StringTokenizer(gridUrls,",");
			FileWriter resultfile = new FileWriter("CP_results.csv");
			while(tokens.hasMoreTokens())
			{
				String url = tokens.nextToken();
				System.out.println(url);
				String centerName = getCenterName(url);
				client = new CaTissueSuiteClient(url,proxy);
				
				List<CollectionProtocol> cpList = new CollectionProtocolQuery().getCollectionProtocolList(client);
/*				List<CollectionProtocol> cpList = new ArrayList<CollectionProtocol>();
				CollectionProtocol c = new CollectionProtocol();
				c.setId(2L);
				c.setTitle("SAChin");
				cpList.add(c);
*/
				for(int i=0;i<9;i++)
				{
					if(i>=8)
						break;
					CollectionProtocol cp = cpList.get(i);
					
					Map<String,String>resultmap = new Hashtable<String, String>();
					resultmap.put(HEADER_CP_NAME, cp.getTitle());
					System.out.println(cp.getTitle()+"  ");

					List<CollectionProtocolRegistration>  cprList = new CollectionProtocolRegistrationQuery().getRegisteredParticipantCount(client,cp.getId().toString());//cp.getId().toString())
					resultmap.put(HEADER_PART_REG, ""+cprList.size());
					//System.out.print(cprList.size()+"  ");
					resultmap.put(HEADER_WHOLE_BLOOD, "0");
					resultmap.put(HEADER_PLASMA, "0");
					resultmap.put(HEADER_SERUM, "0");
					resultmap.put(HEADER_OTHER_FLUID, "0");
					resultmap.put(HEADER_RNA, "0");
					resultmap.put(HEADER_DNA, "0");
					resultmap.put(HEADER_OTHER_MOLECULAR, "0");
					resultmap.put(HEADER_CELL, "0");
					

					for(int j=0;j<cprList.size();j++)
					{
						CollectionProtocolRegistration cpr =  cprList.get(j);
						runFluidAndMolecularQuery(resultmap, cpr.getId().toString());
					}
					resultList.add(resultmap);
				}
				
				resultfile.write("Center name,CP title,# Participants registered,Whole Blood Samples collected,Serum Samples collected,Plasma Samples collected,Other Fluid Samples collected,DNA Samples collected,RNA Samples collected,Other Molecular Samples collected,Cell Samples collected\n");
				StringBuffer str = new StringBuffer();
				for(int i=0;i<resultList.size();i++)
				{
					Map<String,String> map = resultList.get(i);
					resultfile.write(centerName+",");	
					resultfile.write(map.get(HEADER_CP_NAME)+",");
					resultfile.write(map.get(HEADER_PART_REG)+",");
					resultfile.write(map.get(HEADER_WHOLE_BLOOD)+",");
					resultfile.write(map.get(HEADER_SERUM)+",");
					resultfile.write(map.get(HEADER_OTHER_FLUID)+",");
					resultfile.write(map.get(HEADER_DNA)+",");
					resultfile.write(map.get(HEADER_RNA)+",");
					resultfile.write(map.get(HEADER_OTHER_MOLECULAR)+",");
					resultfile.write(map.get(HEADER_CELL)+"\n");
				}
				resultfile.close();
				System.out.println("Please see 'CP_results.csv' file for results");
			}
			
			
			
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public static void runFluidAndMolecularQuery(Map<String,String> resultmap, String cprID) throws Exception
	{
		FluidSpecimenQuery fluidSpecimenQuery = new FluidSpecimenQuery();
		MolecularSpecimenQuery molecularSpecimenQuery = new MolecularSpecimenQuery();
		
		// Whole blood fluid
		int wholeBloodSpecimenList = fluidSpecimenQuery.getFluidSpecimen(client,cprID,new String[]{"Whole Blood"});
		
		wholeBloodSpecimenList += Integer.valueOf(resultmap.get(HEADER_WHOLE_BLOOD)).intValue();
		resultmap.put(HEADER_WHOLE_BLOOD, ""+wholeBloodSpecimenList);
		
		// plsama fluid
		int plasmaSpecimenList = fluidSpecimenQuery.getFluidSpecimen(client,cprID,new String[]{"Plasma"});
		plasmaSpecimenList += Integer.valueOf(resultmap.get(HEADER_PLASMA)).intValue();
		resultmap.put(HEADER_PLASMA, ""+plasmaSpecimenList);
		
		// Serum fluid
		int serumSpecimenList = fluidSpecimenQuery.getFluidSpecimen(client,cprID.toString(),new String[]{"Serum"});
		serumSpecimenList += Integer.valueOf(resultmap.get(HEADER_SERUM)).intValue();
		resultmap.put(HEADER_SERUM, ""+serumSpecimenList);
		
		// other fluid
		int otherFluidSpecimenList = fluidSpecimenQuery.getFluidSpecimen(client,cprID.toString(),new String[]{"Amniotic Fluid","Bile","Body Cavity Fluid","Bone Marrow Plasma","Cerebrospinal Fluid","Feces","Gastric Fluid","Lavage","Milk","Not Specified",
							"Pericardial Fluid","Saliva","Sputum","Sweat","Synovial Fluid","Urine","Vitreous Fluid","Whole Bone Marrow"});
		otherFluidSpecimenList += Integer.valueOf(resultmap.get(HEADER_OTHER_FLUID)).intValue();
		resultmap.put(HEADER_OTHER_FLUID, ""+otherFluidSpecimenList);
		
		// RNA molecular 
		int rnaSpecimenList = molecularSpecimenQuery.getMolecularSpecimen(client,cprID,new String[]{"RNA"});
		rnaSpecimenList += Integer.valueOf(resultmap.get(HEADER_RNA)).intValue();
		resultmap.put(HEADER_RNA, ""+rnaSpecimenList);

		// DNA molecular		
		int dnaSpecimenList = molecularSpecimenQuery.getMolecularSpecimen(client,cprID,new String[]{"DNA"});
		dnaSpecimenList += Integer.valueOf(resultmap.get(HEADER_DNA)).intValue();
		resultmap.put(HEADER_DNA, ""+dnaSpecimenList);

		//Other molecular
		int otherMolecularSpecimenList = molecularSpecimenQuery.getMolecularSpecimen(client,cprID,new String[]{"Not Specified","RNA, cytoplasmic","RNA, nuclear","RNA, poly-A enriched","Total Nucleic Acid","Whole Genome Amplified DNA","cDNA"});
		otherMolecularSpecimenList += Integer.valueOf(resultmap.get(HEADER_OTHER_MOLECULAR)).intValue();
		resultmap.put(HEADER_OTHER_MOLECULAR, ""+otherMolecularSpecimenList);

	}
	
	public static String getCenterName(String url) throws Exception
	{
		EndpointReferenceType e = new EndpointReferenceType (new org.apache.axis.types.URI(url));
    	System.out.println("Add "+e.getAddress());
    	ServiceMetadata metadata = MetadataUtils.getServiceMetadata(e);
    	String centerName = metadata.getHostingResearchCenter().getResearchCenter().getDisplayName();
    	System.out.println("centerName: "+centerName);
    	return centerName;
	}
	
	
	public static User getPIofCollectionProtocol(String collectionProtocolid) throws Exception
	{
		CQLQuery piQuery = new CQLQuery();
		gov.nih.nci.cagrid.cqlquery.Object piTarget = new gov.nih.nci.cagrid.cqlquery.Object();
		piTarget.setName("edu.wustl.catissuecore.domain.User");
		Association piAssociation = new Association();
		piAssociation.setRoleName("collectionProtocolCollection");
		piAssociation.setName("edu.wustl.catissuecore.domain.CollectionProtocol");
		Attribute cpIdentifier = new Attribute();
		cpIdentifier.setPredicate(Predicate.EQUAL_TO);
		cpIdentifier.setName("id");
		cpIdentifier.setValue(collectionProtocolid);
		piAssociation.setAttribute(cpIdentifier);
		piTarget.setAssociation(piAssociation);
		piQuery.setTarget(piTarget);
		CQLQueryResults piCqlQueryResult = client.query(piQuery);
		CQLQueryResultsIterator piiter = new CQLQueryResultsIterator(piCqlQueryResult, true);
		
		FileWriter fw = new FileWriter("temp.xml");
		fw.write((String)piiter.next());
		fw.close();
		User piUser = (User )XMLUtility.fromXML(new File("temp.xml"));
		
		System.out.println(piUser.getFirstName()+" "+piUser.getLastName());
		return piUser;
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
	
}
