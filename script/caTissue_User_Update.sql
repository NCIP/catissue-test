update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin@admin.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin@wustl.edu';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='supervisor@wustl.edu';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='tech@wustl.edu';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='scientist@wustl.edu';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin@washu.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user2@storageAdmin.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user3@specimenProcessing.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user6@registration.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user7@distribution.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user1@userProvisioning.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='user3@specimenProcessing.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='scientist@washu.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='technician@washu.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='supervisor@washu.com';

#CSM_User table updating to avoid password expiry feature

REMARK "Upading date in CSM_USER
update csm_user set update_date=CURRENT_DATE where login_name='admin@admin.com';
update csm_user set update_date=CURRENT_DATE where login_name='admin@wustl.edu';
update csm_user set update_date=CURRENT_DATE where login_name='supervisor@wustl.edu';
update csm_user set update_date=CURRENT_DATE where login_name='tech@wustl.edu';
update csm_user set update_date=CURRENT_DATE where login_name='scientist@wustl.edu';
update csm_user set update_date=CURRENT_DATE where login_name='admin@washu.com';
update csm_user set update_date=CURRENT_DATE where login_name='user2@storageAdmin.com';
update csm_user set update_date=CURRENT_DATE where login_name='user3@specimenProcessing.com';
update csm_user set update_date=CURRENT_DATE where login_name='user6@registration.com';
update csm_user set update_date=CURRENT_DATE where login_name='user7@distribution.com';
update csm_user set update_date=CURRENT_DATE where login_name='user1@userProvisioning.com';
update csm_user set update_date=CURRENT_DATE where login_name='user3@specimenProcessing.com';
update csm_user set update_date=CURRENT_DATE where login_name='scientist@washu.com';
update csm_user set update_date=CURRENT_DATE where login_name='technician@washu.com';
update csm_user set update_date=CURRENT_DATE where login_name='supervisor@washu.com';


REMARK "Upading date in CATISSUE_PASSWORD
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin@admin.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin@wustl.edu');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='supervisor@wustl.edu');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='tech@wustl.edu');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='scientist@wustl.edu');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin@washu.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user2@storageAdmin.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user3@specimenProcessing.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user6@registration.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user7@distribution.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user1@userProvisioning.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='user3@specimenProcessing.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='scientist@washu.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='technician@washu.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='supervisor@washu.com');

commit;
quit;