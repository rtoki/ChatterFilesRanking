@isTest 
private class CFRankingControllerTest {
    static testMethod void validateCFRankingController() {
        
        // Create CollaborationGroup
        CollaborationGroup cg = new CollaborationGroup(
            Name = 'New Group',
            CollaborationType = 'Private'
        );        
        INSERT cg;
        
        // Create ContentVersion in order to generate ContentDocument
        ContentVersion cv = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('test'),
            IsMajorVersion = true
        );
        INSERT cv;
        System.debug('****** Content Version = ' + cv.Id);      
        
        // Create feeditem
        FeedItem fi = new FeedItem(
        	ParentId = cg.Id,
            Body = 'hi there',
            Type = 'ContentPost',
            Title = 'Test',
            RelatedRecordId = cv.Id
        );
        INSERT fi;
        
        List<ContentDocumentLink> links = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink WHERE linkedEntityId = :cg.Id ];
        System.debug('***** contentdocumentlink = ' + links.get(0));
/*        
		// Get ContentDocument
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        System.debug('****** Content Document = ' + cd.Id);
        ContentDocumentLink link = new ContentDocumentLink(
        	LinkedEntityId = cg.Id,
        	ContentDocumentId = cd.Id,
        	ShareType = 'V',
        	Visibility = 'AllUsers'
        );
        INSERT link;
*/
			        
		// Test        
        List<CollaborationGroup> cgroups = CFRankingController.getCollaborationGroups();
        Id collgroup = cgroups.get(0).Id;
        List<CFRankingDoc> doclinks = CFRankingController.getDocs(collgroup, 'All');
        CFRankingController.getChatterFiles();
        CFRankingController.getCollaborationGroup(collgroup);
        
        // Check
        System.assertEquals(1, cgroups.size());
        System.assertEquals(1, doclinks.size());
    }
}