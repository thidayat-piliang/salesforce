@IsTest
private class LeadServiceRestTest {

    // JSON valid
    private static String makeBodyTaufik() {
        return JSON.serialize(new Map<String, Object>{
            'FirstName'  => 'Taufik',
            'LastName'   => 'Hidayat',
            'Phone'      => '081288774256',
            'Email'      => 'thidayat.piliang@gmail.com',
            'Street'     => 'Jl. Kemanggisan Ilir XI',
            'City'       => 'Jakarta',
            'State'      => 'JK',
            'Country'    => 'ID',
            'PostalCode' => '12345',
            'Weight'     => 80,
            'Height'     => 175,
            'ExternalId' => 'EXT-100',
            'Company'    => 'PT Testing'
        });
    }

    // JSON Company kosong "Unknown"
    private static String makeBodyNoCompany() {
        return JSON.serialize(new Map<String, Object>{
            'FirstName'  => 'Taufik',
            'LastName'   => 'Hidayat',
            'Phone'      => '081288774256',
            'Email'      => 'thidayat.piliang@gmail.com',
            'Street'     => 'Jl. Kemanggisan Ilir XI',
            'City'       => 'Jakarta',
            'State'      => 'JK',
            'Country'    => 'ID',
            'PostalCode' => '12345',
            'Weight'     => 80,
            'Height'     => 175,
            'ExternalId' => 'EXT-100',
            'Company'    => ''   // kosong → harus fallback ke "Unknown"
        });
    }


    //
    // 1) TEST SUCCESS 
    //
    @IsTest
    static void testCreateLeadSuccess_Taufik() {

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/leadservice/v1/create';
        req.requestBody = Blob.valueOf(makeBodyTaufik());

        RestContext.request  = req;
        RestContext.response = new RestResponse();

        LeadServiceRest.LeadResponse res = LeadServiceRest.createLead();

        System.assertEquals(true, res.success, 'Harus sukses');
        System.assertNotEquals(null, res.leadId, 'LeadId harus ada');

        Lead ld = [
            SELECT FirstName, LastName, Phone, Email, Street, City,
                   StateCode, CountryCode, PostalCode,
                   Weight__c, Height__c, ExternalId__c, Company
            FROM Lead
            WHERE Id = :res.leadId
        ];

        System.assertEquals('Taufik', ld.FirstName);
        System.assertEquals('Hidayat', ld.LastName);
        System.assertEquals('081288774256', ld.Phone);
        System.assertEquals('thidayat.piliang@gmail.com', ld.Email);
        System.assertEquals('Jl. Kemanggisan Ilir XI', ld.Street);
        System.assertEquals('Jakarta', ld.City);

        System.assertEquals('JK', ld.StateCode);
        System.assertEquals('ID',    ld.CountryCode);

        System.assertEquals(80,  ld.Weight__c);
        System.assertEquals(175, ld.Height__c);
        System.assertEquals('EXT-100', ld.ExternalId__c);
        System.assertEquals('PT Testing', ld.Company);
    }


    //
    // 2) TEST COMPANY "Unknown"
    //
    @IsTest
    static void testCompanyFallback() {

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/leadservice/v1/create';
        req.requestBody = Blob.valueOf(makeBodyNoCompany());

        RestContext.request  = req;
        RestContext.response = new RestResponse();

        LeadServiceRest.LeadResponse res = LeadServiceRest.createLead();

        System.assertEquals(true, res.success);
        System.assertNotEquals(null, res.leadId);

        Lead ld = [
            SELECT Company
            FROM Lead
            WHERE Id = :res.leadId
        ];

        System.assertEquals('Unknown', ld.Company, 'Company harus auto Unknown jika kosong');
    }


    //
    // TEST ERROR (invalid JSON → masuk catch)
    //
    @IsTest
    static void testInvalidJson() {

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/leadservice/v1/create';

        req.requestBody = Blob.valueOf('{invalid json');

        RestContext.request  = req;
        RestContext.response = new RestResponse();

        LeadServiceRest.LeadResponse res = LeadServiceRest.createLead();

        System.assertEquals(false, res.success, 'Harus gagal');
        System.assertEquals(null,  res.leadId);
    }
}
