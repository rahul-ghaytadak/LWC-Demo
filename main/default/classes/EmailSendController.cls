public class EmailSendController {
 @AuraEnabled 
    public static void sendMailMethod(Id mMail, Id whatId, String mSubject ,String mbody){
    
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(mMail);
        mail.setWhatId(whatId);
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }   
}