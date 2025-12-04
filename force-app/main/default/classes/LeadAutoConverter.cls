public without sharing class LeadAutoConverter {

    public static void convertEligibleLeads(List<Lead> leads) {
        if (leads.isEmpty()) return;

        // Ambil satu convertedStatus yang valid di org
        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1].MasterLabel;

        List<Database.LeadConvert> converts = new List<Database.LeadConvert>();

        for (Lead l : leads) {
            if (l.IsConverted) continue;

            Boolean ready =
                String.isNotBlank(l.Phone) &&
                String.isNotBlank(l.Email) &&
                l.Weight__c != null &&
                l.Height__c != null &&
                String.isNotBlank(l.ExternalId__c);

            if (!ready) continue;

            Database.LeadConvert req = new Database.LeadConvert();
            req.setLeadId(l.Id);
            req.setConvertedStatus(convertedStatus); // gunakan status yang valid
            req.setDoNotCreateOpportunity(true);

            converts.add(req);
        }

        if (!converts.isEmpty()) {
            List<Database.LeadConvertResult> results = Database.convertLead(converts, false);

            for (Database.LeadConvertResult r : results) {
                if (!r.isSuccess()) {
                    // log error supaya bisa dicek, tapi tetap lanjut
                    System.debug('Lead conversion failed: ' + r.getErrors());
                }
            }
        }
    }
}
