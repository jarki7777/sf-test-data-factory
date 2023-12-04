// Code coverage will plummet well below 75% if the org has no RecordTypes nor dependant picklists

public with sharing class TestDataFactory {

    @TestVisible
    public SObject obj { get; private set; }
    public List<SObject> objs { get; private set; }
    public List<SObject> childs;
    private List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    private static final String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    private static final String NUMS = '123456789';
    private static final String BASE64MAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    public TestDataFactory make(String sObjectApiName) {
        SObject obj = createSObjectInstance(sObjectApiName);
        this.obj = populateRequiredFields(getRequiredFields(sObjectApiName), obj);
        return this;
    }

    public TestDataFactory make(String sObjectApiName, Integer count) {

        this.objs = new List<SObject>();

        for (Integer i = 0; i < count; i++) {
            SObject obj = createSObjectInstance(sObjectApiName);
            this.obj = populateRequiredFields(getRequiredFields(sObjectApiName), obj);
            this.objs.add(this.obj);
        }
        return this;
    }

    public TestDataFactory make(String sObjectApiName, String rtDevName) {
        SObject obj = createSObjectInstance(sObjectApiName, rtDevName);
        this.obj = populateRequiredFields(getRequiredFields(sObjectApiName), obj);
        return this;
    }

    public TestDataFactory make(String sObjectApiName, String rtDevName, Integer count) {

        this.objs = new List<SObject>();

        for (Integer i = 0; i < count; i++) {
            SObject obj = createSObjectInstance(sObjectApiName, rtDevName);
            this.obj = populateRequiredFields(getRequiredFields(sObjectApiName), obj);
            this.objs.add(this.obj);
        }

        return this;
    }

    public TestDataFactory withField(String name, Object value) {

        if (this.objs != null) {
            for (SObject currentObj : this.objs) {
                currentObj.put(name, value);
            }
        } else {
            this.obj.put(name, value);
        }

        return this;
    }

    public TestDataFactory withChild(String childSObjectName, Integer count) {

        if (this.saveResults.isEmpty()) {
            throw new TestDataFactoryException('Can\'t insert orphan records');
        }

        List<Schema.ChildRelationship> childRelationships = this.obj.getSObjectType().getDescribe().getChildRelationships();
        Schema.SObjectType childObj = Schema.getGlobalDescribe().get(childSObjectName);
        String foreignKey;

        for (Schema.ChildRelationship cr : childRelationships) {
            if (cr.getChildSObject() == childObj) {
                foreignKey = cr.getField().getDescribe().getName();
                break;
            }
        }

        this.childs = new List<SObject>();

        for (Database.SaveResult currentParent : this.saveResults) {

            for (Integer i = 0; i < count; i++) {

                SObject obj = createSObjectInstance(childSObjectName);
                SObject populatedChild = populateRequiredFields(getRequiredFields(childSObjectName), obj);
                populatedChild.put(foreignKey, currentParent.getId());

                this.childs.add(populatedChild);
            }
        }
        
        return this;
    }

    private boolean isBulk() {
        return this.objs != null && !this.objs.isEmpty();
    }

    public void insertChilds() {

        try {
            insert this.childs;
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }
    }

    public TestDataFactory insertData() {

        try {
            if (isBulk()) {
                this.saveResults = Database.insert(this.objs);
            } else {
                this.saveResults.add(Database.insert(this.obj));
            }            
        } catch (DmlException ex) {
            throw new TestDataFactoryException(ex);
        }

        return this;
    }

    @TestVisible
    private SObject createSObjectInstance(String sObjectApiName) {

        SObjectType sObjType = ((SObject) Type.forName(sObjectApiName).newInstance()).getSObjectType();
        return sObjType.newSObject();
    }

    @TestVisible
    private SObject createSObjectInstance(String sObjectApiName, String rtDevName) {

        SObjectType sObjType = ((SObject) Type.forName(sObjectApiName).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe();
        String rtId = objDescribe.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        return sObjType.newSObject(rtId, true);
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
    private SObject populateRequiredFields(Map<String, Schema.SObjectField> requiredFields, SObject obj) {

        for (String fieldName : requiredFields.keySet()) {
            Object value;

            Schema.SObjectField currentField = requiredFields.get(fieldName.toLowerCase());
            Schema.DescribeFieldResult dfr = requiredFields.get(fieldName.toLowerCase()).getDescribe();
            Schema.DisplayType fieldType = dfr.getType();

            Boolean hasValue = obj.get(fieldName) != null;
            Boolean isPickList = dfr.getPicklistValues().size() > 0;

            if (dfr.isCreateable() && !hasValue && !isPicklist) {
                value = getFieldValue(fieldType, currentField);
            } else if (dfr.isCreateable() && !hasValue && isPicklist) {
                handlePopulatePicklist(currentField, obj);
            }

            if (value != null && obj.get(fieldName) == null) {
                obj.put(fieldName, value);
            }
        }

        return obj;
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
                value = 'https://www.salesforce.com/';
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
    private void handlePopulatePicklist(Schema.SObjectField field, SObject obj) {
        
        populatePicklistFieldWithDependencies(field, obj);
        populatePicklistField(field, obj);
        
    }

    @TestVisible
    private void populatePicklistFieldWithDependencies(Schema.SObjectField field, SObject obj) {

        Schema.DescribeFieldResult dfr = field.getDescribe();
        Boolean isDependant = dfr.isDependentPicklist();
        
        if (isDependant) {
            String fieldName = dfr.getName();
            Schema.SObjectField controllerField = dfr.getController();
            String controllerValue = getRandomPicklistValue(controllerField.getDescribe().getPicklistValues());
            obj.put(controllerField.getDescribe().getName(), controllerValue);
            
            Map<String, List<Schema.PicklistEntry>> dependencies = getPicklistDependencies(field);
            String dependencyValue = getRandomPicklistValue(dependencies.get(controllerValue));
            obj.put(fieldName, dependencyValue);
        }
    }

    @TestVisible
    private void populatePicklistField(Schema.SObjectField field, SObject obj) {

        Schema.DescribeFieldResult dfr = field.getDescribe();
        String fieldName = dfr.getName();

        if (obj.get(fieldName) == null) {
            obj.put(fieldName, getRandomPicklistValue(dfr.getPicklistValues()));            
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