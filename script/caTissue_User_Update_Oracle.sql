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
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin1@admin.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='super@super.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='tech@bjc.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='scientist@sci.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='custom@user.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin1@washu.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='admin_ltp@gmail.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='superv_pra@superv.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='sci_pra@sci.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='tech_pra@tech.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='sup_ltp@gmail.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='tech_ltp@gmail.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='scientist@sci.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='dmp@dmp.com';
update CATISSUE_USER set FIRST_TIME_LOGIN=0 where EMAIL_ADDRESS='techWU@wustl.edu';
#CSM_User table updating to avoid password expiry feature


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
update csm_user set update_date=CURRENT_DATE where login_name='admin1@admin.com';
update csm_user set update_date=CURRENT_DATE where login_name='super@super.com';
update csm_user set update_date=CURRENT_DATE where login_name='tech@bjc.com';
update csm_user set update_date=CURRENT_DATE where login_name='scientist@sci.com';
update csm_user set update_date=CURRENT_DATE where login_name='custom@user.com';
update csm_user set update_date=CURRENT_DATE where login_name='admin1@washu.com';
update csm_user set update_date=CURRENT_DATE where login_name='admin_ltp@gmail.com';
update csm_user set update_date=CURRENT_DATE where login_name='superv_pra@superv.com';
update csm_user set update_date=CURRENT_DATE where login_name='sci_pra@sci.com';
update csm_user set update_date=CURRENT_DATE where login_name='tech_pra@tech.com';
update csm_user set update_date=CURRENT_DATE where login_name='sup_ltp@gmail.com';
update csm_user set update_date=CURRENT_DATE where login_name='tech_ltp@gmail.com';
update csm_user set update_date=CURRENT_DATE where login_name='scientist@sci.com';
update csm_user set update_date=CURRENT_DATE where login_name='dmp@dmp.com';
update csm_user set update_date=CURRENT_DATE where login_name='techWU@wustl.edu';

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
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin1@admin.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='super@super.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='tech@bjc.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='scientist@sci.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='custom@user.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin1@washu.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='admin_ltp@gmail.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='superv_pra@superv.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='sci_pra@sci.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='tech_pra@tech.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='sup_ltp@gmail.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='tech_ltp@gmail.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='scientist@sci.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='dmp@dmp.com');
update catissue_password set update_date=CURRENT_DATE where user_id=(select IDENTIFIER from CATISSUE_USER where login_name='techWU@wustl.edu');
update catissue_user set activity_status='Active' where identifier=1;

commit;
quit;