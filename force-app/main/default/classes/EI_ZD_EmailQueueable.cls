public class EI_ZD_EmailQueueable  implements Queueable { 
    String subject;
    String recList;
    Map<String,String> variables;
    String template;
    String mailjet;
    public EI_ZD_EmailQueueable(String subject, String recList,Map<String,String> variables,String template, String mailjet){
        this.subject = subject;
        this.recList = recList;
        this.variables = variables;
        this.template = template;
        this.mailjet = mailjet;
        
    }
    public void execute(QueueableContext context) {
          EI_ZD_EmailUtility.sendEmail(subject, recList, variables, template,  mailjet);
        // awesome code here
    }
}