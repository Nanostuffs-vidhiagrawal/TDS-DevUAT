({
	handleChangePassword: function (component, event, helpler) {
        var userId = $A.get( "$SObjectType.CurrentUser.Id");
        helpler.handleChangePassword(component, event, userId);
    },
    
})