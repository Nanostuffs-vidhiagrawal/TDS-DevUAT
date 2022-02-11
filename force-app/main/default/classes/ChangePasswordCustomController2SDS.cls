public class ChangePasswordCustomController2SDS {
    public String newPassword { get; set; }
    public String verifyNewPassword { get; set; }
    public String target{get;set;}
    public ChangePasswordCustomController2SDS()
    {
      target='no';
    } 
     
    public PageReference changePassword() {
        System.PageReference abc= Site.changePassword(newPassword, verifyNewPassword);
        if (abc != null)
        {
            target = 'yes';
            String customLabelValue = System.Label.EI_SDScommunityURL;
            PageReference pageRef = new PageReference(customLabelValue);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
           target = 'no';
            return null;
        }
        
    }
    /*public  Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }*/
    
}