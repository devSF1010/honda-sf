({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getPayload");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this,function(response){
            component.set("v.showSpinner",false);
            if(response.getState() == 'SUCCESS'){
                const data = response.getReturnValue();
                component.set("v.ChargingToggle",!!data);
            }
        });
        $A.enqueueAction(action);
    },
    handleChargingToggle: function(component,event,helper){
        component.set("v.showSpinner",true);
        let ChargingToggle = component.get("v.ChargingToggle");
        if(ChargingToggle) {
            let action = component.get("c.createChargingRecord");
            action.setParams({ recordId: component.get("v.recordId") });
            action.setCallback(this,function(response){
                component.set("v.showSpinner",false);
                $A.get('e.force:refreshView').fire()
            });
            $A.enqueueAction(action);
        } else {
            let action = component.get("c.updateChargingRecord");
            action.setParams({ recordId: component.get("v.recordId") });
            action.setCallback(this,function(response){
                component.set("v.showSpinner",false);
                if(response.getState() == 'SUCCESS'){
                    component.set("v.ChargingToggle",false);
                    $A.get('e.force:refreshView').fire()
                }
            });
            $A.enqueueAction(action);
        }
    }
})