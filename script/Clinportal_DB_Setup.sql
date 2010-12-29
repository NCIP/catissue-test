REMARK SQL script to Drop and Creat database user for clinprotal Bulk Operation.

REMARK Drop ClinPortal_bo User
DROP USER clinportal_bo CASCADE;

REMARK Creat User "clinportal_bo"
CREATE USER clinportal_bo IDENTIFIED BY clinportal_bo default TABLESPACE clinportal_bo;

REMARK Grant Privileges to ClinPortal_bo User
GRANT CONNECT,RESOURCE TO clinportal_bo;

REMARK DBA access to "clinportal_bo" user
GRANT DBA TO clinportal_bo;

REMARK Drop caTissue_bo User
DROP USER catissue_bo CASCADE;

REMARK Creat User "caTissue_bo"
CREATE USER catissue_bo IDENTIFIED BY catissue_bo default TABLESPACE aq;

REMARK Grant Privileges to caTissue_bo User
GRANT CONNECT,RESOURCE TO catissue_bo;

REMARK DBA access to "caTissue_bo" user
GRANT DBA TO catissue_bo;

REMARK Drop Idp_bo User
DROP USER idp_bo CASCADE;

REMARK Creat User "Idp_bo"
CREATE USER idp_bo IDENTIFIED BY idp_bo default TABLESPACE idp;

REMARK Grant Privileges to Idp_bo User
GRANT CONNECT,RESOURCE TO idp_bo;

REMARK DBA access to "Idp_bo" user
GRANT DBA TO idp_bo;

quit;