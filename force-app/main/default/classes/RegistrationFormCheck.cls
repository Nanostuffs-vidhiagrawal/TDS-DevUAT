public class RegistrationFormCheck {

    public String imageURL{get;set;}

    public RegistrationFormCheck(){
        imageURL='/servlet/servlet.FileDownload?file=';
        List<Document> documentList=[select name from document where Name=:Label.Registration_Form];
        
        if(documentList.size()>0){
            imageURL=imageURL+documentList[0].id;
        }
    }
}