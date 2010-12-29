REMARK SQL script to Drop and Creat database user for catissue_bo.

REMARK Drop catissue_bo User
DROP USER catissue_bo CASCADE;

REMARK Creat User "catissue_bo"
CREATE USER catissue_bo IDENTIFIED BY catissue_bo default TABLESPACE catissue;

GRANT CONNECT,RESOURCE TO catissue_bo;

GRANT DBA TO catissue_bo;

quit;
