public with sharing class TestDataFactoryException extends Exception {

    public TestDataFactoryException(DmlException ex) {

        switch on ex.getDmlType(0) {
            when FIELD_INTEGRITY_EXCEPTION {
                this.setMessage('Insert failed, the provided picklist value for field ' + ex.getDmlFieldNames(0) + ' is not valid for this record');
            } when INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST {
                this.setMessage('Insert failed, ' + ex.getDmlFieldNames(0) + ' has restricted values by Record Type. Please use a different method overload');
            } when FIELD_CUSTOM_VALIDATION_EXCEPTION {
                this.setMessage('Insert failed, a validation rule prevented record insertion. Please use createTestSObjects instead');
            }
        }
    }
}