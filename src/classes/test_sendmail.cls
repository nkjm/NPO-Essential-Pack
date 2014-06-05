@isTest(seeAllData=true)
public with sharing class test_sendmail {
	public static list<contributor__c> create_destinations(){
		list<contributor__c> conts = new list<contributor__c>();
		id recordTypeId = [select id from recordType where developerName = 'regular' and SObjectType = 'contributor__c' and IsActive = true].id;
		conts.add(new contributor__c(Name = 'User A', email__c = 'usera@hoge.com', RecordTypeId = recordTypeId));
		conts.add(new contributor__c(Name = 'User B', email__c = 'userb@hoge.com', RecordTypeId = recordTypeId));
		conts.add(new contributor__c(Name = 'User C', RecordTypeId = recordTypeId));
		conts.add(new contributor__c(Name = 'User D', RecordTypeId = recordTypeId));
		insert conts;
		return conts;
	}

	public testmethod static void test_getDestinations(){
		list<contributor__c> conts = create_destinations();
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(conts);

		// selected_contributors will be 3. (emulate checking User A, B, C.)
		// destinations will be 2. (User C does not have email so will be excluded.)
		conts.remove(3);
		ssc.setSelected(conts);
		sendmail sm = new sendmail(ssc);
		system.assertEquals(3, sm.selected_contributors.size());
		system.assertEquals(2, sm.destinations.size());
	}
	
	public testmethod static void test_getDestinations_json(){
		list<contributor__c> conts = create_destinations();
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(conts);

		ssc.setSelected(conts);
		sendmail sm = new sendmail(ssc);
		list<contributor__c> conts_deserialized = (list<contributor__c>)JSON.deserialize(sm.getDestinations_json(), list<contributor__c>.class);
		system.assertEquals(2, conts_deserialized.size());
	}

	public testmethod static void test_send(){
		boolean err = false;
		list<id> dest_ids = new list<id>();

		list<contributor__c> conts = create_destinations();

		// No mail will be sent. (Dests is 0.)
		system.assertEquals(0, sendmail.send(dest_ids, 'testsender@hoge.com', 'test subject', 'test body'));

		// Add 2 valid dests.
		for (contributor__c cont : conts){
			dest_ids.add(cont.Id);
		}

		// Error. Sender not set.
		try {
			sendmail.send(dest_ids, '', 'test subject', 'test body');
		} catch (Exception e){
			system.assertEquals(system.label.sender_not_set, e.getMessage());
			err = true;
		}
		system.assertEquals(true, err);
		err = false;
		
		// Error. Subject not set.
		try {
			sendmail.send(dest_ids, 'testsender@hoge.com', '', 'test body');
		} catch (Exception e){
			system.assertEquals(system.label.subject_not_set, e.getMessage());
			err = true;
		}
		system.assertEquals(true, err);
		err = false;

		// Error. Body not set.
		try {
			sendmail.send(dest_ids, 'testsender@hoge.com', 'test subject', '');
		} catch (Exception e){
			system.assertEquals(system.label.body_not_set, e.getMessage());
			err = true;
		}
		system.assertEquals(true, err);
		err = false;

		// 2 mails sent.
		system.assertEquals(2, sendmail.send(dest_ids, 'testsender@hoge.com', 'test subject', 'test body'));
		system.assertEquals(1, [select Id from Task where WhatId = :dest_ids[0]].size());
		system.assertEquals(1, [select Id from Task where WhatId = :dest_ids[1]].size());
		system.assertEquals(0, [select Id from Task where WhatId = :dest_ids[2]].size());
		system.assertEquals(0, [select Id from Task where WhatId = :dest_ids[3]].size());
	}

	public testmethod static void test_send_more_than_govener_limit(){
		boolean err = false;
		list<id> dest_ids = new list<id>();
		list<contributor__c> conts = new list<contributor__c>();
		integer governer_limit = 15;

		id recordTypeId = [select id from recordType where developerName = 'regular' and SObjectType = 'contributor__c' and IsActive = true].id;
		integer num_of_conts = 1;
		while (num_of_conts <= (governer_limit + 1)){
			conts.add(new contributor__c(Name = 'User ' + String.valueOf(num_of_conts), email__c = 'user' + num_of_conts + '@hoge.com', RecordTypeId = recordTypeId));
			num_of_conts++;
		}
		insert conts;

		for (contributor__c cont : conts){
			dest_ids.add(cont.Id);
		}

		try {
			sendmail.send(dest_ids, 'testsender@hoge.com', 'test subject', 'test body');
		} catch (Exception e){
			system.assertEquals(system.label.exceed_daily_mail_limit, e.getMessage());
			err = true;
		}
		system.assertEquals(true, err);
		err = false;
	}

	public testmethod static void test_upload_file(){
		sendmail.upload_file('test file', 'image/jpeg', EncodingUtil.base64Encode(Blob.valueOf('test content')));
	}

	public testmethod static void test_crud_template(){
		// Delete existing data.
		delete [select Id from mail_template__c];

		// Test create and get.
		sendmail.create_template(new mail_template__c(Name = 'test template 1', subject__c = 'test subject 1', sender__c = 'testsender1@hoge.com', body__c = 'test sender 1'));
		sendmail.create_template(new mail_template__c(Name = 'test template 2', subject__c = 'test subject 2', sender__c = 'testsender2@hoge.com', body__c = 'test sender 2'));
		system.assertEquals(2, sendmail.get_templates().size());

		// Test update.
		list<mail_template__c> mts = sendmail.get_templates();
		mts[0].Name = 'test tempalte 1 updated';
		sendmail.update_template(mts[0]);
		system.assertEquals(mts[0].Name, sendmail.get_templates()[0].Name);

		// Test deleting.
		sendmail.delete_template(mts[0].Id);
		system.assertEquals(1, sendmail.get_templates().size());
	}
}