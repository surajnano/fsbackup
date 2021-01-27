({
    confirmSuccess : function() {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    cancel : function(){
        $A.get("e.force:closeQuickAction").fire();
    }

})