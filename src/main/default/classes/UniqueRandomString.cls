public with sharing class UniqueRandomString {

    private static UniqueRandomString urs;
    private String chars;
    private Integer length;
    private Set<String> generatedStrings = new Set<String>();
    private String generatedString;
    private Integer maxPossibleCombinations;

    private UniqueRandomString(String chars, Integer length) {
        this.chars = chars;
        this.length = length;
        this.maxPossibleCombinations = (Integer) Math.pow(chars.length(), length);
    }

    public static UniqueRandomString getInstance(String chars, Integer length) {

        if (urs == null) {
            urs = new UniqueRandomString(chars, length);
        }
        
        return urs;
    }

    public void generateRandomString() {

        if (generatedStrings.size() == maxPossibleCombinations) {
            throw new MathException('All possible combinations have been exhausted');
        }

        while (generatedStrings.size() < maxPossibleCombinations) {

            String randomStr = '';

            while (randomStr.length() < length) {
                Integer index = Math.round(Math.random() * (chars.length() - 1));
                randomStr += chars.substring(index, index + 1);
            }

            if (!generatedStrings.contains(randomStr)) {
                generatedStrings.add(randomStr);
                generatedString = randomStr;
                return;
            }
        }
    }

    public String getRandomString() {
        generateRandomString();
        return generatedString;
    }
}