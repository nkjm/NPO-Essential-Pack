@isTest
public with sharing class test_scrud {

    private static string ns = '';
    private static boolean err = false;

    private static testmethod void test_screate(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        system.assertNotEquals(null, a1.id);
    }

    private static testmethod void test_sread(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        mail_template__c a2 = (mail_template__c)scrud.sread('mail_template__c',a1.id);
        system.assertEquals(a1.name, a2.name);
    }

    private static testmethod void test_supdate(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        a1.name = 'ueroioegldkfj';
        scrud.supdate(a1);
        mail_template__c a2 = (mail_template__c)scrud.sread('mail_template__c',a1.id);
        system.assertEquals('ueroioegldkfj', a2.name);
    }

    private static testmethod void test_supsert(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        a1.name = 'ueroioegldkfj';
        scrud.supsert(a1);
        mail_template__c a2 = (mail_template__c)scrud.sread('mail_template__c',a1.id);
        system.assertEquals('ueroioegldkfj', a2.name);
    }

    private static testmethod void test_sdelete(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        scrud.sdelete(a1);
        system.assertEquals(0, [select id from mail_template__c where name = 'khdijfbeirfn'].size());
    }

    private static testmethod void test_squery(){
        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        list<sobject> sos = scrud.squery('select id, name from mail_template__c where name = \'khdijfbeirfn\'');
        boolean found = false;
        for (sobject so : sos){
            mail_template__c a = (mail_template__c)so;
            if (a.name == 'khdijfbeirfn'){
                found = true;
            }
        }
        system.assertEquals(true, found);
    }

    private static testmethod void test_slist(){
        try {
            scrud.slist('UnexistingObj');
        } catch (Exception e){
            system.assertEquals('Object not found.', e.getMessage());
            err = true;
        }
        system.assertEquals(true, err);
        err = false;

        mail_template__c a1 = new mail_template__c(name = 'khdijfbeirfn');
        scrud.screate(a1);
        list<sobject> sos = scrud.slist('mail_template__c');
        boolean found = false;
        for (sobject so : sos){
            mail_template__c a = (mail_template__c)so;
            if (a.name == 'khdijfbeirfn'){
                found = true;
            }
        }
        system.assertEquals(true, found);
    }

    private static testmethod void test_requireAccessible(){
        scrud.requireAccessible('mail_template__c');

        try {
            scrud.requireAccessible('UnexistingObj', new list<string>());
        } catch (Exception e){
            system.assertEquals('Object: UnexistingObj not found.', e.getMessage());
            err = true;
        }
        system.assertEquals(true, err);
        err = false;
    }

    private static testmethod void test_isAccessible(){
        system.assertEquals(true, scrud.isAccessible('mail_template__c'));

        try {
            scrud.isAccessible('UnexistingObj', new list<string>());
        } catch (Exception e){
            system.assertEquals('Object: UnexistingObj not found.', e.getMessage());
            err = true;
        }
        system.assertEquals(true, err);
        err = false;
    }

    private static testmethod void test_getFields(){
        scrud.getFields('mail_template__c');

        try {
            scrud.getFields('UnexistingObj');
        } catch (Exception e){
            system.assertEquals('Object: UnexistingObj not found.', e.getMessage());
            err = true;
        }
        system.assertEquals(true, err);
        err = false;
    }

    private static testmethod void test_getCreateableFields(){
        try {
            scrud.getCreateableFields('UnexistingObj');
        } catch (Exception e){
            system.assertEquals('Object: UnexistingObj not found.', e.getMessage());
            err = true;
        }
        system.assertEquals(true, err);
        err = false;

        list<string> fs = scrud.getCreateableFields('mail_template__c');
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getCreateableFieldsInCSV(){
        string field_csv = scrud.getCreateableFieldsInCSV('mail_template__c');
        list<string> fs = field_csv.split(',', 0);
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getAccessbileFields(){
        list<string> fs = scrud.getAccessibleFields('mail_template__c');
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'CreatedDate'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);

        fs = scrud.getAccessibleFields('mail_template__c', true);
        allowed_field_found = false;
        not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'CreatedDate'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(true, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getAccessbileFieldsInCSV(){
        string field_csv = scrud.getAccessibleFieldsInCSV('mail_template__c');
        list<string> fs = field_csv.split(',', 0);
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'CreatedDate'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);

        field_csv = scrud.getAccessibleFieldsInCSV('mail_template__c', true);
        fs = field_csv.split(',', 0);
        allowed_field_found = false;
        not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'CreatedDate'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(true, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }


    private static testmethod void test_getUpdateableFields(){
        list<string> fs = scrud.getUpdateableFields('mail_template__c');
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getUpdateableFieldsInCSV(){
        string field_csv = scrud.getUpdateableFieldsInCSV('mail_template__c');
        list<string> fs = field_csv.split(',', 0);
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getUpsertableFields(){
        list<string> fs = scrud.getUpsertableFields('mail_template__c');
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }

    private static testmethod void test_getUpsertableFieldsInCSV(){
        string field_csv = scrud.getUpsertableFieldsInCSV('mail_template__c');
        list<string> fs = field_csv.split(',', 0);
        boolean allowed_field_found = false;
        boolean not_allowed_field_found = false;
        for (string f : fs){
            if (f.toLowerCase() == 'Name'){
                allowed_field_found = true;
            }
            if (f.toLowerCase() == 'Id'){
                not_allowed_field_found = true;
            }
        }
        system.assertEquals(false, not_allowed_field_found);
        system.assertEquals(true, allowed_field_found);
    }
}