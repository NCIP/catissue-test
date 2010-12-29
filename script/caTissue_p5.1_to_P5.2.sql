alter table CATISSUE_SPECIMEN_PROTOCOL drop column LABEL_FORMAT ;
alter table CATISSUE_SPECIMEN_PROTOCOL drop column DERIV_LABEL_FORMAT ;
alter table CATISSUE_SPECIMEN_PROTOCOL drop column ALIQUOT_LABEL_FORMAT ;
drop table KEY_SEQ_GENERATOR;
drop sequence KEY_GENERATOR_SEQ;
commit;
quit;
