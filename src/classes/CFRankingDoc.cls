/**
 *  CFRankingDoc
 * 
 *  @author rtoki
 *  @copyright rtoki
 *  @description a wrapper class for storing file info
 *
 */
public class CFRankingDoc {
    @AuraEnabled
    public Id contentDocumentId { get; set;}
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String fileExtension { get; set; }
    @AuraEnabled
    public String fileType { get; set; }
    @AuraEnabled
    public Integer contentSize { get; set; }
    @AuraEnabled
    public String userName { get; set; }
   @AuraEnabled
    public Datetime lastModifiedDate { get; set; }
    @AuraEnabled
    public String latestPublishedVersionId { get; set;}

    @AuraEnabled
    public Integer downloadCountByUser { get; set; }
    @AuraEnabled
    public String linkedEntityId { get; set; }
    @AuraEnabled
    public String imageUrl { get; set; }	// thumbnail image url
	@AuraEnabled
    public Id feedEntityId { get; set; }	// chatter feed entity id
    @AuraEnabled
    public Integer feedLikeCount { get; set; }	// feed like count (feed item only. not supported feed comments. needs rest call to get likes of feed comments..)
    @AuraEnabled
    public Integer feedCommentCount {get; set; } // feed comment count (feed item only. not supported feed comments)
    
    // constractor    
    public CFRankingDoc(Id cid, String t, String fe, String ft, Integer cs, Id lid, String un, Datetime lmd) {
        contentDocumentId = cid;
        title = t;
        fileExtension = fe;
        fileType = ft;
        contentSize = cs;
        latestPublishedVersionId = lid;
        userName = un;
        lastModifiedDate = lmd;
        
        // thumbnail image url
        //     https://developer.salesforce.com/blogs/engineering/2014/04/building-content-rich-visualforce-pages-with-salesforce-crm-content.html
        if(fileType == 'ZIP') {
            imageUrl = '/sfc/images/docicons/doctype_zip_32.png';
        } else {
	        imageUrl =  '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + lid;
        }
		// init
        downloadCountByUser = 0;
        feedEntityId = null;
    }
    
		
}