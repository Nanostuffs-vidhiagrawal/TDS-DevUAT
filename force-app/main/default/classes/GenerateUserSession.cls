public class GenerateUserSession {
 
     private static HttpResponse authenticateByUsernamePassword(String useName, String password) {
        String uri = Url.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/44.0';
//String body ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com"> <soapenv:Body> <urn:login> <urn:username>'+useName+'</urn:username> <urn:password>'+password+'</urn:password> </urn:login> </soapenv:Body> </soapenv:Envelope>';
  String body='<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +
            useName +
            '</username><password>' +
            password +
            '</password></login></Body></Envelope>';          
        Http h = new Http();
        HttpRequest hRqst = new HttpRequest();
        hRqst.setEndpoint(uri);
        hRqst.setMethod('POST');
        hRqst.setHeader('SOAPAction', 'VALUE');
        hRqst.setHeader('Accept', 'text/xml');
        hRqst.setHeader('Content-type', 'text/xml');
        hRqst.setHeader('charset', 'UTF-8');
        hRqst.setBody(body);
        return h.send(hRqst);
    }

    public static string getSessionId(string username, string password) {
       
        HttpResponse response = authenticateByUsernamePassword(username, password);
        system.debug(response.getStatusCode());
        if (response.getStatusCode() == 200) {
            Dom.XmlNode resultElmt = response.getBodyDocument()
                .getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                .getChildElement('result', 'urn:partner.soap.sforce.com');
            return resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
        }
        return null;
    }
    
    public  void doLogin()
{  
    /*pageReference pg = new pageReference('www.google.com'); 
    return pg.setRedirect(true);*/
 // return Site.login('deepali.mittal@espire.com6.0','sales123',''https://devuat-thedisputeservice.cs87.force.com/Sds/s/');
  //  return Site.login('deepali.mittal@espire.com','qwerty123','https://devuat-thedisputeservice.cs87.force.com/Sds/s/');
    //p.getRedirect(true);
}
}