public with sharing class BMICalculatorController {

    @AuraEnabled
    public static Account getAccountFields(Id recordId) {
        if(recordId == null) return null;
        return [SELECT Id, Name, Age__c, Height__c, Weight__c, BMI__c, Weight_Status__c
                FROM Account WHERE Id = :recordId LIMIT 1];
    }
    
    @AuraEnabled
    public static Account calculateAndSaveBMI(Id recordId, Integer age, Decimal height, Decimal weight) {
        if(recordId == null) throw new AuraHandledException('Record Id is required.');
        if(height == null || height <= 0 || weight == null || weight <= 0) {
            throw new AuraHandledException('Height and Weight must be greater than 0.');
        }
        if(age == null || age <= 0) throw new AuraHandledException('Age must be greater than 0.');
        
        Decimal bmi = weight / (height * height);
        String status;
        if(bmi < 18.5) status = 'Underweight';
        else if(bmi < 25) status = 'Normal';
        else if(bmi < 30) status = 'Overweight';
        else status = 'Obese';
        
        Account acc = [SELECT Id, Name, Age__c, Height__c, Weight__c, BMI__c, Weight_Status__c 
                       FROM Account WHERE Id = :recordId LIMIT 1];
        
        acc.Age__c = age;
        acc.Height__c = height;
        acc.Weight__c = weight;
        acc.BMI__c = bmi.setScale(2);
        acc.Weight_Status__c = status;
        
        update acc;
        return acc;
    }
}
