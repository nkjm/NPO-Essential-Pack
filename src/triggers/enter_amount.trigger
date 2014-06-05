trigger enter_amount on membership_fee__c (before insert) {
    supporter__c config = supporter__c.getOrgDefaults();
    list<id> member_ids = new list<id>();
    for (membership_fee__c mf : Trigger.new){
        member_ids.add(mf.contributor__c);
    }
    map<id, contributor__c> cont_map = new map<id, contributor__c>([select recordType.DeveloperName from contributor__c where id in :member_ids]);
    
    for (membership_fee__c mf : Trigger.new){
        if (cont_map.get(mf.contributor__c).recordType.DeveloperName == 'regular'){
            mf.amount__c = config.regular_membership_fee__c;
        } else if (cont_map.get(mf.contributor__c).recordType.DeveloperName == 'support'){
            mf.amount__c = config.support_membership_fee__c;
        }
    }
}