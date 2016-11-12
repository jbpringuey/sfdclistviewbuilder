/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@isTest
private class infiniteviews_ViewControllerTest {

    static testMethod void testGetManageAlerts() {
        List<infiniteviews_View__c> views = [select id from infiniteviews_View__c];
        List<Map<String,String>> viewMaps = infiniteviews_ViewController.getManageAlerts();
        System.assertEquals(views.size(), viewMaps.size());
            
    }
    
    static List<infiniteviews_View__c> getAlerts() {
        return [select id from infiniteviews_View__c];
    }
    
    static infiniteviews_View__c createAlert(String name) {
        infiniteviews_View__c view = new infiniteviews_View__c(Name=name, Object__c='dontcare', Label__c='dontcare',Secondary_label__c='dontcare');
        insert view;
        
        System.assert(view.id != null);
        return view;
    }
    
    static testMethod void testGetInitialCriterions() {
        infiniteviews_View__c view = new infiniteviews_View__c(Name='test get initial criterions', Object__c='Account', Label__c='Name');
        insert view;
        
        infiniteviews_Criterion__c numberEqualsCriterion = new infiniteviews_Criterion__c(
        Filter_field_type__c='INTEGER',
        Operator__c='Equals',
        ObjectName__c='Account',
        Value__c='42',
        Attribute__c='numberofemployees',
        View__c=view.id);
        insert numberEqualsCriterion;
        
        List<Map<String,Object>> initialCriterions = infiniteviews_ViewController.getInitialCriterions(view.id);
        System.assertEquals(2, initialCriterions.size());
        System.assert(initialCriterions.get(0).containsKey('view')); // TODO: need to 
    }
    
