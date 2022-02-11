public class UpdateProfileClass{
public UpdateProfileClass(){}
public void doProfileUpdate(){     
        try{
            String userId = ApexPages.currentPage().getParameters().get('userId');
            String profileId = ApexPages.currentPage().getParameters().get('profileId');
            System.debug('USERID '+userId +' @@ '+profileId );
            update new User(Id=userId,ProfileId = profileId,
                            User_Type__c = ApexPages.currentPage().getParameters().get('userType'),
                            Old_Member_ID__c = ApexPages.currentPage().getParameters().get('userOldMemberId'),
                            MemberId__c = ApexPages.currentPage().getParameters().get('userMemberId'));
        }
        Catch(Exception e){
            System.debug('::::user profile not update'+e);
        }
    }
}