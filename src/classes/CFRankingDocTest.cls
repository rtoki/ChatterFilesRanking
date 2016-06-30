@isTest
private class CFRankingDocTest {
    static testMethod void validateCFRankingDoc() {
        CFRankingDoc d = new CFRankingDoc(null, 'test', 'test', 'test', 0, null, 'test', null);
        d.downloadCountByUser = 0;
        d.linkedEntityId = '';
       // Test that the trigger correctly updated the price
       System.assertEquals(null, d.contentDocumentId);
       System.assertEquals('test', d.title);
       System.assertEquals('test', d.fileType);
       System.assertEquals(0, d.contentSize);
       System.assertEquals(0, d.downloadCountByUser);
       System.assertEquals('',d.linkedEntityId);
       System.assertEquals(null, d.latestPublishedVersionId);
       System.assertEquals(null, d.lastModifiedDate);
    }
}