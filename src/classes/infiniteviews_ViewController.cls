/**
* Controller for the application
*/

global with sharing class infiniteviews_ViewController{
    
    //used to create all criterions
    public static Integer[] getAlertIndex() {
        return new Integer[]{1,2,3,4,5,6,7,8,9,10};
    }
    
  /**
    * The application can only run if the users and profile is fully granted with accesss to all objects and fields of Infinite Views.
    **/
    private static Boolean hasAccess(String objectName){
        if(objectName == 'View'){
            Schema.DescribeSObjectResult viewObject = Schema.sObjectType.infiniteviews_View__c;
            Schema.DescribeFieldResult viewObjectId = Schema.sObjectType.infiniteviews_View__c.fields.Id;
            Schema.DescribeFieldResult viewObjectName = Schema.sObjectType.infiniteviews_View__c.fields.Name;
            Schema.DescribeFieldResult viewObjectObject = Schema.sObjectType.infiniteviews_View__c.fields.Object__c;
            Schema.DescribeFieldResult viewObjectLabel = Schema.sObjectType.infiniteviews_View__c.fields.Label__c;
            Schema.DescribeFieldResult viewObjectSecondaryLabel = Schema.sObjectType.infiniteviews_View__c.fields.Secondary_label__c;
            if (
            !viewObject.isAccessible() ||
            !viewObjectId.isAccessible() ||
            !viewObjectName.isAccessible() || 
            !viewObjectObject.isAccessible() || 
            !viewObjectLabel.isAccessible() || 
            !viewObjectSecondaryLabel.isAccessible()||
            
            !viewObject.isCreateable() ||
            !viewObjectName.isCreateable() || 
            !viewObjectObject.isCreateable() || 
            !viewObjectLabel.isCreateable() || 
            !viewObjectSecondaryLabel.isCreateable()||
            
            !viewObject.isUpdateable() ||
            !viewObjectName.isUpdateable() || 
            !viewObjectObject.isUpdateable() || 
            !viewObjectLabel.isUpdateable() || 
            !viewObjectSecondaryLabel.isUpdateable()||
            
            !viewObject.isDeletable()
            ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'You need full Create/Read/Update/Delete access on infiniteviews_View__c to be able to use the application.'));
                return false;
            }
            
        }else if(objectName == 'Criterion'){
        
            Schema.DescribeSObjectResult viewObject = Schema.sObjectType.infiniteviews_Criterion__c;
            Schema.DescribeFieldResult viewObjectId = Schema.sObjectType.infiniteviews_Criterion__c.fields.Id;
            Schema.DescribeFieldResult viewObjectView = Schema.sObjectType.infiniteviews_Criterion__c.fields.View__c;
            Schema.DescribeFieldResult viewObjectAttribute = Schema.sObjectType.infiniteviews_Criterion__c.fields.Attribute__c;
            Schema.DescribeFieldResult viewObjectOperator = Schema.sObjectType.infiniteviews_Criterion__c.fields.Operator__c;
            Schema.DescribeFieldResult viewObjectValue = Schema.sObjectType.infiniteviews_Criterion__c.fields.Value__c;
            Schema.DescribeFieldResult viewObjectFilterFieldType = Schema.sObjectType.infiniteviews_Criterion__c.fields.Filter_field_type__c;
            Schema.DescribeFieldResult viewObjectObjectName = Schema.sObjectType.infiniteviews_Criterion__c.fields.ObjectName__c;
            if (
                !viewObject.isAccessible() ||
                !viewObjectId.isAccessible() ||
                !viewObjectView.isAccessible() || 
                !viewObjectAttribute.isAccessible() || 
                !viewObjectOperator.isAccessible() || 
                !viewObjectValue.isAccessible()||
                !viewObjectFilterFieldType.isAccessible()||
                !viewObjectObjectName.isAccessible()||
                
                !viewObject.isCreateable() ||
                !viewObjectView.isCreateable() || 
                !viewObjectAttribute.isCreateable() || 
                !viewObjectOperator.isCreateable() || 
                !viewObjectValue.isCreateable()||
                !viewObjectFilterFieldType.isCreateable()||
                !viewObjectObjectName.isCreateable()||
                
                !viewObject.isUpdateable() ||
                !viewObjectView.isUpdateable() || 
                !viewObjectAttribute.isUpdateable() || 
                !viewObjectOperator.isUpdateable() || 
                !viewObjectValue.isUpdateable()||
                !viewObjectFilterFieldType.isUpdateable()||
                !viewObjectObjectName.isUpdateable() ||
                
                !viewObject.isDeletable()
                ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'You need full Create/Read/Update/Delete access on infiniteviews_Criterion__c to be able to use the application.'));
                return false;
            }
        }
        return true;
    }


    @RemoteAction
    global static List<infiniteviews_View__c> getAlerts(){
    	// Check if the user has create select access on infiniteviews_View__c
		if(!hasAccess( 'View')){
			return new List<infiniteviews_View__c>();
		}
    	return [select Id, Name, Object__c, Label__c, Secondary_label__c from infiniteviews_View__c where Owner.Id=:UserInfo.getUserId() order by Name];
    }
    
    @RemoteAction
    global static infiniteviews_View__c getAlert(Id viewId){
    	// Check if the user has create select access on infiniteviews_View__c
    	if(!hasAccess( 'View')){
			return null;
		}
        Set<Id> viewIds = new Set<Id>{viewId};
        return [select Id, Name, Object__c, Label__c, Secondary_label__c from infiniteviews_View__c where Id in :viewIds].get(0);
    }
    
    @RemoteAction
    global static List<Map<String,String>> getManageAlerts(){
        List<infiniteviews_View__c> views = getAlerts();
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(infiniteviews_View__c view : views){
            Map<String,String> viewMap = new Map<String,String>();
            viewMap.put('Id',view.Id);
            viewMap.put('Name',view.Name);
            viewMap.put('Object__c', view.Object__c);
            results.add(viewMap);
        }
        return results;
    }
    
    /* Method to initialize the edit view page */
    @RemoteAction
    global static List<Map<String,Object>> getInitialCriterions(Id viewId) {
        infiniteviews_View__c view = getAlert(viewId);
        List<infiniteviews_Criterion__c> criterions = getCriterion(viewId);
        List<Map<String,Object>> results = new List<Map<String,Object>>();
        Map<String, Object> sharedAttributes = new Map<String, Object>();
        sharedAttributes.put('objects',getObjects());
        Map<String, List<String>> labels = getAttributes(view.Object__c);
        sharedAttributes.put('view',view);
        sharedAttributes.put('labels', labels);
        results.add(sharedAttributes); 
        for(infiniteviews_Criterion__c criteria : criterions){
            Map<String,Object> criteriaWithDetails = new Map<String,Object>();
            String objectName = criteria.ObjectName__c;
            Map<String, List<String>> attributes = getAttributes(objectName);
            criteriaWithDetails.put('labelattributes',attributes);
            criteriaWithDetails.put('filterattributes',attributes); 
            criteriaWithDetails.put('selectedAttribute',criteria.Attribute__c); 
            criteriaWithDetails.put('selectedOperator',criteria.Operator__c); 
            criteriaWithDetails.put('selectedValue',criteria.Value__c);  
            criteriaWithDetails.put('selectedSubObject',objectName); 
            results.add(criteriaWithDetails);
        }
        return results;

    }
    
    @RemoteAction
    global static List<infiniteviews_Criterion__c> getCriterion(Id viewId) {
        return getCriterions(new Set<Id>{viewId});
    }
    
    @RemoteAction
    global static List<infiniteviews_Criterion__c> getCriterions(Set<Id> viewIds) {
    	// Check if the user has create select access on infiniteviews_Criterion__c
    	if(!hasAccess( 'Criterion')){
			return new List<infiniteviews_Criterion__c>();
		}
        return [select Id,View__c,Attribute__c,Operator__c,Value__c, Filter_field_type__c,ObjectName__c from infiniteviews_Criterion__c where View__c in :viewIds];
    }
    
   /**
    * Key query for the main page
    **/
    @RemoteAction
    global static List<infiniteviews_ViewWithResults> runAlerts() {
        /**
        1 ) Query all views
        2 ) Query all criterions
        2 ) Construct distinct queries and execute
        **/
        //get all views
        List<infiniteviews_View__c> views = getAlerts();
        return runAlerts2(views);
    }
    
    /**
     * For the given view, gives the result key which will will be used in the result map from the query
     * TODO: probably we shouldn't be using names for keys unless we make them unique.
     */
    global static String getResultKey(infiniteviews_View__c view) {
        return view.Name;
    }
    
    // The $UserContext variable doesn't seem to be available or work as expected for values created in apex tests.
    // For that reason I added this indirection, so that tests can pass in the list of views.
    global static List<infiniteviews_ViewWithResults> runAlerts2(List<infiniteviews_View__c> views){
      	if(!hasAccess( 'Criterion') || !hasAccess( 'View')){
			return new List<infiniteviews_ViewWithResults>();
		}
        Set<Id> viewIds = new Set<Id>();
        for(infiniteviews_View__c view : views){
            viewIds.add(view.Id);
        }
        
        //index criterions list by view
        List<infiniteviews_Criterion__c> criterions = getCriterions(viewIds);
        Map<Id,List<infiniteviews_Criterion__c>> criterionByAlertId = new  Map<Id,List<infiniteviews_Criterion__c>>();
        for(infiniteviews_Criterion__c criterion : criterions){
            if(criterionByAlertId.get(criterion.View__c)==null){
                criterionByAlertId.put(criterion.View__c,new List<infiniteviews_Criterion__c>());
            }
            criterionByAlertId.get(criterion.View__c).add(criterion);
        }
        
        List<infiniteviews_Criterion__c> EMPTY_LIST = new List<infiniteviews_Criterion__c>();

        List<infiniteviews_ViewWithResults> results = new List<infiniteviews_ViewWithResults>();
        
        for(infiniteviews_View__c view : views){
            List<infiniteviews_Criterion__c> viewCriterions =  criterionByAlertId.get(view.Id);
            if(viewCriterions == null) {
                viewCriterions = EMPTY_LIST;
            }
            String selectPart = String.escapeSingleQuotes(view.Label__c);
            Boolean secondaryLabelDefined = false;
            if(view.Secondary_label__c!=null && view.Secondary_label__c!=''){
                selectPart = selectPart+','+String.escapeSingleQuotes(view.Secondary_label__c);
                secondaryLabelDefined = true;
            }
            String query = 'Select '+selectPart+' from '+String.escapeSingleQuotes(view.Object__c);
            //FLS & CRUD check
            SObjectType objResult = Schema.getGlobalDescribe().get(view.Object__c);
            if(objResult == null || !objResult.getDescribe().isAccessible() || 
               !objResult.getDescribe().fields.getMap().get(view.Label__c).getDescribe().isAccessible() ||
               (secondaryLabelDefined && !objResult.getDescribe().fields.getMap().get(view.Secondary_label__c).getDescribe().isAccessible())){
                results.add(new infiniteviews_ViewWithResults(view, new List<sObject>(),'No access to object'));
            }else{
            	
	            //Handle multiple value selected for Equal or not Equal to leverage in or not in operator
	            Map<String,List<infiniteviews_Criterion__c>> criterionsIndexedByAttribute = new Map<String,List<infiniteviews_Criterion__c>>();
	            for(infiniteviews_Criterion__c viewCriteria : viewCriterions){
	            	String key = viewCriteria.Attribute__c+viewCriteria.Operator__c;
	            	if(criterionsIndexedByAttribute.get(key)==null){
	            		criterionsIndexedByAttribute.put(key,new List<infiniteviews_Criterion__c>());	
	            	}
	            	criterionsIndexedByAttribute.get(key).add(viewCriteria);
	            }
	            
	            
	            Integer counter = 0;
	            for(String key : criterionsIndexedByAttribute.keySet()){
	                if(counter == 0) {
	                    query = query + ' where ';
	                } else {
	                    query = query + ' and ';
	                }
	                List<infiniteviews_Criterion__c> criterionsForAttribute= criterionsIndexedByAttribute.get(key);
	                infiniteviews_Criterion__c viewCriteria = criterionsForAttribute.get(0);
	                String operator = viewCriteria.Operator__c;
	                String preOperator = ' ';
	                String postOperator = ' ';
	                String criteriaValue = ' ';
	                
	                Integer valueCounter = 0; 
	                for(infiniteviews_Criterion__c criteria :criterionsForAttribute){
                        if(valueCounter != 0) {
                            criteriaValue = criteriaValue + ',';
                        }
                        if( viewCriteria.Filter_field_type__c=='DOUBLE'||
                            viewCriteria.Filter_field_type__c=='INTEGER'||
                            viewCriteria.Filter_field_type__c=='PERCENT'||
                            viewCriteria.Filter_field_type__c=='BOOLEAN'||
                            viewCriteria.Filter_field_type__c=='CURRENCY'
                        ){
                            criteriaValue = criteriaValue+' '+ String.escapeSingleQuotes(criteria.Value__c);
                        }else if( 
                            viewCriteria.Filter_field_type__c=='DATE' ||
                            viewCriteria.Filter_field_type__c=='TIME' ||
                            viewCriteria.Filter_field_type__c=='DATETIME'
                            ){
                            Integer i = integer.valueof(criteria.Value__c);
                            datetime today = datetime.now();
                            today = today.addDays(i);
                            criteriaValue = today.format('yyyy-MM-dd');
                            if(viewCriteria.Filter_field_type__c=='DATETIME'){
                                criteriaValue = criteriaValue + 'T' + today.formatGMT('HH:mm:ss.SSS') + 'Z';
                            }
                        }else{
                            criteriaValue = criteriaValue+' '+'\''+ String.escapeSingleQuotes(criteria.Value__c)+'\'';
                        }
                        valueCounter++;
                    }
	                
	                if(operator=='Equals'){ // TODO: can we use an enum?
	                    operator = ' in (';   
	                    postOperator = ') ';
	                }else if(operator=='Not Equals'){
	                    operator = ' not in ( ';  
	                    postOperator = ' ) '; 
	                }else if(operator=='Less Than'){
	                    operator = ' < ';   
	                }else if(operator=='Greater Than'){
	                    operator = ' > ';   
	                }else if(operator=='Contains'){
	                    operator = ' LIKE ';  
	                    criteriaValue = '\'%'+ String.escapeSingleQuotes(viewCriteria.Value__c)+ '%\''; 
	                }else if(operator=='Not Contains'){
	                    preOperator = ' NOT ';  
	                    operator = ' LIKE '; 
	                    criteriaValue = '\'%'+ String.escapeSingleQuotes(viewCriteria.Value__c)+ '%\''; 
	                }
	                
	                query = query +' ( '+preOperator+ String.escapeSingleQuotes(viewCriteria.Attribute__c) +operator+ criteriaValue+postOperator+' )';
	                counter++;
	            }
	            //limiting to 100 as it is not convenient to look at more than 100 records from a mobile as well as for performance reasons.
	            query = query + ' LIMIT 200 ';
	            List<sObject> objects = new List<sObject>();
	            String errorMessage = null;
	            try{
	                objects = Database.query(query);
	            } catch(Exception e) {
	                //likely related to schema change
	                errorMessage = 'An error occured due to a recent schema changes. Please rebuild your view. ';
	            }
	            results.add(new infiniteviews_ViewWithResults(view, objects,errorMessage));
             }
        }
        
        return results;
       
    }
    
    /**
    * To be used by the edit view page. Watch out for of governance limit on number of fields that can be fetched is 100
    **/
    @RemoteAction
    global static Map<String,String> getObjects(){
        Map<String,String> objects = new Map<String,String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        for(Schema.SObjectType f : gd){
            String name = f.getDescribe().getName();
            if(name != 'infiniteviews_View__c' &&
                name != 'infiniteviews_Criterion__c' &&
                 f.getDescribe().isAccessible()){
                objects.put(f.getDescribe().getLabel(),name);   
            }
        }
        return objects;
   }
   

    @RemoteAction
    global static Boolean deleteAlert(String viewID){
    	//FLS & CRUD check
    	if(!hasAccess( 'Criterion') || !hasAccess( 'View')){
			return false;
		}
        Set<Id> viewIds = new Set<Id>{viewId};
        List<infiniteviews_Criterion__c> criterions = [select Id from infiniteviews_Criterion__c where View__c in :viewIds];
        if(criterions.size() > 0) delete criterions;
        infiniteviews_View__c view = [select Id from infiniteviews_View__c where Id=:viewID];
        delete view;    
        return true;
    }     

    @RemoteAction
    global static void editAlert(List<infiniteviews_View__c> views, List<infiniteviews_Criterion__c> criterions) {
    	//FLS & CRUD check
        if(!hasAccess( 'Criterion') || !hasAccess( 'View')){
			return;
		}
        infiniteviews_View__c view = views.get(0);
        update view;
        Set<Id> viewIds = new Set<Id>{view.id};
        List<infiniteviews_Criterion__c> oldCriterions = [select Id from infiniteviews_Criterion__c where View__c in :viewIds];
        delete oldCriterions;
        for(infiniteviews_Criterion__c criterion : criterions) {
            criterion.View__c = view.id;
        }
        insert criterions;
    }
    
   
    
    @RemoteAction
    global static Id createAlert(List<infiniteviews_View__c> views, List<infiniteviews_Criterion__c> criterions) {
    	//FLS & CRUD check
        if(!hasAccess( 'Criterion') || !hasAccess( 'View')){
			return null;
		}
        infiniteviews_View__c view = views.get(0);
        insert view;
        for(infiniteviews_Criterion__c criterion : criterions) {
            criterion.View__c = view.id;
        }
        insert criterions;
        return view.id;
    }

   

    @RemoteAction
    global static Map<String, List<String>> getAttributes(String objectName){
        SObjectType obj = Schema.getGlobalDescribe().get(objectName);
        Map<String, List<String>> filtertedFields = new Map<String, List<String>>();
        Map<String, SObjectField> fieldsMap = obj.getDescribe().fields.getMap();

        for(String field : fieldsMap.keySet()){
            if(field == 'Id') continue;
            DescribeFieldResult selectedField = fieldsMap.get(field).getDescribe();
            //FLS & CRUD check
            if( selectedField.isFilterable()  && selectedField.isAccessible() ){
                List<String> values = new List<String>();
                values.add(field);
                String type = selectedField.getType().name().toUpperCase();
                values.add(type);
                //important for governance limit
                if(type == 'PICKLIST'){
                    //handle picklist values
                    List<Schema.PicklistEntry> ple = selectedField.getPicklistValues();
                    if(ple!=null){
                        for(Schema.PicklistEntry f : ple){
                          values.add(f.getValue());
                        }
                    }
                }
                //important for governance limit
                if(type == 'REFERENCE'){
                    //set relationship name
                    values.set(0,selectedField.getRelationshipName());
                    //handle lookups
                    List<Schema.sObjectType> references = selectedField.getReferenceTo();
                    if(references!=null){
                        for(Schema.sObjectType f : references){
                          values.add(f.getDescribe().getName());
                        }
                    }
                }
                filtertedFields.put(selectedField.getLabel(),values);
            }
        }
        return filtertedFields;
   }

}