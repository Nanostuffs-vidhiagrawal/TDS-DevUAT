public class TestWorkingDays {
     public static Integer calculateWorkingDays(Date startDate, Date endDate)
    {        
              
        Integer workingDays = 0;
       
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)
        {
            Date dt = startDate + i;
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            String todayDay = currDate.format('EEEE');
            if(todayDay != 'Saturday' && todayDay !='Sunday')
            {
                workingDays = workingDays + 1;
            }
        }
       
        System.debug('--Working days'+workingDays);
        return workingDays-1;
    }
public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
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
        if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }



}