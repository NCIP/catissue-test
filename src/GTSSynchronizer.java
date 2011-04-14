/**
 *
 */

import gov.nih.nci.cagrid.syncgts.bean.SyncDescription;
import gov.nih.nci.cagrid.syncgts.core.SyncGTS;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.axis.utils.XMLUtils;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.globus.wsrf.encoding.ObjectDeserializer;
import org.w3c.dom.Document;

/**
 * @author chetan_patil
 * 
 */
public class GTSSynchronizer {
	private static final Logger logger = Logger
			.getLogger(GTSSynchronizer.class);

	/**
	 * This method generates the globus certificate in user.home folder
	 * 
	 * @param gridType
	 */
	public static void generateGlobusCertificate() {
		System.out.println("\n In generateGlobusCertificate");
		try {

			
			String home = "D:/Selenium_framework/caGrid_Automation/src";
			String signingPolicy = CagridPropertyLoader.getSigningPolicy();
				//"production/62f4fd66.signing_policy";
			String certificate = CagridPropertyLoader.getCertificate();
				//"production/62f4fd66.0";
			String syncDescriptionFile = CagridPropertyLoader.getSyncDesFile(); 
				//"production/sync-description.xml";

			URL signingPolicyURL = null;
			URL certificateURL = null;
			URL syncDescriptionURL = null;
			System.out.println("\n Before -----"+home + "/conf");
			System.out.println("\n Before ---signingPolicy--"+signingPolicy);
			File file = new File(home + "/conf", signingPolicy);
			
			if (file.exists()) {
				signingPolicyURL = file.toURI().toURL();
			}
			System.out.println("\n Before -----"+home + "/conf");
			System.out.println("\n Before ---signingPolicy--"+certificate);
			file = new File(home + "/conf", certificate);
			if (file.exists()) {
				certificateURL = file.toURI().toURL();
			}

			if (signingPolicy != null || certificate != null) {
				
				System.out.println("\n In copy If");
				copyCACertificates(signingPolicyURL);
				copyCACertificates(certificateURL);
			} else {
				logger.error("Could not find CA certificates");
			}
			System.out.println("\n Before Sync");
			logger.debug("Getting sync-descriptor.xml file");
			// try {
			logger.debug("Synchronizing with GTS service");
			file = new File(home + "/conf", syncDescriptionFile);
			if (file.exists()) {
				syncDescriptionURL = file.toURI().toURL();
			}
			System.out.println("\n Before -----1 Sync");
			Document doc = XMLUtils
					.newDocument(syncDescriptionURL.openStream());
			System.out.println("\n Before ----- 2 Sync");
			Object obj = ObjectDeserializer.toObject(doc.getDocumentElement(),
					SyncDescription.class);
			System.out.println("\n Before ----- 3 Sync");
			SyncDescription description = (SyncDescription) obj;
			System.out.println("\n Before ----- 4 Sync"); 
			//SyncGTS.getInstance().syncOnce(description);
			System.out.println("\n Before ----- Sync");
			logger
					.debug("Successfully syncronized with GTS service. Globus certificates generated.");
		} catch (Exception e) {
			logger.error(e.getMessage(), e);

		}
	}

	private static void copyCACertificates(URL inFileURL) {
		int index = inFileURL.getPath().lastIndexOf('/');
		if (index > -1) {
			String fileName = inFileURL.getPath().substring(index + 1).trim();
			StringBuffer destinationFilePath = new StringBuffer(System
					.getenv("USERPROFILE"));
			destinationFilePath.append(File.separator).append(".globus")
					.append(File.separator).append("certificates").append(
							File.separator);
			File destination = new File(destinationFilePath + File.separator
					+ fileName);
			try {
				FileUtils.copyURLToFile(inFileURL, destination);
			} catch (IOException e) {
				logger.error(e.getMessage(), e);
			}
		}
	}
}
