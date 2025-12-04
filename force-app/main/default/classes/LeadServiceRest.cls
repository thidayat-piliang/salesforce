@RestResource(urlMapping='/leadservice/v1/create')
global with sharing class LeadServiceRest {

    global class LeadRequest {
        public String FirstName;
        public String LastName;
        public String Phone;
        public String Email;
        public String Street;
        public String City;
        public String State;
        public String Country;
        public String PostalCode;
        public Decimal Weight;
        public Decimal Height;
        public String ExternalId;
        public String Company;
    }

    global class LeadResponse {
        public Boolean success;
        public String message;
        public Id leadId;
    }

    @HttpPost
    global static LeadResponse createLead() {
        LeadResponse res = new LeadResponse();

        try {
            RestRequest req = RestContext.request;
            LeadRequest body = (LeadRequest) JSON.deserialize(req.requestBody.toString(), LeadRequest.class);

            Lead lead = new Lead();
            lead.FirstName  = body.FirstName;
            lead.LastName   = body.LastName;
            lead.Phone      = body.Phone;
            lead.Email      = body.Email;
            lead.Street     = body.Street;
            lead.City       = body.City;
            lead.StateCode   = body.State;
            lead.CountryCode = body.Country;
            lead.PostalCode = body.PostalCode;
            lead.Weight__c  = body.Weight;
            lead.Height__c  = body.Height;
            lead.ExternalId__c = body.ExternalId;
            lead.Company    = String.isBlank(body.Company) ? 'Unknown' : body.Company;

            insert lead;

            res.success = true;
            res.message = 'Lead created successfully';
            res.leadId = lead.Id;

        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }

        return res;
    }
}
