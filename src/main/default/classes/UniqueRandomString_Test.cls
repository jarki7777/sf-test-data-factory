@IsTest
private class UniqueRandomString_Test {
    
    @IsTest
    static void itShouldGenerateRadomFixedLengthString() {
        // given
        Integer length = 10;
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

        // when
        Test.startTest();
        UniqueRandomString urs = UniqueRandomString.getInstance(chars, length);
        String randomString = urs.getRandomString();
        Test.stopTest();

        // then
        Assert.isNotNull(randomString, 'String shouldn\'t be null');
        Assert.isTrue(randomString.length() == length, 'String should be same length as parameter');
    }

    @IsTest
    static void itShouldGenerateUniqueStringsOnly() {
        // given
        String chars = 'ABC';
        Integer length = 2;
        Set<String> randomStrings = new Set<String>();

        // when
        Test.startTest();

        UniqueRandomString urs = UniqueRandomString.getInstance(chars, length);
        String errMsg;

        try {
            while (true) {
                randomStrings.add(urs.getRandomString());
            }
        } catch (MathException e) {
            errMsg = e.getMessage();
        }

        Test.stopTest();

        // then
        Assert.isNotNull(errMsg);
        Assert.areEqual('All possible combinations have been exhausted', errMsg);
        Assert.areEqual(9, randomStrings.size());
    }
}