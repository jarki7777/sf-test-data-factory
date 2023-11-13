@IsTest
private class TestDataFactory_Test {
    
    @IsTest
    static void itShouldMakeObject() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
        tdf.make(sObjectApiName);
        Account acct = (Account) tdf.obj;
        Test.stopTest();

        // when
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isNotNull(acct, 'Result shouldn\'t be null');
        Assert.isNotNull(acct.Name, 'Account Name is required');
    }

    @IsTest
    static void itShouldMakeObjects() {
        // given
        String sObjectApiName = 'Account';
        Integer count = 10;

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
        tdf.make(sObjectApiName, count);
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
    static void itShouldMakeWithFields() {
        // given
        String sObjectApiName = 'Account';
        String name = 'Website';
        String value = 'https://www.salesforce.com/';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
        tdf.make(sObjectApiName)
            .withField(name, value);
        Account acct = (Account) tdf.obj;
        Test.stopTest();

        // then
        List<Account> persistedAccts = [SELECT Id FROM Account];

        Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
        Assert.isNotNull(acct, 'Result shouldn\'t be null');
        Assert.isNotNull(acct.Name, 'Account Name is required');
        Assert.areEqual(value, acct.Website, 'Website should be the specified');
    }

    @IsTest
    static void itShouldMakeCountWithFields() {
        // given
        String sObjectApiName = 'Account';
        String name = 'Website';
        String value = 'https://www.salesforce.com/';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
        tdf.make(sObjectApiName, 10)
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
            TestDataFactory tdf = new TestDataFactory();
            tdf.make(sObjectApiName, rtDevName);
            SObject obj = tdf.obj;
            Test.stopTest();

            // then
            List<Account> persistedAccts = Database.query('SELECT Id, RecordTypeId FROM ' + sObjectApiName);

            Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
            Assert.isNotNull(obj, 'Result shouldn\'t be null');
            Assert.areEqual(rt[0].Id, obj.get('RecordTypeId'), 'Result should be successfull');
        }
    }

    @IsTest
    static void itShouldMakeWithRecordTypeCount() {
        List<RecordType> rt = [SELECT Id, SObjectType, DeveloperName FROM RecordType LIMIT 1];

        if (!rt.isEmpty()) {
            // given
            String sObjectApiName = rt[0].SObjectType;
            String rtDevName = rt[0].DeveloperName;
            Integer count = 10;

            // when
            Test.startTest();
            TestDataFactory tdf = new TestDataFactory();
            tdf.make(sObjectApiName, rtDevName, count);
            List<SObject> objs = tdf.objs;
            Test.stopTest();

            // then
            List<Account> persistedAccts = Database.query('SELECT Id, RecordTypeId FROM ' + sObjectApiName);

            Assert.isTrue(persistedAccts.isEmpty(), 'No data should\'ve ben inserted');
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
        TestDataFactory tdf = new TestDataFactory();
        try {
            tdf.make(sObjectApiName).insertData();
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
        TestDataFactory tdf = new TestDataFactory();
        try {
            tdf.make(sObjectApiName, 10).insertData();
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
        TestDataFactory tdf = new TestDataFactory();
        tdf.createSObjectInstance(sObjectApiName);
        SObject o = tdf.obj;
        Test.stopTest();

        // then
        Assert.isNotNull(o, 'Object instance shouldn\'t be null');
        Assert.isTrue(o instanceof Account, 'Should be an instance of Account');
    }

    @IsTest
    static void itShouldReturnRequiredFields() {
        // given
        String sObjectApiName = 'Account';

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
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
        TestDataFactory tdf = new TestDataFactory();
        tdf.createSObjectInstance(sObjectApiName);
        tdf.populateRequiredFields(tdf.getRequiredFields(sObjectApiName));
        Account acct = (Account) tdf.obj; 
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
        TestDataFactory tdf = new TestDataFactory();
        tdf.createSObjectInstance(sObjectApiName);
        tdf.populateRequiredFields(pickListMap);
        Account acct = (Account) tdf.obj; 
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type, field);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type, field);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        tdf.obj = new Account(Name = 'Test');
        tdf.handlePopulatePicklist(field);
        Test.stopTest();

        // then
        Assert.isNotNull(tdf.obj.get('type'), 'type shouldn\'t be null');
    }

    @IsTest
    static void itShouldGetFieldTextAreaValue() {
        // given
        Schema.DisplayType type = Schema.DisplayType.TEXTAREA;
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('description');

        // when
        Test.startTest();
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type, field);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type);
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
        TestDataFactory tdf = new TestDataFactory();
        Object value = tdf.getFieldValue(type, field);
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
    // @IsTest
    // static void itShouldGetFieldPercentValue() {
    //     // given
    //     Schema.DisplayType type = Schema.DisplayType.PERCENT;
    //     // Modify this line according to your Object and Field
    //     Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('YOUR_PERCENT_FIELD__c');

    //     // when
    //     Test.startTest();
    //     TestDataFactory tdf = new TestDataFactory();
    //     Object value = tdf.getFieldValue(type, field);
    //     Test.stopTest();

    //     // then
    //     Assert.isNotNull(value, 'Value shouldn\'t be null');
    //     Assert.isInstanceOfType(value, Double.class, 'Value should be an instance of Double');
    // }


    // Uncomment this in case your org has a Multipicklist field and modify accordingly. 
    // @IsTest
    // static void itShouldPopulateMultipicklistValue() {
    //     // given
    //     Schema.DisplayType type = Schema.DisplayType.MULTIPICKLIST;
    //     // Modify this line according to your Object and Field
    //     Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get('YOUR_MULTIPICKLIST_FIELD__c');

    //     // when
    //     Test.startTest();
    //     TestDataFactory tdf = new TestDataFactory();
    //     tdf.obj = new Account(Name = 'Test');
    //     tdf.handlePopulatePicklist(field);
    //     Test.stopTest();

    //     // then
    //     Assert.isNotNull(tdf.obj.get('YOUR_MULTIPICKLIST_FIELD__c'), 'YOUR_MULTIPICKLIST_FIELD__c shouldn\'t be null');
    // }

    // Uncomment this in case your org has dependent picklists and modify accordingly
    // @IsTest
    // static void itShouldPopulatePicklistFieldWithDependencies() {
    //     // given
    //     String dependantName = 'YOUR_DEPENDANT_FIELD__c';
    //     String controllerName = 'Type';
    //     Schema.SObjectField dependantField = Schema.SObjectType.Account.fields.getMap().get(dependantName);

    //     // when
    //     Test.startTest();
    //     TestDataFactory tdf = new TestDataFactory();
    //     tdf.obj = new Account(Name = 'Test');
    //     tdf.populatePicklistFieldWithDependencies(dependantField);

    //     Test.stopTest();

    //     // then
    //     Assert.isNotNull(tdf.obj.get(dependantName), 'YOUR_DEPENDANT_FIELD__c shouldn\'t be null');
    //     Assert.isNotNull(tdf.obj.get(controllerName), 'controllerName shouldn\'t be null');
    // }
}