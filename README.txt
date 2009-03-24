-------------------------------------------------------------------------------
CATISSUE SUITE v1.1 API TEST CASE CLIENT BY COLLECTION PROTOCOL BASIS
-------------------------------------------------------------------------------
This utility executes the query to get the result form each configurd instance in following CSV format  
Center name,CP title, # Participants registered, Whole Blood Samples collected, Serum Samples collected, Plasma Samples collected, Other Fluid Samples collected, DNA Samples collected, RNA Samples collected, Other Molecular Samples collected., Cell Samples collected

Steps to eecute query 
1. configured cagridServiceURL,dorainServiceURL,dorainUser,dorainPassword
2. Execute command 'ant runCQL' from command prompt 
-------------------------------------------------------------------------------
CATISSUE SUITE v1.1 API TEST CASE CLIENT
-------------------------------------------------------------------------------
This utility test case produces stats on a pre-defined set of caTissue Suite 1.1 grid instances, 
in terms of object counts and time elapsed for each query. The client can also be configured and used to execute 
the same query through different API i.e caGrid, caCORE and hibernate

1.	Allow a configurable set of the Suite 1.1 instance to be monitored

2.	For each configured Suite 1.1, the utility will query every object in the instance and retrieve a count, and for each query,  
    record a success for failure of the operation, and if successful, record the number of count and time elapsed for the whole 
    operation; if fail, record an exception type.  Failure to retrieve a particular object should not stop the application
    
3.	If a particular grid node is not responding, errors get noted and that node is skipped, without stopping the 
    whole application.

4.	the results in Following  format is stored in CSV file created in base directory,
	"Query class name, caTissue Grid URL, Result Count, Execution Time"
	For exception grid nodes the result count coulmn contains error message    

Following is the the steps to run this test program

1. Modify the client.properties file. To give the appropriate credential and location

	classToQuery : Comma separated fully qualified caTissue's domain class names. e.g. edu.wustl.catissuecore.domain.Department,edu.wustl.catissuecore.domain.Participant
	
	runCQLOnMultipleInstance: "true" if to used client for executing query on multiple grid instance. "false" value to execute client 
	with different caTisue API
	
	cagridServiceURL: The grid service URL, multiple urls can be configured as comma separated value if runCQLOnMultipleInstance=true
	e.g. https://catissueshare.wustl.edu:28443/wsrf/services/cagrid/CaTissueSuite,https://cagrid.bmif.upenn.edu:8443/wsrf/services/cagrid/CaTissueSuite 
	
	dorainServiceURL: URL of dorain service. Default set as production dorain url
	
	dorainUser: Dorian Username required to authenticate through grid service
	  
	dorainPassword: Dorian password required to authenticate through grid service
	
	cacoreServiceURL: caTisue caCORE instance URL http://catissue.wustl.edu:8080/catissuecore/http/remoteService
	
	cacoreUser: caTissue username required to login through caCORE API
	 
	cacorePassword: caTissue password required to login through caCORE API
	
	database.type: database type
	
	database.host: database host
	
	database.port: database port
	
	database.name: database name
	
	database.username: database user name
	
	database.password: database password
	
2. This is steps is not required if client is configured to execute multiple grid instance query.
   Modify the conf/remoteSErvice.xml to point to correct caTissue caCORE instance. 
   The default URL  is WASHU demo site instance
   
3. Execute command 'ant runQuery' from command prompt 

4. The output will create result.csv file in base folder.