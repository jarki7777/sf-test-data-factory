// TO DO:
// related records, createOnCascade, createOnReverseCascade, insertOnCascade, insertOnReverseCascade
// validation rules -> catch custom validation exception and throw tdf exception

// Code coverage will plummet below 60% if the org has no RecordTypes
// I had to add catch blocks on every insert test because of CleanStatus field throwing FIELD_INTEGRITY_EXCEPTION on some values
// Still trying to find a way to to test validation rule exceptions

public with sharing class TestDataFactory {

    @TestVisible
    private SObject obj;
    private static final String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    private static final String NUMS = '123456789';
    private static final String BASE64MAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    public void insertTestSObjects(String sObjectApiName) {
        createSObjectInstance(sObjectApiName);
        populateRequiredFields(getRequiredFields(sObjectApiName));
        try {
            insert this.obj;
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }        
    }

    public void insertTestSObjects(String sObjectApiName, Integer count) {

        List<SObject> results = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            results.add(createTestSObjects(sObjectApiName));
        }

        try {
            insert results;            
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }
    }

    public void insertTestSObjects(String sObjectApiName, Integer count, String rtDevName, Map<String, String> pickListValues) {
        List<SObject> results = createTestSObjects(sObjectApiName, count, rtDevName, pickListValues);
        try {
            insert results;            
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }
    }

    public void insertTestSObjects(String sObjectApiName, Integer count, String rtDevName) {
        List<SObject> results = createTestSObjects(sObjectApiName, count, rtDevName);
        try {
            insert results;            
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }
    }

    public SObject createTestSObjects(String sObjectApiName) {
        createSObjectInstance(sObjectApiName);
        populateRequiredFields(getRequiredFields(sObjectApiName));
        return this.obj;
    }

    public List<SObject> createTestSObjects(String sObjectApiName, Integer count) {
        
        List<SObject> results = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            results.add(createTestSObjects(sObjectApiName));
        }

        return results;
    }

    public List<SObject> createTestSObjects(
        String sObjectApiName, 
        Integer count, 
        String rtDevName, 
        Map<String, String> pickListValues) 
    {

        List<SObject> results = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            createSObjectInstance(sObjectApiName, rtDevName, pickListValues);
            populateRequiredFields(getRequiredFields(sObjectApiName));
            results.add(this.obj);
        }

        return results;
    }

    public List<SObject> createTestSObjects(String sObjectApiName, Integer count, String rtDevName) {

        List<SObject> results = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            createSObjectInstance(sObjectApiName, rtDevName);
            populateRequiredFields(getRequiredFields(sObjectApiName));
            results.add(this.obj);
        }

        return results;
    }

    @TestVisible
    private void createSObjectInstance(String sObjectApiName) {

        SObjectType sObjType = ((SObject) Type.forName(sObjectApiName).newInstance()).getSObjectType();
        this.obj = sObjType.newSObject();
    }

    @TestVisible
    private void createSObjectInstance(String sObjectApiName, String rtDevName, Map<String, String> pickListValues) {

        SObjectType sObjType = ((SObject) Type.forName(sObjectApiName).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe();
        String rtId = objDescribe.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        this.obj = sObjType.newSObject(rtId, true);

        for (String field : pickListValues.keySet()) {
            this.obj.put(field, pickListValues.get(field));
        }
    }

    @TestVisible
    private void createSObjectInstance(String sObjectApiName, String rtDevName) {

        SObjectType sObjType = ((SObject) Type.forName(sObjectApiName).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe();
        String rtId = objDescribe.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        this.obj = sObjType.newSObject(rtId, true);
    }

    @TestVisible
    private Map<String, Schema.SObjectField> getRequiredFields(String sObjectApiName) {

        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> requiredFields = new Map<String, Schema.SObjectField>();

        for (String fieldName : fieldsMap.keySet()) {
            Schema.SObjectField field = fieldsMap.get(fieldName);
            Schema.DescribeFieldResult dr = field.getDescribe();
            if (!dr.isDefaultedOnCreate() && (!dr.isNillable() || dr.isNameField())) {
                requiredFields.put(fieldName, field);
            }
        }

        return requiredFields;
    }

    @TestVisible
    private void populateRequiredFields(Map<String, Schema.SObjectField> requiredFields) {

        for (String fieldName : requiredFields.keySet()) {
            Object value;

            Schema.SObjectField currentField = requiredFields.get(fieldName.toLowerCase());
            Schema.DescribeFieldResult dfr = requiredFields.get(fieldName.toLowerCase()).getDescribe();
            Schema.DisplayType fieldType = dfr.getType();

            Boolean hasValue = this.obj.get(fieldName) != null;
            Boolean isPickList = dfr.getPicklistValues().size() > 0;

            if (dfr.isCreateable() && !hasValue && !isPicklist) {
                value = getFieldValue(fieldType, currentField);
            } else if (dfr.isCreateable() && !hasValue && isPicklist) {
                handlePopulatePicklist(currentField);
            }

            if (value != null && this.obj.get(fieldName) == null) {
                this.obj.put(fieldName, value);
            }
        }
    }

    @TestVisible
    private Object getFieldValue(Schema.DisplayType fieldType, Schema.SObjectField currentField) {
        
        Object value;

        switch on fieldType {
            when STRING {
                value = getRandomStringValue(currentField);
            } when CURRENCY {
                value = getRandomDouble(currentField);
            } when PERCENT {
                value = getRandomDouble(currentField);
            } when TEXTAREA {
                value = getRandomStringValue(currentField);
            } when else {
                value = getFieldValue(fieldType);
            }
        }

        return value;
    }

    @TestVisible
    private Object getFieldValue(Schema.DisplayType fieldType) {
        
        Object value;

        switch on fieldType {
            when DATE {
                value = Date.today();
            } when DATETIME {
                value = Datetime.now();
            } when EMAIL {
                value = getRandomEmail();
            } when LOCATION {
                value = Location.newInstance(37.7899, -122.3969);
            } when PHONE {
                value = '00 353 1 440 3500';
            } when TIME {
                value = Time.newInstance(1, 2, 3, 4);
            } when URL {
                value = new Url('https://www.salesforce.com/');
            }
        }

        return value;
    }

    @TestVisible
    private static String getRandomStringValue(Schema.SObjectField field) {
        Integer maxLength = field.getDescribe().getLength();
        UniqueRandomString urs = UniqueRandomString.getInstance(CHARS, maxLength);
        return urs.getRandomString();
    }

    @TestVisible
    private static String getRandomEmail() {
        UniqueRandomString urs = UniqueRandomString.getInstance(CHARS, 5);
        return urs.getRandomString() + '@' + urs.getRandomString() + '.invalid';
    }

    @TestVisible
    private static Double getRandomDouble(Schema.SObjectField field) {

        Schema.DescribeFieldResult dfr = field.getDescribe();

        Integer maxLength = dfr.getDigits() + dfr.getPrecision();
        Integer decimalPosition = dfr.getScale();
        
        UniqueRandomString urs = UniqueRandomString.getInstance(NUMS, maxLength);
        String numberString = urs.getRandomString();
        
        String leftPart = numberString.substring(0, numberString.length() - decimalPosition);
        String rightPart = numberString.substring(numberString.length() - decimalPosition);
        
        String stringNumber = rightPart != '' ?  leftPart + '.' + rightPart: leftPart;
        return Double.valueOf(stringNumber);
    }

    @TestVisible
    private void handlePopulatePicklist(Schema.SObjectField field) {
        
        populatePicklistFieldWithDependencies(field);
        populatePicklistField(field);
        
    }

    @TestVisible
    private void populatePicklistFieldWithDependencies(Schema.SObjectField field) {

        Schema.DescribeFieldResult dfr = field.getDescribe();
        Boolean isDependant = dfr.isDependentPicklist();
        
        if (isDependant) {
            String fieldName = dfr.getName();
            Schema.SObjectField controllerField = dfr.getController();
            String controllerValue = getRandomPicklistValue(controllerField.getDescribe().getPicklistValues());
            this.obj.put(controllerField.getDescribe().getName(), controllerValue);
            
            Map<String, List<Schema.PicklistEntry>> dependencies = getPicklistDependencies(field);
            String dependencyValue = getRandomPicklistValue(dependencies.get(controllerValue));
            this.obj.put(fieldName, dependencyValue);
        }
    }

    @TestVisible
    private void populatePicklistField(Schema.SObjectField field) {

        Schema.DescribeFieldResult dfr = field.getDescribe();
        String fieldName = dfr.getName();

        if (this.obj.get(fieldName) == null) {
            this.obj.put(fieldName, getRandomPicklistValue(dfr.getPicklistValues()));            
        }
    }


    @TestVisible
    public static String getRandomPicklistValue(List<Schema.PicklistEntry> allValues) {

        List<Schema.PicklistEntry> allowedValues = new List<Schema.PicklistEntry>();

        for (Schema.PicklistEntry val : allValues) {
            if (val.isActive()) {
                allowedValues.add(val);
            }
        }

        Integer randomIndex = Math.round(Math.random() * (allowedValues.size() - 1));

        return allowedValues[randomIndex].getValue();
    }

    @TestVisible
    private static Map<String, List<Schema.PicklistEntry>> getPicklistDependencies(Schema.SObjectField field) {

        Map<String, List<Schema.PicklistEntry>> dependencies = new Map<String, List<Schema.PicklistEntry>>();

        Schema.DescribeFieldResult dfr = field.getDescribe();

        Schema.DescribeFieldResult control = field.getDescribe().getController().getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if (control.getType() != Schema.DisplayType.BOOLEAN) {
            controlEntries = control.getPicklistValues();
        }

        for (Schema.PicklistEntry entry : dfr.getPicklistValues()) {

            Map<String, Object> mappedEntryClass = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry));
            String validFor = String.valueOf(mappedEntryClass.get('validFor'));
            Boolean hasDependencies = String.isNotEmpty(validFor);

            if (entry.isActive() && hasDependencies) {

                List<String> base64chars = validFor.split('');
                
                Integer condition = controlEntries != null ? controlEntries.size() : 2;
                for (Integer index = 0; index < condition; index++) {

                    Object controlPickListEntry =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index] : null)
                            );

                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }

                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlPickListEntry == null || (BASE64MAP.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0) {
                        continue;
                    }

                    Schema.PicklistEntry pickEntry = (Schema.PicklistEntry) controlPickListEntry;

                    if (!dependencies.containsKey((String) pickEntry.getValue())) {
                        dependencies.put(pickEntry.getValue(), new List<Schema.PicklistEntry>());
                    }

                    dependencies.get((String) pickEntry.getValue()).add(entry);
                }
            }
        }

        return dependencies;
    }
}