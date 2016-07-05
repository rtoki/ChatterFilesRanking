({    
    doInit : function(cmp, event, helper) {
        console.log("doInit");
        helper.getCollaborationGroups(cmp);        
        var group = cmp.get("v.group");        

        // groupが設定されていた場合
        if(group && group != '') {
	        helper.setActiveTab(cmp, 'All');
   		     helper.getDocs(cmp, group, 'All');
        }
    },
    onChange: function(cmp, evt, helper) {
        console.log("onChange");
        // すべてで表示
        helper.setActiveTab(cmp, 'All');
        var group = cmp.find("entityList").get("v.value");       
        helper.getDocs(cmp, group, 'All');
    },
	// tabs
    pushWeekTab : function(cmp, evt, helper) {
        console.log("pushWeekTab");
		helper.setActiveTab(cmp, 'Week');
        var group = ( cmp.get("v.group") != '') ? cmp.get("v.group") : cmp.find("entityList").get("v.value");        
        helper.getDocs(cmp, group, 'Week');
    },
    pushMonthTab : function(cmp, evt, helper) {
        console.log("pushMonthTab");
		helper.setActiveTab(cmp, 'Month');
        var group = ( cmp.get("v.group") != '') ? cmp.get("v.group") : cmp.find("entityList").get("v.value");        
        helper.getDocs(cmp, group, 'Month');
    },
    pushYearTab : function(cmp, evt, helper) {
        console.log("pushYearTab");
		helper.setActiveTab(cmp, 'Year');
        var group = ( cmp.get("v.group") != '') ? cmp.get("v.group") : cmp.find("entityList").get("v.value");        
        helper.getDocs(cmp, group, 'Year');
    },
    pushAllTab : function(cmp, evt, helper) {
		console.log("pushAllTab");
		helper.setActiveTab(cmp, 'All');
        var group = ( cmp.get("v.group") != '') ? cmp.get("v.group") : cmp.find("entityList").get("v.value");        
        helper.getDocs(cmp, group, 'All');        
    }

})