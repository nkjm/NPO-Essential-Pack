@isTest(seeAllData=true)
public with sharing class test_trigger_enter_amount {
    private static double regular_membership_fee = 5000;
    private static double support_membership_fee = 3000;

    private static contributor__c create_contributor(string member_recordtype){
        id recordType_id = [select id from recordType where developerName = :member_recordType and SObjectType = 'contributor__c' and IsActive = true].id;
        contributor__c cont = new contributor__c(Name = 'lasdf asldjf', RecordTypeId = recordType_id);
        insert cont;
        return cont;
    }

    private static testmethod void test_enter_amount(){
        contributor__c cont;
        membership_fee__c mfee;

        // Test inserting membership_fee__c for regular member. amount__c will be 5000.
        cont = create_contributor('regular');
        mfee = new membership_fee__c(contributor__c = cont.Id);
        insert mfee;
        system.assertEquals(regular_membership_fee, [select amount__c from membership_fee__c where id = :mfee.id].amount__c);

        // Test inserting membership_fee__c for support member. amount__c will be 3000.
        cont = create_contributor('support');
        mfee = new membership_fee__c(contributor__c = cont.Id);
        insert mfee;
        system.assertEquals(support_membership_fee, [select amount__c from membership_fee__c where id = :mfee.id].amount__c);

        // Test inserting membership_fee__c for general (non-member).amount__c will be null. *This use case should not happen practically.
        cont = create_contributor('general');
        mfee = new membership_fee__c(contributor__c = cont.Id);
        insert mfee;
        system.assertEquals(null, [select amount__c from membership_fee__c where id = :mfee.id].amount__c);
    }
}