/*L
 *  Copyright Washington University in St. Louis
 *  Copyright SemanticBits
 *  Copyright Persistent Systems
 *  Copyright Krishagni
 *
 *  Distributed under the OSI-approved BSD 3-Clause License.
 *  See http://ncip.github.com/catissue-test/LICENSE.txt for details.
 */

package edu.wustl.catissuecore.common;

import javax.xml.namespace.QName;


public interface CaTissueSuiteConstants {
	public static final String SERVICE_NS = "http://catissuecore.wustl.edu/CaTissueSuite";
	public static final QName RESOURCE_KEY = new QName(SERVICE_NS, "CaTissueSuiteKey");
	public static final QName RESOURCE_PROPERTY_SET = new QName(SERVICE_NS, "CaTissueSuiteResourceProperties");

	//Service level metadata (exposed as resouce properties)
	public static final QName DOMAINMODEL = new QName("gme://caGrid.caBIG/1.0/gov.nih.nci.cagrid.metadata.dataservice", "DomainModel");
	public static final QName SERVICEMETADATA = new QName("gme://caGrid.caBIG/1.0/gov.nih.nci.cagrid.metadata", "ServiceMetadata");
	
}
