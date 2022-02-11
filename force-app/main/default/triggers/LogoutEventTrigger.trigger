trigger LogoutEventTrigger on LogoutEventStream (after insert) { 
  LogoutEventStream event = Trigger.new[0];
  Id userId = event.UserId;
    /*try{
        Update new User(Id = userId, Move_To_Certificate_Payment__c = false);
    }catch(Exception e){
        System.debug(e.getMessage());
    }
  */
    Update new User(Id = userId, Move_To_Certificate_Payment__c = false);
}