@IsTest
private class TestDataFactory_Test {
    
    @IsTest
    static void itShouldMakeObject() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName).create();

        List<Account> acct = (List<Account>) tdf.objs;
        Test.stopTest();

        // when
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isFalse(acct.isEmpty(), 'Result shouldn\'t be empty');
        Assert.isNotNull(acct[0].Name, 'Account Name is required');
    }

    @IsTest
    static void itShouldMakeObjects() {
        // given
        String sObjectApiName = 'Account';
        Integer count = 10;

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName)
            .count(count)
            .create();

        List<Account> accts = (List<Account>) tdf.objs;
        Test.stopTest();

        // when
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isNotNull(accts, 'Result shouldn\'t be null');

        for (Account acct : accts) {
            Assert.isNotNull(acct.Name, 'Account Name is required');
        }
    }

    @IsTest
    static void itShouldThrowExceptionWithField() {
        // given
        String sObjectApiName = 'Account';
        String name = 'Website';
        String value = 'https://www.salesforce.com/';

        // when
        Test.startTest();
        TestDataFactoryException ex;
        try {
            TestDataFactory tdf = new TestDataFactory(sObjectApiName).withField(name, value);            
        } catch (TestDataFactoryException thrownEx) {
            ex = thrownEx;
        }

        Test.stopTest();

        // then
        String message = 'Object must be created before specifiying fields';
        Assert.isTrue(ex.getMessage() == message, 'Exception was expected');
    }

    @IsTest
    static void itShouldMakeWithFields() {
        // given
        String sObjectApiName = 'Account';
        String name = 'Website';
        String value = 'https://www.salesforce.com/';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName)
            .create()
            .withField(name, value);

        List<Account> acct = (List<Account>) tdf.objs;
        Test.stopTest();

        // then
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isFalse(acct.isEmpty(), 'Result shouldn\'t be empty');
        Assert.isNotNull(acct[0].Name, 'Account Name is required');
        Assert.areEqual(value, acct[0].Website, 'Website should be the specified');
    }

    @IsTest
    static void itShouldMakeCountWithFields() {
        // given
        String sObjectApiName = 'Account';
        String name = 'Website';
        String value = 'https://www.salesforce.com/';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName)
            .count(2)
            .create()
            .withField(name, value);

        List<Account> accts = (List<Account>) tdf.objs;
        Test.stopTest();

        // then
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isNotNull(accts, 'Result shouldn\'t be null');

        for (Account acct : accts) {
            Assert.isNotNull(acct.Name, 'Account Name is required');
            Assert.areEqual(value, acct.Website, 'Website should be the specified');            
        }
    }

    @IsTest
    static void itShouldMakeWithRecordType() {
        List<RecordType> rt = [SELECT Id, SObjectType, DeveloperName FROM RecordType];

        if (!rt.isEmpty()) {
            // given
            String sObjectApiName = rt[0].SObjectType;
            String rtDevName = rt[0].DeveloperName;

            // when
            Test.startTest();
            TestDataFactory tdf = new TestDataFactory(sObjectApiName)
                .recordType(rtDevName)
                .create();

            List<SObject> obj = tdf.objs;
            Test.stopTest();

            // then
            List<SObject> persistedObjs = Database.query('SELECT Id, RecordTypeId FROM ' + sObjectApiName);

            Assert.isTrue(persistedObjs.isEmpty(), 'No data should\'ve ben inserted');
            Assert.isFalse(obj.isEmpty(), 'Result shouldn\'t be empty');
            Assert.areEqual(rt[0].Id, obj[0].get('RecordTypeId'), 'Result should be successfull');
        }
    }

    @IsTest
    static void itShouldMakeWithRecordTypeCount() {
        List<RecordType> rt = [SELECT Id, SObjectType, DeveloperName FROM RecordType];

        if (!rt.isEmpty()) {
            // given
            String sObjectApiName = rt[0].SObjectType;
            String rtDevName = rt[0].DeveloperName;
            Integer count = 10;

            // when
            Test.startTest();
            TestDataFactory tdf = new TestDataFactory(sObjectApiName)
                .recordType(rtDevName)
                .count(count)
                .create();

            List<SObject> objs = tdf.objs;
            Test.stopTest();

            // then
            List<SObject> persistedObjs = Database.query('SELECT Id, RecordTypeId FROM ' + sObjectApiName);

            Assert.isTrue(persistedObjs.isEmpty(), 'No data should\'ve ben inserted');
            Assert.areEqual(count, objs.size());
            Assert.isNotNull(objs, 'Result shouldn\'t be null');

            for (SObject obj : objs) {
                Assert.areEqual(rt[0].Id, obj.get('RecordTypeId'), 'Result should be successfull');
            }
        }
    }

    @IsTest
    static void itShouldInsertData() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();        
        try {
            TestDataFactory tdf = new TestDataFactory(sObjectApiName)
                .create()
                .insertData();
        } catch (TestDataFactoryException ex) {
            // Tried to insert a record with a bad value for restricted picklist.
            return;
        }
        Test.stopTest();

        // then
        List<Account> result = [SELECT Id FROM Account];
        Assert.isNotNull(result, 'Result shouldn\'t be null');
        Assert.isFalse(result.isEmpty(), 'result should contain records');
        Assert.areEqual(1, result.size(), 'Result have 1 Account record');
    }

    @IsTest
    static void itShouldInsertDataCount() {
        // given
        String sObjectApiName = 'Account';
        Integer count = 10;

        // when
        Test.startTest();
        try {
            TestDataFactory tdf = new TestDataFactory(sObjectApiName)
                .count(count)
                .create()
                .insertData();
        } catch (TestDataFactoryException ex) {
            // Tried to insert a record with a bad value for restricted picklist.
            return;
        }
        Test.stopTest();

        // then
        List<Account> result = [SELECT Id FROM Account];
        Assert.isNotNull(result, 'Result shouldn\'t be null');
        Assert.isFalse(result.isEmpty(), 'result should contain records');
        Assert.areEqual(10, result.size(), 'Result have 1 Account record');
    }

    @IsTest 
    static void itShouldCreateSObjectInstance() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName);
        SObject obj = tdf.createSObjectInstance();
        Test.stopTest();

        // then
        Assert.isNotNull(obj, 'Object instance shouldn\'t be null');
        Assert.isTrue(obj instanceof Account, 'Should be an instance of Account');
    }

    @IsTest
    static void itShouldReturnRequiredFields() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName);
        Map<String, Schema.SObjectField> rf = tdf.getRequiredFields(sObjectApiName);
        Test.stopTest();

        // then
        Assert.isNotNull(rf, 'Required fields shouldn\'t be null');
        Assert.isFalse(rf.keySet().isEmpty(), 'There should be at least 1 required field');
    }

    @IsTest
    static void itShouldPopulateRequiredFields() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName);
        SObject obj = tdf.createSObjectInstance();
        tdf.populateRequiredFields(tdf.getRequiredFields(sObjectApiName), obj);
        Account acct = (Account) obj; 
        Test.stopTest();

        // then
        Assert.isNotNull(acct, 'SObject shouldn\'t be null');
        Assert.isNotNull(acct.Name, 'Required field Name shouldn\'t be null');
    }

    @IsTest
    static void itShouldPopulatePicklistField() {
        // given
        String sObjectApiName = 'Account';
        Map<String, Schema.SObjectField> pickListMap = new Map<String, Schema.SObjectField>();
        pickListMap.put('type', Schema.SObjectType.Account.fields.getMap().get('type'));

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory(sObjectApiName);
        SObject obj = tdf.createSObjectInstance();
        tdf.populateRequiredFields(pickListMap, obj);
        Account acct = (Account) obj; 
        Test.stopTest();

        // then
        Assert.isNotNull(acct, 'SObject shouldn\'t be null');
        Assert.isNotNull(acct.Type, 'Required field Name shouldn\'t be null');
    }

    @IsTest
    static void itShouldGetRandomTextFieldValue() {
        // given
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('name');

        // when
        Test.startTest();
        String value = TestDataFactory.getRandomStringValue(field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Field value shouldn\'t be null');
        Assert.isTrue(value.length() > 0, 'Field value length should be more than 0');
    }
    
    @IsTest
    static void itShouldGetRandomEmail() {
        // when
        Test.startTest();
        String value = TestDataFactory.getRandomEmail();
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Email value shouldn\'t be null');
        Assert.isTrue(value.length() > 0, 'Email value length should be more than 0');
    }

    @IsTest
    static void itShouldGetRandomDecimalFieldValue() {
        // given
        Schema.SObjectField field = Schema.SObjectType.Opportunity.fields.getMap().get('Amount');
        Integer precision = field.getDescribe().getPrecision();
        Integer scale = field.getDescribe().getScale();

        // when
        Test.startTest();
        Double value = TestDataFactory.getRandomDouble(field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Field value shouldn\'t be null');
        
        Integer integerDigits = (Integer) String.valueOf(value.longValue()).length();
        Assert.areEqual(scale, (precision - integerDigits), 'Amount should have ' + scale + ' decimal digits');
        Assert.areEqual((precision - scale), integerDigits, 'Amount max integer digits should be ' + (precision - scale));
    }

    @IsTest
    static void itShouldGetRandomIntegerFieldValue() {
        // given
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('NumberOfEmployees');
        Integer digits = field.getDescribe().getDigits();
        Integer scale = field.getDescribe().getScale();

        // when
        Test.startTest();
        Double value = TestDataFactory.getRandomDouble(field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Field value shouldn\'t be null');
        
        Integer integerDigits = (Integer) String.valueOf(value.longValue()).length();
        Assert.areEqual(digits, integerDigits, 'NumberOfEmployees max integer digits should be ' + digits);
        Assert.areEqual(scale, (digits - integerDigits), 'NumberOfEmployees should have ' + scale + ' decimal digits');
    }

    @IsTest
    static void itShouldGetRandomPicklistValue() {
        // given
        String fieldName = 'Type';
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get(fieldName);
        List<Schema.PicklistEntry> allowedEntries = field.getDescribe().getPicklistValues();

        List<String> allowedValues = new List<String>();
        for (Schema.PicklistEntry entry : allowedEntries) {
            allowedValues.add(entry.getValue());
        }

        // when
        Test.startTest();
        String value = TestDataFactory.getRandomPicklistValue(field.getDescribe().getPicklistValues());
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isTrue(allowedValues.contains(value), 'Random value should belong to the picklist values');
    }

    @IsTest
    static void itShouldGetFieldStringValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.STRING;
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('name');

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type, field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }

    @IsTest
    static void itShouldGetFieldCurrencyValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.CURRENCY;
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('annualrevenue');

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type, field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Double.class, 'Value should be an instance of Double');
    }

    @IsTest
    static void itShouldGetFieldDateValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.DATE;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Date.class, 'Value should be an instance of Date');
    }

    @IsTest
    static void itShouldGetFieldDatetimeValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.DATETIME;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Datetime.class, 'Value should be an instance of Datetime');
    }

    @IsTest
    static void itShouldGetFieldEmailValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.EMAIL;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }

    @IsTest
    static void itShouldGetFieldLocationValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.LOCATION;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Location.class, 'Value should be an instance of Location');
    }

    @IsTest
    static void itShouldPopulatePicklistValue() {
        // given
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('type');

        // when
        Test.startTest();
        Account obj = new Account(Name = 'Test');
        TestDataFactory.handlePopulatePicklist(field, obj);
        Test.stopTest();

        // then
        Assert.isNotNull(obj.get('type'), 'type shouldn\'t be null');
    }

    @IsTest
    static void itShouldGetFieldTextAreaValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.TEXTAREA;
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('description');

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type, field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }

    @IsTest
    static void itShouldGetFieldPhoneValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.PHONE;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }

    
    @IsTest
    static void itShouldGetFieldTimeValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.TIME;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Time.class, 'Value should be an instance of Time');
    }

    @IsTest
    static void itShouldGetFieldUrlValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.URL;

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }
    
    @IsTest
    static void itShouldGetFieldAnyValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.EMAIL;
        Schema.SObjectField field = Schema.SObjectType.Contact.fields.getMap().get('Email');

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type, field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, String.class, 'Value should be an instance of String');
    }

    @IsTest
    static void itShouldCatchFieldIntegrityExceptionMsg() {
        // given
        Account acct = new Account(Name = 'Test', CleanStatus = 'SelectMatch');
        TestDataFactoryException tdfEx = new TestDataFactoryException();

        // when
        Test.startTest();
        try {
            insert acct;
        } catch (DmlException ex) {
            tdfEx = new TestDataFactoryException(ex);
        }

        // then
        String msg = 'Insert failed, the provided value for field (CleanStatus) is not valid for this record';
        Assert.areEqual(msg, tdfEx.getMessage());
    }

    @IsTest
    static void itShouldCatchRestricktedPicklistExceptionMsg() {
        // given
        Account acct = new Account(Name = 'Test', CleanStatus = 'BadValue');
        TestDataFactoryException tdfEx = new TestDataFactoryException();

        // when
        Test.startTest();
        try {
            insert acct;
        } catch (DmlException ex) {
            tdfEx = new TestDataFactoryException(ex);
        }

        // then
        String msg = 'Insert failed, (CleanStatus) has restricted values by Record Type. Please use withField method';
        Assert.areEqual(msg, tdfEx.getMessage());
    }

    // Uncomment this in case your org has a Percent field and modify accordingly. 
    @IsTest
    static void itShouldGetFieldPercentValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.PERCENT;
        // Modify this line according to your Object and Field
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('YOUR_PERCENT_FIELD__c');

        // when
        Test.startTest();
        Object value = TestDataFactory.getFieldValue(type, field);
        Test.stopTest();

        // then
        Assert.isNotNull(value, 'Value shouldn\'t be null');
        Assert.isInstanceOfType(value, Double.class, 'Value should be an instance of Double');
    }


    // Uncomment this in case your org has a Multipicklist field and modify accordingly. 
    @IsTest
    static void itShouldPopulateMultipicklistValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.MULTIPICKLIST;
        // Modify this line according to your Object and Field
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('YOUR_MULTIPICKLIST_FIELD__c');

        // when
        Test.startTest();
        Account obj = new Account(Name = 'Test');
        TestDataFactory.handlePopulatePicklist(field, obj);
        Test.stopTest();

        // then
        Assert.isNotNull(obj.get('YOUR_MULTIPICKLIST_FIELD__c'), 'YOUR_MULTIPICKLIST_FIELD__c shouldn\'t be null');
    }

    // Uncomment this in case your org has dependent picklists and modify accordingly
    @IsTest
    static void itShouldPopulatePicklistFieldWithDependencies() {
        // given
        String dependantName = 'YOUR_DEPENDANT_FIELD__c';
        String controllerName = 'Type';
        Schema.SObjectField dependantField = Schema.SObjectType.Account.fields.getMap().get(dependantName);

        // when
        Test.startTest();
        Account obj = new Account(Name = 'Test');
        TestDataFactory.populatePicklistFieldWithDependencies(dependantField, obj);

        Test.stopTest();

        // then
        Assert.isNotNull(obj.get(dependantName), 'YOUR_DEPENDANT_FIELD__c shouldn\'t be null');
        Assert.isNotNull(obj.get(controllerName), 'controllerName shouldn\'t be null');
    }

    @IsTest
    static void itShouldInsertRecordWithChild() {
        // given
        String parentName = 'Account';
        String childName = 'Opportunity';

        // when
        Test.startTest();
        try {
            TestDataFactory tdf = new TestDataFactory(parentName)
                .create()
                .insertData()
                .withChild(childName)
                .withChildCount(1)
                .createChildren()
                .insertChildren();
        } catch (TestDataFactoryException ex) {
            // Tried to insert a record with a bad value for restricted picklist.
            return;
        }
        Test.stopTest();

        // then
        List<Account> result = [SELECT Id, (SELECT Id FROM Opportunities) FROM Account];
        
        Assert.isNotNull(result, 'Result shouldn\'t be null');
        Assert.isFalse(result.isEmpty(), 'result should contain records');
        Assert.areEqual(1, result.size(), 'Result have 1 Account record');

        Assert.isNotNull(result[0].Opportunities, 'Result shouldn\'t be null');
        Assert.isFalse(result[0].Opportunities.isEmpty(), 'result should contain Opportunities');
        Assert.areEqual(1, result[0].Opportunities.size(), 'Result have 1 Account record');
    }

    @IsTest
    static void itShouldThrowOrphanRecordException() {
        // given
        String parentName = 'Account';
        String childName = 'Opportunity';

        // when
        Test.startTest();
        TestDataFactoryException ex;
        try {
            TestDataFactory tdf = new TestDataFactory(parentName)
                .create()
                .withChild(childName)
                .withChildCount(1)
                .createChildren()
                .insertChildren();
        } catch (TestDataFactoryException thrownEx) {
            ex = thrownEx;
        }
        Test.stopTest();

        // then
        String message = 'Can\'t insert orphan records';
        Assert.isNotNull(ex, 'Exception was expected');
        Assert.isTrue(ex.getMessage() == message, 'Orphan records Exception was expected');
    }

    @IsTest
    static void itShouldThrowChildNameException() {
        // given
        String parentName = 'Account';
        String childName = 'Opportunity';

        // when
        Test.startTest();
        TestDataFactoryException ex;
        try {
            TestDataFactory tdf = new TestDataFactory(parentName)
                .create()
                .insertData()
                .withChildCount(1)
                .createChildren()
                .insertChildren();
        } catch (TestDataFactoryException thrownEx) {
            ex = thrownEx;
        }
        Test.stopTest();

        // then
        String message = 'Specify the child record API name';
        Assert.isNotNull(ex, 'Exception was expected');
        Assert.isTrue(ex.getMessage() == message, 'Child name Exception was expected');
    }
}