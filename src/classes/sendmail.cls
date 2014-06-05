public with sharing class sendmail {
    public list<contributor__c> selected_contributors {get;set;}
    public list<contributor__c> destinations {get;set;}

    public sendmail(ApexPages.StandardSetController controller) {
        this.selected_contributors = (list<Contributor__c>)controller.getSelected();
        this.destinations = getDestinations();
    }

    public list<contributor__c> getDestinations(){
    	list<id> selected_ids = new list<id>();
    	for (contributor__c cont : this.selected_contributors){
    		selected_ids.add(cont.id);
    	}

        scrud.requireAccessible('contributor__c', new list<string>{'Id','Name','email__c'});
    	return [select id, name, email__c, RecordType.Name from contributor__c where id in :selected_ids and email__c <> null];
    }

    public string getDestinations_json(){
    	return JSON.serialize(this.destinations).stripHtmlTags();
    }

    private class sexception extends exception {}

    @remoteAction
    public static integer send(list<id> destination_ids, string sender, string subject, string body){
        scrud.requireAccessible('contributor__c', new list<string>{'Id','Name','email__c'});
        list<contributor__c> conts = [select id, name, email__c from contributor__c where id in :destination_ids and email__c <> null];
        if (conts.size() == 0){
            return 0;
        }

        if (String.isBlank(sender)){
            sexception se = new sexception();
            se.setMessage(system.label.sender_not_set);
            throw se;
        }

        if (String.isBlank(subject)){
            sexception se = new sexception();
            se.setMessage(system.label.subject_not_set);
            throw se;
        }

        if (String.isBlank(body)){
            sexception se = new sexception();
            se.setMessage(system.label.body_not_set);
            throw se;
        }

        // reserve mail resource.
        try {
            Messaging.reserveSingleEmailCapacity(conts.size());
        } catch (Exception e){
            sexception se = new sexception();
            se.setMessage(system.label.exceed_daily_mail_limit);
            throw se;    
        }
        
        
        List<Messaging.singleEmailMessage> mails = new List<Messaging.singleEmailMessage>();
        string task_status_for_closed = [select MasterLabel from TaskStatus where isClosed = true][0].MasterLabel;
        list<task> tsks = new list<task>(); // for loggig to ActivityHistory
        for (contributor__c cont : conts){
            
            //Initialize Messaging Object.
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
                
            //Set To:
            list<string> to_addresses = new list<string>();
            to_addresses.add(cont.email__c);
            mail.setToAddresses(to_addresses);
                
            //Set Sender:
            mail.setSenderDisplayName(sender);
                
            //Set Reply-To:
            mail.setReplyTo(sender);
            
            //Set Subject:
            mail.setSubject(subject);
            
            //Set Message Body:
            mail.setPlainTextBody(body);
                
            //Add to list
            mails.add(mail);

            tsks.add(new task(
                WhatId = cont.Id,
                Description = body,
                Status = task_status_for_closed,
                Subject = subject
            ));
        }
                
        if (mails.size() > 0){
            // send
            Messaging.SendEmailResult[] sers = Messaging.sendEmail(mails);
            for (Messaging.SendEmailResult ser : sers){
                if (!ser.isSuccess()){
                    sexception se = new sexception();
                    Messaging.SendEmailError[] sees = ser.getErrors();
                    for (Messaging.SendEmailError see : sees){
                        se.setMessage(see.getMessage() + ' ');
                    }
                    throw se;
                }
            }

            // log to ActivityHistory
            scrud.screate(tsks);
        }
        
        return mails.size();
    }

    @remoteAction
    public static list<mail_template__c> get_templates(){
        return scrud.slist('mail_template__c');
    }

    @remoteAction
    public static void create_template(mail_template__c mail_template){
        scrud.screate(mail_template);
    }

    @remoteAction
    public static void update_template(mail_template__c mail_template){
        scrud.supdate(mail_template);
    }

    @remoteAction
    public static void delete_template(id template_id){
        scrud.sdelete([select id from mail_template__c where Id = :template_id]);
    }
}