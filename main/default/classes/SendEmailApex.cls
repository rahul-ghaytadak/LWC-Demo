public class SendEmailApex {
    public class values{
        @invocableVariable
        public String docId;
        @invocableVariable(required=true)
        public ID recordId;
        @invocableVariable(required=true)
        public String emailTemplateName;
        @invocableVariable(required=true)
        public ID recipientId;
        @invocableVariable
        public Boolean AttachAgreementFromContract;
    }
    
    @invocableMethod(label = 'invokeSendEmail')
    public static void invokeSendEmail(List<values> v){
        List<ID> docIds = new List<ID>();
        if(v[0].docId != NULL){
            if(v[0].docId.contains(','))
                docIds = v[0].docId.split(',');
        }
        if(v[0].AttachAgreementFromContract == False)
            sendEmail(docIds, v[0].emailTemplateName, v[0].recipientId,v[0].recordId );
        else{
            List<Contract> cRecord = [SELECT Id, Opportunity__c, Signed_Agreement__c FROM Contract WHERE Id =: v[0].recordId];
            List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
            if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
            sendEmail(docIds, v[0].emailTemplateName, v[0].recipientId, cRecord[0].Opportunity__c );
        }
    }
    public static void sendEmail(List<Id> docIds, String emailTemplateName, Id recipientId, Id recordId){
        //Opportunity oppRecord = [SELECT Id, Broker__r.Primary_Contact__r.FirstName, Broker__r.Primary_Contact__r.Email , Owner.Name, Account.Name FROM Opportunity WHERE Id =: recordId ];
        
        List<Attachment> attachmentRecords = [Select Name, Body From Attachment Where id =: docIds ];
        EmailTemplate ET = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: emailTemplateName LIMIT 1];
        if(ET != NULL){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.templateid = ET.Id;
            message.setTargetObjectId(recipientId);
            message.setWhatId(recordId);   
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                message.setEntityAttachments(docIds);
            message.setSaveAsActivity(true);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
            system.debug('res ' + results);
        }
    }
}