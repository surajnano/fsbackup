/* Lightning Component Helper.
 * 
 * Created by - Suresh Meghnathi
 *
 * Modifications:
 * - Suresh Meghnathi, 05/06/2020 – Initial Development
 */
({
    // This method is used to initialize component.
    doInit : function(component, event, helper) {
        // Get folder
        var getFolderAction = component.get("c.getFolder");
		getFolderAction.setParams({
            "parentRecordId": component.get("v.recordId")
        });
        getFolderAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var targetFolderId = response.getReturnValue();
            	
                // Set target folder id
                component.set("v.parentRecordId", targetFolderId);
                
                if(!$A.util.isUndefinedOrNull(targetFolderId)){
                	component.set("v.success", true);
                }
            } else if(state == 'ERROR'){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        component.set("v.success", false);
                        component.set("v.folderCreationErrorMessage", errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(getFolderAction); 
    }
})