/*L
 *  Copyright Washington University in St. Louis
 *  Copyright SemanticBits
 *  Copyright Persistent Systems
 *  Copyright Krishagni
 *
 *  Distributed under the OSI-approved BSD 3-Clause License.
 *  See http://ncip.github.com/catissue-test/LICENSE.txt for details.
 */


import java.net.URI;

import gov.nih.nci.cagrid.authentication.bean.BasicAuthenticationCredential;
import gov.nih.nci.cagrid.authentication.bean.Credential;
import gov.nih.nci.cagrid.authentication.client.AuthenticationClient;
import gov.nih.nci.cagrid.discovery.client.DiscoveryClient;
import gov.nih.nci.cagrid.dorian.client.IFSUserClient;
import gov.nih.nci.cagrid.dorian.ifs.bean.DelegationPathLength;
import gov.nih.nci.cagrid.dorian.ifs.bean.ProxyLifetime;
import gov.nih.nci.cagrid.metadata.MetadataUtils;
import gov.nih.nci.cagrid.metadata.ServiceMetadata;

import org.apache.axis.message.addressing.EndpointReferenceType;


public class DiscoveryExamples {

    @SuppressWarnings("null")
    public static void main(String[] args) {
        DiscoveryClient client = null;
        try {
        	

            if (args.length == 1) 
            {
                client = new DiscoveryClient(args[1]);
            } 
            else 
            {
                //client = new DiscoveryClient("http://index.training.cagrid.org:8080/wsrf/services/DefaultIndexService");
            	client = new DiscoveryClient("http://cagrid-index.nci.nih.gov:8080/wsrf/services/DefaultIndexService");
                
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }

        try {
            EndpointReferenceType[] services = null;
//            services = client.discoverServicesByName("CaTissueSuite");//client.getAllServices(false);
//            for(int i=0;i<services.length;i++)
//            {
//            	EndpointReferenceType e = services[i];
//            	System.out.println("Add "+e.getAddress());
//            	ServiceMetadata metadata = MetadataUtils.getServiceMetadata(e);
//            	System.out.println(metadata.getHostingResearchCenter().getResearchCenter().getDisplayName()); 
//            	//DomainModel model = MetadataUtils.getDomainModel(epr); System.out.println(model.getProjectShortName());
//            }
        	EndpointReferenceType e = new EndpointReferenceType (new org.apache.axis.types.URI("https://catissueshare.wustl.edu:28443/wsrf/services/cagrid/CaTissueSuite"));
        	System.out.println("Add "+e.getAddress());
        	ServiceMetadata metadata = MetadataUtils.getServiceMetadata(e);
        	System.out.println(metadata.getHostingResearchCenter().getResearchCenter().getDisplayName()); 
        
             
           
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
  
}

