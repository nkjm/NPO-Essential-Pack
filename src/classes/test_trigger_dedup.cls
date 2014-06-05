@isTest
public with sharing class test_trigger_dedup {
    private static contributor__c create_contributor(){
        id recordType_id = [select id from recordType where developerName = 'regular' and SObjectType = 'contributor__c' and IsActive = true].id;
        contributor__c cont = new contributor__c(Name = 'lasdf asldjf', RecordTypeId = recordType_id);
        insert cont;
        return cont;
    }

    private static testmethod void test_dedupe(){
        contributor__c cont;
        membership_fee__c mfee;
        list<membership_fee__c> mfees = new list<membership_fee__c>();
        boolean error_found = false;

        cont = create_contributor();

        // Test inserting new and first membership_fee. Result will be success.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2013');
        insert mfee;

        //// 2013 is in database.

        // Test inserting non-duplicated membership_fee. Result will be success.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2014');
        insert mfee;

        //// 2013, 2014 are in database.

        // Test inserting duplicated membership_fee. Result will be fail.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2014');
        try {
            insert mfee;
        } catch (Exception e){
            error_found = true;
        }
        system.assertEquals(true, error_found);
        error_found = false;

        //// 2013, 2014 are in database.

        // Test bulk inserting non-duplicated membership_fee. Result will be success.
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2015'));
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2016'));
        insert mfees;

        //// 2013, 2014, 2015, 2016 are in database.

        // Test bulk inserting duplicated membership_fee. Result will be success.
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2016'));
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2017'));
        try {
            insert mfees;
        } catch (Exception e){
            error_found = true;
        }
        system.assertEquals(true, error_found);
        error_found = false;

        //// 2013, 2014, 2015, 2016 are in database.
        system.assertEquals(4, [select id from membership_fee__c where contributor__c = :cont.id].size());

        // Test inserting membership_fee with fy__c = null. Result will be success.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = null);
        insert mfee;

        //// 2013, 2014, 2015, 2016, null are in database.

        // Test inserting membership_fee with fy__c = null again. Result will be success.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = null);
        insert mfee;

        //// 2013, 2014, 2015, 2016, null, null are in database.
        system.assertEquals(6, [select id from membership_fee__c where contributor__c = :cont.id].size());
    }
}