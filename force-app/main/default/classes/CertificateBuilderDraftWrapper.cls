global class CertificateBuilderDraftWrapper{
  public Address TenantAddress;  //
  public String AmountOfDipositProtected;  //
    public string AmountOfDipositAgreementProtected;
//  public String TenancyAgreementStartDate;  //
    public String RentAmount;  
    public String DepositAmount;
    public String ProtectedAmount;
    public String TenancyAgreementStartDate;
    public String landlordReceivedDate; 
    public String DepositReference;
  public String TenancyAgreementExpected;  //
  public String DateAgent_landlordReceived;  //
  public String DateSSDReceivedTheDeposit;  //
    
  public cls_Tenants[] Tenants;
  public cls_Landlords[] Landlords;
  public class cls_Tenants {
        public boolean isOrguser;
        public String TenantTittle;
        public String TenantcompanyName;
        public String phoneCode;
        public String TenantFirstName;
    public String TenantLastName;  //
    public String TenantEmail;  //
    public String TenantPhone;  //
  }
  public class cls_Landlords {
        public boolean isOrguser;
        public String LandlordTittle;
        public String LandlordCompanyName;  
        public String LandlordCompanyPhone;
         public String LandlordCompanyPhoneCode;  
    public String LandlordFirstName;  //
        public String LandlordLastName;
    public String LandlordEmail;  //
    public String LandlordPhone;  //
        public String LandlordPhoneCode;
        public String LandlordRegStatus;
        public boolean isPrimaryLandlord;
        public String LandlordRegNumber;
    public Address LandlordAddress;  //
  }
    public class Address {
    public String street;  //
        public String houseNo;
    public String city;  //
    public String county;  //
    public String country;  //
    public String postalcode;  //
        public String localAuthorityArea;
  }
/*  public static CertificateBuilderDraftWrapper parse(String json){
    return (CertificateBuilderDraftWrapper) System.JSON.deserialize(json, CertificateBuilderDraftWrapper.class);
  }

  static testMethod void testParse() {
    String json=    '{'+
    '  "TenantAddress":"",'+
    '  "AmountOfDipositProtected":"",'+
    '  "TenancyAgreementStartDate":"",'+
    '  "TenancyAgreementExpected":"",'+
    '  "DateAgent/landlordReceived":"",'+
    '  "DateSSDReceivedTheDeposit":"",'+
    '  "Tenants":['+
    '     {'+
    '        "TenantName":"",'+
    '        "TenantEmail":"",'+
    '        "TenantPhone":""'+
    '     },'+
    '     {'+
    '        "TenantName":"",'+
    '        "TenantEmail":"",'+
    '        "TenantPhone":""'+
    '     }'+
    '  ],'+
    '  "Landlords":['+
    '     {'+
    '        "LandlordName":"",'+
    '        "LandlordEmail":"",'+
    '        "LandlordPhone":"",'+
    '        "LandlordAddress":""'+
    '     },'+
    '     {'+
    '        "LandlordName":"",'+
    '        "LandlordEmail":"",'+
    '        "LandlordPhone":"",'+
    '        "LandlordAddress":""'+
    '     }'+
    '  ]'+
    '}';
    CertificateBuilderDraftWrapper obj = parse(json);
    System.assert(obj != null);
  }*/
}