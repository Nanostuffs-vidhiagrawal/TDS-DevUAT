public class EI_SDS_SendManualEmailWrapper {
   
	public Integer Count;	//1
    @AuraEnabled
	public cls_Data[] Data;
	public Integer Total;	//1
    
	class cls_Data {
		public cls_MJMLContent MJMLContent;
        @AuraEnabled
		public String Html_part;	
        
        @AuraEnabled
		public String Text_part;
		
		public cls_Headers Headers;
	}
	class cls_MJMLContent {
		public String tagName;	//mjml
		public cls_children[] children;
		public cls_attributes attributes;
		public String id;	//26Pr8ZgZAzf
	}
	class cls_children {
		public cls_children[] children;
		public String tagName;	//mj-preview
		public String content;	//
		public String id;	//Tp45kwBPenK
		public cls_attributes attributes;
		public String id2;	//kW1jzqBvsSG
	}
	class cls_attributes {
		public String version;	//4.6.3
		public String owa;	//desktop
		public cls_passport passport;
	}
	class cls_passport {
		public boolean revertLostLink;
		public String id;	//bqAlOFcoIzS
		public String ck_version;	//5
	}
	public class cls_Headers {
        @AuraEnabled
		public String Subject;	//Invitation to respond to claim
		public String SenderName;	//Invitation to respond to claim
		public String ReplyEmail;	//
		public String X_MJ_TemplateLanguage;	//0
		public String from_email;	//Invitation to respond to claim <ashish.singh1@espire.com>
		public String Reply_To;	//
		public String SenderEmail;	//ashish.singh1@espire.com
	}
	public static EI_SDS_SendManualEmailWrapper parse(String json){
		return (EI_SDS_SendManualEmailWrapper) System.JSON.deserialize(json, EI_SDS_SendManualEmailWrapper.class);
	}
}