/**
 * Created by Muhammad on 16/11/20.
 */

({
    confirmSuccess : function() {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    cancel : function(){
        $A.get("e.force:closeQuickAction").fire();
    }

});