trigger dedup on membership_fee__c (before insert, before update) {
    // Create id list of contributor__c where new membership_fee__c will be inserted/updated
    list<id> cont_ids = new list<id>();
    for (membership_fee__c mfee : Trigger.new){
        cont_ids.add(mfee.contributor__c);
    }
    
    // Retrieve contributor__c Map based on id list
    map<id, contributor__c> cont_map = new map<id, contributor__c>([select id, (select id, fy__c from membership_fee__r) from contributor__c where id in :cont_ids]);
    
    // Check duplication
    for (membership_fee__c mfee : Trigger.new){
        if (mfee.fy__c == null){
            continue;
        }
        for (membership_fee__c existing_mfee : cont_map.get(mfee.contributor__c).membership_fee__r){
            if (mfee.fy__c == existing_mfee.fy__c){
                mfee.addError(mfee.fy__c + system.label.membership_fee_already_paid);
            }
        }
    }
}