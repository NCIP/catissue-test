/*L
 *  Copyright Washington University in St. Louis
 *  Copyright SemanticBits
 *  Copyright Persistent Systems
 *  Copyright Krishagni
 *
 *  Distributed under the OSI-approved BSD 3-Clause License.
 *  See http://ncip.github.com/catissue-test/LICENSE.txt for details.
 */

package edu.wustl.catissuecore.service.globus;

import edu.wustl.catissuecore.service.CaTissueSuiteImpl;

import java.rmi.RemoteException;

/** 
 * DO NOT EDIT:  This class is autogenerated!
 *
 * This class implements each method in the portType of the service.  Each method call represented
 * in the port type will be then mapped into the unwrapped implementation which the user provides
 * in the CaTissueSuiteImpl class.  This class handles the boxing and unboxing of each method call
 * so that it can be correclty mapped in the unboxed interface that the developer has designed and 
 * has implemented.  Authorization callbacks are automatically made for each method based
 * on each methods authorization requirements.
 * 
 * @created by Introduce Toolkit version 1.2
 * 
 */
public class CaTissueSuiteProviderImpl{
	
	CaTissueSuiteImpl impl;
	
	public CaTissueSuiteProviderImpl() throws RemoteException {
		impl = new CaTissueSuiteImpl();
	}
	

}
