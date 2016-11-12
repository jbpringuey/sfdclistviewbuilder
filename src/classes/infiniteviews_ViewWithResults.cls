global with sharing class infiniteviews_ViewWithResults {
	infiniteviews_View__c view;
	List<SObject> results;String errorMessage;
    
    public infiniteviews_ViewWithResults(infiniteviews_View__c view, List<SObject> results,String errorMessage) {
        this.view = view;
        this.results = results;
        this.errorMessage = errorMessage;
    }
	
	public List<SObject> getResults() {
		return results;
	}
	
	public infiniteviews_View__c getView() {
		return view;
	}
}