#script to update date in CSM_User table

REMARK "Upading date in CSM_USER
update csm_user set update_date=CURRENT_DATE where login_name='clin_portal@persistent.co.in';

REMARK "Upading date in CATISSUE_PASSWORD
update catissue_password set update_date=CURRENT_DATE where user_id=(select user_id from csm_user where login_name='clin_portal@persistent.co.in');

quit;