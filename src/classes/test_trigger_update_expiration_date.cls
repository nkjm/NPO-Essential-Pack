@isTest
public with sharing class test_trigger_update_expiration_date {
    private static contributor__c create_contributor(){
        id recordType_id = [select id from recordType where developerName = 'regular' and SObjectType = 'contributor__c' and IsActive = true].id;
        contributor__c cont = new contributor__c(Name = 'lasdf asldjf', RecordTypeId = recordType_id);
        insert cont;
        return cont;
    }
    
    private static testmethod void test_update_expiration_date(){
        contributor__c cont;
        membership_fee__c mfee;
        list<membership_fee__c> mfees = new list<membership_fee__c>();
        boolean error_found = false;

        cont = create_contributor();

        // Test inserting new and first membership_fee. Expiration date will be updated.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2013');
        insert mfee;
        system.assertEquals(system.date.newInstance(2014,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2014/3/31

        // Test inserting newer membership fee. Expiration date will be updated.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2014');
        insert mfee;
        system.assertEquals(system.date.newInstance(2015,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2015/3/31

        // Test inserting older membership fee. Expiration date will not be updated.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = '2012');
        insert mfee;
        system.assertEquals(system.date.newInstance(2015,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2015/3/31
        
        // Test updating fy of a membership fee to newest. Expiration date will be updated.
        mfee.fy__c = '2015';
        update mfee;
        system.assertEquals(system.date.newInstance(2016,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2016/3/31
        
        //Test updating fy of a membership fee to oldest. Expiration date will be updated.
        mfee.fy__c = '2011';
        update mfee;
        system.assertEquals(system.date.newInstance(2015,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2015/3/31
        
        //Test deleting newest membershiop fee. Expiration date will be updated.
        mfee = [select id, fy__c from membership_fee__c order by fy__c][0];
        delete mfee;
        system.assertEquals(system.date.newInstance(2014,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2014/3/31
        
        //Test deleting oldest membershiop fee. Expiration date will not be updated.
        mfee = [select id from membership_fee__c order by fy__c desc][0];
        delete mfee;
        system.assertEquals(system.date.newInstance(2014,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);

        //// expiration date is 2014/3/31
        
        // Test bulk inserting membership_fee including newest fy. Expiration date will be updated
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2010'));
        mfees.add(new membership_fee__c(contributor__c = cont.id, fy__c = '2015'));
        insert mfees;
        system.assertEquals(system.date.newInstance(2016,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);
        
        //// expiration date is 2016/3/31
        
        //Test inserting membership fee with null fy. Expiration date will not be updated.
        mfee = new membership_fee__c(contributor__c = cont.id, fy__c = null);
        insert mfee;
        system.assertEquals(system.date.newInstance(2016,3,31), [select expiration_date__c from contributor__c where id = :cont.id].expiration_date__c);
    }
}