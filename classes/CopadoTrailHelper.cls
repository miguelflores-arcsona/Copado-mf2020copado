public class CopadoTrailHelper {

    /**
     * This method will search for a metadata cache file and clear the log based on a namespace.
     * In addition we also do not include the CopadoTrailHelper and TestCopadoTrailHelper classes.
     * @param ns Namespace to be cleared.
     * @param orgName the Org Credential Name for which we want to clear the log.
     * @return void
     */
    public static void trimMetadataCache(String ns, String orgName) {
        Map<Id, copado__Org__c> orgs = new Map<Id, copado__Org__c>([select Id from copado__Org__c where Name=:orgName]);
        List<Attachment> atts = new List<Attachment>();
        
        if(orgs.keySet().size()==0)return;
        
        //If we have found one or more org credentials.
        atts = [select Id, Body from Attachment where ParentId IN:orgs.keySet() and Name='MetaData'];
        
        for(Attachment a : atts) {
            system.debug('------------------------------------------------------');
            List<cacheFile> newCache = new List<cacheFile>();
        	List<cacheFile> theCache = (List<CacheFile>) JSON.deserialize(a.Body.toString(), List<CacheFile>.class);
        	system.debug(theCache.size());
            for(CacheFile cf : theCache) {
                if(!cf.n.contains(ns) && !cf.n.contains('CopadoTrailHelper')){
                    system.debug('>>>>> Adding: '+cf.n);
                    newCache.add(cf);
                }
            }
            system.debug('>>>> newCache: '+newCache.size());
            String newCacheString = JSON.serialize(newCache);
            a.Body = Blob.valueOf(newCacheString);
        }
        update atts;
    }
    
    /**
     * The wrapper class for the metadata cache.
     */
	public class cacheFile {
        public String t {get;set;}
        public String n {get;set;}
        public String b {get;set;}
        public String d {get;set;}
        public String cb {get;set;}
        public String cd {get;set;}
        public cacheFile(String t, String n, String b, String d, String cb, String cd){
            this.t = t;
            this.n = n;
            this.b = b;
            this.d = d;
            this.cb = cb;
            this.cd = cd;
        }
	}
}