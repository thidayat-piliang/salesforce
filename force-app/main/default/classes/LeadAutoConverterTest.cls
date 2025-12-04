@IsTest
public class LeadAutoConverterTest {

    // Ambil satu status Lead yang valid untuk conversion
    private static String getValidConvertedStatus() {
        LeadStatus ls = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        return ls.MasterLabel;
    }

    @TestSetup
    static void setupTestData() {
        List<Lead> leads = new List<Lead>();

        // Lead tidak eligible (skip) - missing Email
        leads.add(new Lead(
            FirstName = 'NotEligible',
            LastName = 'Lead',
            Company = 'Company1',
            Phone = '08123456780',
            Weight__c = 65,
            Height__c = 165,
            ExternalId__c = 'EXT1',
            Status = 'Open - Not Contacted'
        ));

        // Lead eligible
        String uniqueEmail = 'eligible' + Datetime.now().getTime() + '@example.com';
        leads.add(new Lead(
            FirstName = 'Eligible',
            LastName = 'Lead',
            Company = 'Company2',
            Email = uniqueEmail,
            Phone = '08123456781',
            Weight__c = 60,
            Height__c = 160,
            ExternalId__c = 'EXT2',
            Status = 'Open - Not Contacted'
        ));

        insert leads;
    }

    @IsTest
    static void testConvertEligibleLeads() {
        List<Lead> leads = [SELECT Id, Email, Phone, Weight__c, Height__c, ExternalId__c, IsConverted FROM Lead];

        Test.startTest();
        LeadAutoConverter.convertEligibleLeads(leads);
        Test.stopTest();

        // Lead eligible harus benar-benar converted
        Lead eligible = [SELECT Id, IsConverted FROM Lead WHERE FirstName = 'Eligible'];
        System.assert(eligible.IsConverted, 'Lead eligible harus dikonversi');

        // Lead tidak eligible tetap tidak converted
        Lead notEligible = [SELECT Id, IsConverted FROM Lead WHERE FirstName = 'NotEligible'];
        System.assert(!notEligible.IsConverted, 'Lead tidak eligible tidak dikonversi');
    }

    @IsTest
    static void testEmptyList() {
        Test.startTest();
        LeadAutoConverter.convertEligibleLeads(new List<Lead>());
        Test.stopTest();
    }

    @IsTest
    static void testAllIneligibleLeads() {
        Lead l1 = new Lead(FirstName='A', LastName='B', Company='C'); 
        Lead l2 = new Lead(FirstName='D', LastName='E', Company='F'); 
        insert new List<Lead>{l1,l2};

        List<Lead> leads = [SELECT Id, IsConverted, Email, Phone, Weight__c, Height__c, ExternalId__c 
                            FROM Lead WHERE FirstName IN ('A','D')];

        Test.startTest();
        LeadAutoConverter.convertEligibleLeads(leads);
        Test.stopTest();

        for (Lead l : leads) {
            System.assert(!l.IsConverted, 'Lead tidak eligible tidak dikonversi');
        }
    }
}
