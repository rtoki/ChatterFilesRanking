({
    // Get collaboration groups
    getCollaborationGroups : function(cmp) {
        var act = cmp.get("c.getCollaborationGroups");
        act.setCallback(this, function(data) {
       		if(data.getState() === "SUCCESS") {
            	cmp.set("v.entities", data.getReturnValue());
            }
        });
        $A.enqueueAction(act);
    },
    // Get collaboration group and set groupName in cmp
    getCollaborationGroup:function(cmp, groupId) {
        var act = cmp.get("c.getCollaborationGroup");
        act.setParams({ groupId : groupId});
        act.setCallback(this, function(data) {
            if(data.getState() === "SUCCESS") {
                cmp.set("v.groupName", data.getReturnValue());
            }
        });
        $A.enqueueAction(act);
    },
    // Get docs
    getDocs: function(cmp, group, span) {
        console.log('getDocs group = ' + group + ', span = ' + span);

        var act = cmp.get("c.getDocs");
        act.setParams({ collgroup : group, span : span });
        act.setCallback(this, function(data) {
            if(data.getState() === "SUCCESS") {                
                cmp.set("v.docs", data.getReturnValue());
            } else if (data.getState() === "ERROR") {
                $A.log("Errors", data.getError());
            }
        });
        $A.enqueueAction(act);
    },
    // Tab style changes 
    setActiveTab:function(cmp, span) {
		var week_li = cmp.find("week_li");
        var month_li = cmp.find("month_li");
        var year_li = cmp.find("year_li");
        var all_li = cmp.find("all_li");

		$A.util.removeClass(week_li, 'slds-active');
        $A.util.removeClass(month_li, 'slds-active');
        $A.util.removeClass(year_li, 'slds-active');
        $A.util.removeClass(all_li, 'slds-active');
                
        if (span == 'Week') {
		        $A.util.addClass(week_li, 'slds-active');
        } else if(span == 'Month') {
		        $A.util.addClass(month_li, 'slds-active');            
         } else if(span == 'Year') {
		        $A.util.addClass(year_li, 'slds-active');            
        } else if(span == 'All') {
            	$A.util.addClass(all_li, 'slds-active');
        }
        
        
    }
})