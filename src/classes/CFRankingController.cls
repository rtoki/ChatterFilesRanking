/**
*  CFRankingController
* 
*  @author rtoki
*  @copyright rtoki
*  @description Ranking controller
*
*/
public class CFRankingController {    
    public static Integer queryLimit = 10000;

    /**
      * Get collaboration groups
      */ 
    @AuraEnabled
    public static List<CollaborationGroup>getCollaborationGroups() {
        List<CollaborationGroup> groups= [SELECT Id,Name FROM CollaborationGroup ORDER BY Name];                 	// 0F9...
        return groups;
    }
    
    /**
      * Get collaboration group name
      * @param Id groupId 0F9....
      */
    @AuraEnabled
    public static String getCollaborationGroup(Id groupId) {
        String ret = '';
        if(groupId != null) {
            ret =  [SELECT Name FROM CollaborationGroup WHERE Id = :groupId LIMIT 1].Name;
        }
        return ret;           
    }
    
    /**
      *  Get CFRankingDoc
      *  @param Id collgroup collaboration group id
      */    
    @AuraEnabled
    public static List<CFRankingDoc> getDocs(Id collgroup, String span) { 
        
        List<Id> docIds = new List<Id>();   // docIds (069...)
        List<Id> docverIds = new List<Id>();   // docverIds (068...)
        List<CFRankingDoc> docs = new List<CFRankingDoc>();   // docs
        Map<Id, CFRankingDoc> docMap =new Map<Id, CFRankingDoc>(); // map of <docId, doc>         
        Map<Id, Id> docverMap =new Map<Id, Id>(); // map of <docverId, doc>
        String collgroupStr = collgroup;
        
        //  Get content filtered by Chatter group id (LinkedEntityId)
        String soql = 'SELECT Id,'
            +' ContentDocumentId,'	// 069...
            + 'ContentDocument.Title,'
            + 'ContentDocument.FileExtension,'
            + 'ContentDocument.FileType,'
            + 'ContentDocument.ContentSize,'
            + 'ContentDocument.LatestPublishedVersionId,'			// 068...
            + 'ContentDocument.CreatedBy.Name,'
            + 'ContentDocument.LastModifiedDate'
            + ' FROM ContentDocumentLink'
            + ' WHERE LinkedEntityId = :collgroup';
        if(span == 'Week') {
            soql += ' AND ContentDocument.LastModifiedDate >= THIS_WEEK';
        } else if (span == 'Month') {
            soql += ' AND ContentDocument.LastModifiedDate >= THIS_MONTH';            
        } else if (span == 'Year') {
            soql += ' AND ContentDocument.LastModifiedDate >= THIS_YEAR';            
        } 
        else if (span == 'All') {
            // do nothing
        }
        soql += ' ORDER BY ContentDocument.LastModifiedDate LIMIT :queryLimit';
		System.debug('soql = ' + soql);
        List<ContentDocumentLink> cdls = Database.query(soql);
            
        
        // Generate docs and docMap        
        for(ContentDocumentLink cdl: cdls) {                                            
            Id docid = cdl.ContentDocumentId;
            docIds.add(docid);    // add Id
            CFRankingDoc dl = New CFRankingDoc(
                docid,
                cdl.ContentDocument.Title,
                cdl.ContentDocument.FileExtension,
                cdl.ContentDocument.FileType,
                cdl.ContentDocument.ContentSize / 1024,	//Kb
                cdl.ContentDocument.LatestPublishedVersionId,
                cdl.ContentDocument.CreatedBy.Name,
                cdl.ContentDocument.LastModifiedDate);
            
            docs.add(dl);    // add doc
            docMap.put(docid, dl);    // map
            docverIds.add(cdl.ContentDocument.LatestPublishedVersionId);	// add docver
            docverMap.put(cdl.ContentDocument.LatestPublishedVersionId, docid);
        }
        
        // Get download count filtered by content document id
        List<AggregateResult>ars = [SELECT ContentVersion.ContentDocumentId ContentDocumentId, Count(Id) DownloadCountByUser 
                                    FROM ContentVersionHistory
                                    WHERE Field = 'contentVersionDownloaded' AND ContentVersion.ContentDocumentId IN :docIds
                                    GROUP BY ContentVersion.ContentDocumentId ];
        // Set download count
        for(AggregateResult ar: ars) {
            Id cid = (Id)ar.get('contentDocumentId');
            CFRankingDoc dl = (CFRankingDoc)docMap.get(cid);
            // Set donwload count
            dl.downloadCountByUser = (dl == null) ? 0 :  (Integer)ar.get('downloadCountByUser');
        }
                
        // Sort
        {
            List<CFRankingDoc> res = new List<CFRankingDoc>();
            Map<Integer, List<CFRankingDoc>> dlMap = new Map<Integer, List<CFRankingDoc>>();
            for(CFRankingDoc d :docs) {
                if(dlMap.get(d.downloadCountByUser) == null) {
                    dlMap.put(d.downloadCountByUser, new List<CFRankingDoc>());
                }
                dlMap.get(d.downloadCountByUser).add(d);
            }
            List<Integer> keys = new List<Integer>(dlMap.keySet());
            keys.sort();
            
            for(Integer key : keys) { 
                res.addAll(dlMap.get(key)); 
            }
            docs.clear();
            for(Integer i = res.size()-1; i >= 0; i--){
                docs.add(res[i]);  
            }                
        }
                
        // Get link to Chatter Feed (Feed Post)
/*
          for (FeedAttachment fa : [SELECT FeedEntityId, RecordId FROM FeedAttachment WHERE RecordId in :docverIds]) {
            Id cid = docverMap.get(fa.RecordId);
            CFRankingDoc dl = (CFRankingDoc)docMap.get(cid);
            dl.feedEntityId = fa.feedEntityId;
        }
*/
		// Search FeedItem and FeedComment without date (because lastmodified date is managed separately)
        for (FeedItem fi : [SELECT Id, RelatedRecordId, LikeCount FROM FeedItem WHERE ParentId = :collgroup AND Type = 'ContentPost' ORDER BY LastEditDate DESC LIMIT :queryLimit]) {
            Id cid = docverMap.get(fi.RelatedRecordId);
            if(cid != null) {
                CFRankingDoc dl = (CFRankingDoc)docMap.get(cid);
                dl.feedEntityId = fi.Id;
                dl.feedLikeCount = fi.LikeCount;
            }
        }
        
        // Get link to Chatter Feed (Feed Comment)
        for (FeedComment fc : [SELECT FeedItemId, RelatedRecordId FROM FeedComment  WHERE ParentId = :collgroup AND Commenttype = 'ContentComment' ORDER BY LastEditDate DESC  LIMIT :queryLimit]) {
            Id cid = docverMap.get(fc.RelatedRecordId);
            if(cid != null) {
                CFRankingDoc dl = (CFRankingDoc)docMap.get(cid);
                dl.feedEntityId = fc.FeedItemId;
            }
        }
        // NB: feed link will be broken if the file got ver-up'ed. 
        return docs;
    } 
    
    
   /**
     * Get Chatter Files
     * Get document info related to chatter group
     */
    @AuraEnabled
    public static List<AggregateResult> getChatterFiles() {
        List<AggregateResult> results = [SELECT ContentVersion.Title Title, count(Id) DownloadCountByUser, CreatedById
                                         FROM ContentVersionHistory
                                         WHERE Field = 'contentVersionDownloaded'
                                         GROUP BY createdbyid, ContentVersion.Title];
        return results;
    }
}