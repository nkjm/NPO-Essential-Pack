trigger update_expiration_date on membership_fee__c (after insert, after update, after delete) {
    list<contributor__c> conts_to_update = new list<contributor__c>();
    list<membership_fee__c> mfees;
    if (Trigger.isInsert || Trigger.isUpdate){
        mfees = Trigger.new;
    } else {
        mfees = Trigger.old;
    }
    
    // Create id list of contributor__c where new membership_fee__c will be inserted/updated
    list<id> cont_ids = new list<id>();
    for (membership_fee__c mfee : mfees){
        cont_ids.add(mfee.contributor__c);
    }
    
    // Retrieve contributor__c Map based on id list
    map<id, contributor__c> cont_map = new map<id, contributor__c>([select id, expiration_date__c, (select id, fy__c from membership_fee__r) from contributor__c where id in :cont_ids]);
    
    // Check if this membership_fee is newer than existing records.
    string newest_fy = '0000';
    
    for (membership_fee__c mfee : mfees){
        if (mfee.fy__c == null){
            continue;
        }
        for (membership_fee__c existing_mfee : cont_map.get(mfee.contributor__c).membership_fee__r){
            if (newest_fy < existing_mfee.fy__c){
                newest_fy = existing_mfee.fy__c;
            }
        }
        
        date expiration_date;
        if (newest_fy == '0000'){
            expiration_date = null;
        } else {
            expiration_date = system.date.newInstance(integer.valueOf(newest_fy) + 1, 3, 31);
        }

        cont_map.get(mfee.contributor__c).expiration_date__c = expiration_date;
    }
    
    for (id cont_key : cont_map.keyset()){
        conts_to_update.add(cont_map.get(cont_key));
    }
    
    update conts_to_update;
}