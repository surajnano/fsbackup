({  
    doInit : function(cmp){

        var action = cmp.get("c.getRateSchedule");
        action.setParams({ rateId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                cmp.set("v.rateSchedule", response.getReturnValue());
            }
        });
 
        $A.enqueueAction(action);
    },

    confirmAction : function(cmp) {
        
        var action = cmp.get("c.executeBatch");
        action.setParams({ rateId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            let jobid = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            if(jobid){
                toastEvent.setParams({
                    "type"   : "success",
                    "message": "Batch successfully queued.",
                    "mode"   : "pester"
                });
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                toastEvent.setParams({
                    "type"   : "error",
                    "message": "There was an error queueing the batch. Contact your salesforce administrator.",
                    "mode"   : "pester"
                });
            }
            
            toastEvent.fire();
            
        });
 
        $A.enqueueAction(action);

        
    },

    cancel : function(){
        $A.get("e.force:closeQuickAction").fire();
    },

    showSpinner: function(cmp) {
        cmp.set("v.showSpinner", true); 
    },
     
    hideSpinner : function(cmp){
        cmp.set("v.showSpinner", false);
    }
})