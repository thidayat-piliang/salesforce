({
    loadRecordData : function(component) {
        var action = component.get("c.getAccountFields");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var acc = response.getReturnValue();
                if(acc){
                    component.set("v.name", acc.Name);
                    component.set("v.age", acc.Age__c);
                    component.set("v.height", acc.Height__c);
                    component.set("v.weight", acc.Weight__c);
                    component.set("v.bmi", acc.BMI__c);
                    component.set("v.status", acc.Weight_Status__c);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    calculateBMIHelper : function(component) {
        var action = component.get("c.calculateAndSaveBMI");
        action.setParams({
            recordId: component.get("v.recordId"),
            age: component.get("v.age"),
            height: component.get("v.height"),
            weight: component.get("v.weight")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var acc = response.getReturnValue();
                component.set("v.bmi", acc.BMI__c);
                component.set("v.status", acc.Weight_Status__c);
                alert("BMI saved successfully!");
            } else {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message){
                    alert(errors[0].message);
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})
