trigger TriggerOnChargingStation on charge__c (after update) {
    Set<Id> contactIds = new Set<Id>();
    for(charge__c data:Trigger.new){
        if(data.Contact__c <> null &&
           data.Start_Time__c <> null && data.End_Time__c <> null && Trigger.oldMap.get(data.Id).End_Time__c == null){
               contactIds.add(data.Contact__c);
           }
    }
    if(contactIds.isEmpty()) return;
    Map<Id,Contact> contactIdToData = new Map<Id,Contact>([SELECT Id,card_value__c FROM Contact WHERE Id IN:contactIds]);
    Map<Id,Decimal> contactIdToChargeDue = new Map<Id,Decimal>();
    for(charge__c data:Trigger.new){
        if(data.Contact__c <> null &&
           data.Start_Time__c <> null && data.End_Time__c <> null && Trigger.oldMap.get(data.Id).End_Time__c == null)
        {
            Contact con = contactIdToData.get(data.contact__c); 
            con.card_value__c = con.card_value__c <> null ? con.card_value__c : 0;
            con.card_value__c = con.card_value__c - data.Cost__c;
            contactIdToData.put(data.contact__c,con);
            if(!contactIdToChargeDue.containsKey(data.contact__c)){
                contactIdToChargeDue.put(data.contact__c,0);
            }
            contactIdToChargeDue.put(data.contact__c,contactIdToChargeDue.get(data.contact__c) + data.Cost__c);
        }
    }
    UPDATE contactIdToData.values();
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for(Contact myContact:[SELECT Id,Name,Email,card_value__c FROM Contact WHERE Id IN:contactIdToData.keySet()]){
        Messaging.SingleEmailMessage mail = 
            new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(myContact.Email);
        mail.setToAddresses(sendTo);
        
        mail.setSenderDisplayName('Charge Deduction');
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('Notification on deduction for charging');
        String body = 'Dear ' + myContact.Name + ', ';
        body += 'Charge Amount Due is: $'+contactIdToChargeDue.get(myContact.Id);
        mail.setHtmlBody(body);
        
        // Step 5. Add your email to the master list
        mails.add(mail);
    }
    if(!mails.isEmpty() && !Test.isRunningTest()){
        Messaging.sendEmail(mails);
    }
}