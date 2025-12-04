trigger LeadTrigger on Lead (after insert, after update) {
    if (Trigger.isAfter) {
        LeadAutoConverter.convertEligibleLeads(Trigger.new);
    }
}