    static testMethod void testRunAlerts() {
        infiniteviews_ViewController.runAlerts(); // it isn't really possible to use this method to do work because the user context doesn't seem to be usable in apex tests
        infiniteviews_View__c view = new infiniteviews_View__c(Name='test run view', Object__c='contact', Label__c='name');
        insert view;
        
        infiniteviews_Criterion__c criterion = getCriterion();
        criterion.Operator__c = 'Equals';
        criterion.Value__c = 'true';
        criterion.Filter_field_type__c = 'BOOLEAN';
        criterion.Attribute__c = 'DoNotCall';
        criterion.View__c = view.id;
        
        insert criterion;
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(view);
        List<infiniteviews_ViewWithResults> results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.size());
        System.assertEquals(0, results.get(0).getResults().size());
        
    }
    
    static testMethod void testGetIndex() {
        System.assert(infiniteviews_ViewController.getAlertIndex().size()>0);
    }
    
    static testMethod void testGetObjects() {
        System.assert(infiniteviews_ViewController.getObjects().size()>0);
    }

    private static String getResultKey(infiniteviews_View__c view) {
        return infiniteviews_ViewController.getResultKey(view); 
    }
    
    static testMethod void testAlertWithNoCriteria() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='Jean-Baptiste'));
        accounts.add(new Account(Name='Nate'));
        insert accounts;
        
        infiniteviews_View__c view = new infiniteviews_View__c(Name='test view with no criteria', Object__c='account', Label__c='name');
        insert view;
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(view);
        List<infiniteviews_ViewWithResults> results = infiniteviews_ViewController.runAlerts2(views);
        
        System.assertEquals(2, results.get(0).getResults().size());
    }
    
    static testMethod void testExclusions() {
        
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='Jean-Baptiste'));
        accounts.add(new Account(Name='Nate'));
        accounts.add(new Account(Name='filtered out by criterion'));
        
        insert accounts;
        
        infiniteviews_View__c view = new infiniteviews_View__c(Name='test exclusions account', Object__c='account', Label__c='name');
        insert view;
        
        infiniteviews_Criterion__c criterion = getCriterion();
        
        criterion.Filter_field_type__c = 'STRING';
        criterion.Operator__c = 'Not Contains';
        criterion.Value__c = 'out';
        criterion.Attribute__c = 'name';
        criterion.View__c = view.id;
        
        insert criterion;
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(view);
        
        // The view should have 2 matching results
        infiniteviews_ViewController.runAlerts2(views);
        List<infiniteviews_ViewWithResults> viewResult = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(2, viewResult.get(0).getResults().size());
        
    }
    
    static testMethod void testDeleteAlert() {
        System.assertEquals(0, getAlerts().size());
        infiniteviews_View__c view = createAlert('delete me');
        System.assertEquals(1, getAlerts().size());
        infiniteviews_ViewController.deleteAlert(view.id);
        System.assertEquals(0, infiniteviews_ViewController.getAlerts().size());
    }
    
    static testMethod void testGetAttributes() {
        Map<String, List<String>> attributes = infiniteviews_ViewController.getAttributes('Account');
        System.assert(attributes != null);
        List<String> nameField = attributes.get('Account Name');
        System.assert(nameField != null);
        System.assertEquals(nameField.get(0), 'name');
        System.assertEquals(nameField.get(1), 'STRING');
    }
    
    private static infiniteviews_Criterion__c getCriterion() {
        infiniteviews_Criterion__c criterion = new infiniteviews_Criterion__c(
            Attribute__c = 'dontcare', Operator__c = 'dontcare', Value__c = 'dontcare', Filter_field_type__c = 'dontcare');
        
        return criterion;
    }
    
    private static infiniteviews_View__c getAccountAlert(String name) {
        return new infiniteviews_View__c(Name=name, Object__c='Account', Label__c='Name');
    }
    
    static testMethod void testEqualsOperator() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='equals')); // String
        accounts.add(new Account(Name='equals', NumberOfEmployees=42));
        accounts.add(new Account(Name='doesnt match'));
        insert accounts;
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(getAccountAlert('test equals operator'));
        insert views;
        
        infiniteviews_Criterion__c criterion = new infiniteviews_Criterion__c(Filter_field_type__c='STRING',
            Operator__c='Equals',
            Value__c='equals',
            Attribute__c='name',
            View__c=views.get(0).id);
            
        insert criterion;
        
        List<infiniteviews_ViewWithResults> results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(2, results.get(0).getResults().size());
        
        infiniteviews_Criterion__c numberEqualsCriterion = new infiniteviews_Criterion__c(
        Filter_field_type__c='INTEGER',
        Operator__c='Equals',
        Value__c='42',
        Attribute__c='numberofemployees',
        View__c=views.get(0).id);
        insert numberEqualsCriterion;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
        
        infiniteviews_Criterion__c numberLessThanCriterion = new infiniteviews_Criterion__c(
        Filter_field_type__c='INTEGER',
        Operator__c='Less Than',
        Value__c='43',
        Attribute__c='numberofemployees',
        View__c=views.get(0).id);
        insert numberLessThanCriterion;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
        
        infiniteviews_Criterion__c greaterLessThanCriterion = new infiniteviews_Criterion__c(
        Filter_field_type__c='INTEGER',
        Operator__c='Greater Than',
        Value__c='39',
        Attribute__c='numberofemployees',
        View__c=views.get(0).id);
        insert greaterLessThanCriterion;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
        
        infiniteviews_Criterion__c criterionContains = new infiniteviews_Criterion__c(Filter_field_type__c='STRING',
            Operator__c='Contains',
            Value__c='equals',
            Attribute__c='name',
            View__c=views.get(0).id);
            
        insert criterionContains;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
        
        
        infiniteviews_Criterion__c criterionDate = new infiniteviews_Criterion__c(Filter_field_type__c='DATETIME',
            Operator__c='Less Than',
            Value__c='100',
            Attribute__c='CreatedDate',
            View__c=views.get(0).id);
            
        insert criterionDate;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
       
        
    }
    
        static testMethod void testNotEqualsOperator() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='equals')); // String
        accounts.add(new Account(Name='equals', NumberOfEmployees=42));
        accounts.add(new Account(name='doesnt match', NumberOfEmployees=42));
        accounts.add(new Account(Name='doesnt match', NumberOfEmployees=22));
        insert accounts;
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(getAccountAlert('test equals operator'));
        insert views;
        
        infiniteviews_Criterion__c criterion = new infiniteviews_Criterion__c(Filter_field_type__c='STRING',
            Operator__c='Not Equals',
            Value__c='equals',
            Attribute__c='name',
            View__c=views.get(0).id);
            
        insert criterion;
        
        List<infiniteviews_ViewWithResults> results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(2, results.get(0).getResults().size());
        
        infiniteviews_Criterion__c numberEqualsCriterion = new infiniteviews_Criterion__c(
            Filter_field_type__c='INTEGER',
            Operator__c='Not Equals',
            Value__c='42',
            Attribute__c='numberofemployees',
            View__c=views.get(0).id);
            
        insert numberEqualsCriterion;
        
        results = infiniteviews_ViewController.runAlerts2(views);
        System.assertEquals(1, results.get(0).getResults().size());
    }

    
    static testMethod void testCreateAlert2() {
        infiniteviews_View__c view = getAccountAlert('test createAlert2');
        List<infiniteviews_Criterion__c> criterions = new List<infiniteviews_Criterion__c>();
        criterions.add(getCriterion());
        criterions.add(getCriterion());
        
        List<infiniteviews_View__c> views = new List<infiniteviews_View__c>();
        views.add(view);
        Id viewId = infiniteviews_ViewController.createAlert(views, criterions);
        
        List<infiniteviews_Criterion__c> insertedCriterions = [select Id from infiniteviews_Criterion__c where View__c = :viewId];
        System.assertEquals(2, insertedCriterions.size());
    }
    
    static testMethod void testEditAlert2() {
        infiniteviews_View__c view = createAlert('update me');
    
        infiniteviews_Criterion__c criterion = getCriterion();
        criterion.View__c = view.id;
        insert criterion;
        
        view.Name = 'updated view name';
        criterion.Attribute__c = 'updated attribute';
        criterion.Id = null;
        List<infiniteviews_Criterion__c> criterionsToUpdate = new List<infiniteviews_Criterion__c>();
        criterionsToUpdate.add(criterion);
        List<infiniteviews_View__c> viewsToUpdate = new List<infiniteviews_View__c>();
        viewsToUpdate.add(view);
        infiniteviews_ViewController.editAlert(viewsToUpdate, criterionsToUpdate);
        
        List<infiniteviews_Criterion__c> updatedCriterions = [select id, Attribute__c from infiniteviews_Criterion__c where View__c = :view.id];
        System.assertEquals(1, updatedCriterions.size());
    }
}