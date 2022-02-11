public class getFile{

    public String boxResponse { get; set; }
    public String fileOpen(){
        string endpoint1 = 'https://auth.springcm.com/api/v201606/apiuser';
    
         HttpRequest req = new HttpRequest();
         req.setEndpoint(endpoint1 );
         req.setMethod('POST');
          req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(genPayload('97db3e7d-08b3-4dac-ba72-a1d7735fc7b8','e9ca9da13401462e9d4cfcf85ad842c9PkvEN39IijJAjQa9VEHGrfHQszslNZDITLp2Yg9p38M2NAkDg38VDsLAjgbUGb3Ta7URAHUNLyctGELH6CS0xn1Bev0EnzUa'));
    
      /*   Http binding = new Http();
         HttpResponse res = binding.send(req);
         Blob boxFile = res.getBodyAsBlob();
         boxResponse = 'data:'+res.getHeader('Content-Type')+';base64,'+EncodingUtil.base64Encode(boxFile );*/
         boxResponse = req.getBody();
         return boxResponse ;
    
    }
    private String genPayload(String client_id, String client_secret) {
        MyPayload mp = new MyPayload();
        mp.client_id = client_id;
        mp.client_secret = client_secret;
       
     
        return JSON.serialize(mp);
    }
    public class MyPayload {
        public String client_id;
        public String client_secret;
    }
}