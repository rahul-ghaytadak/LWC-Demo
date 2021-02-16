({
    doInit: function(component, event, helper) {
        var action = component.get("c.getOppStage");
        action.setParams({
            "oppId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('return value');
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());

                if (response.getReturnValue() == true) {

                    component.set("v.boolean", true);
                } else {
                    component.set("v.boolean", false);
                }
            }
            console.log(component.get("v.boolean"));
        });

        $A.enqueueAction(action);

    },

    getCities: function(component, event, helper) {

        var params = {
            "input": component.get('v.location')
        }

        helper.callServer(component, "c.getSuggestions", function(response) {
            var resp = JSON.parse(response);
            console.log('Json parse---');
            console.log(resp.predictions);
            component.set('v.predictions', resp.predictions);
        }, params);

    },

    getCityDetails: function(component, event, helper) {

        var selectedItem = event.currentTarget;
        var placeid = selectedItem.dataset.placeid;

        var params = {
            "placeId": placeid
        }

        helper.callServer(component, "c.getPlaceDetails", function(response) {
            var placeDetails = JSON.parse(response);
            console.log('Json print');
            console.log(placeDetails);

            component.set('v.location', placeDetails.result.name);
            var streetConcatinate = '';

            for (var i = 0; i < placeDetails.result.address_components.length; i++) {
                console.log('JSON Response****');
                console.log(placeDetails.result.address_components[i].types[0]);

                /*  if(placeDetails.result.address_components[i].types[0] == "sublocality_level_1"){
                      streetConcatinate += placeDetails.result.address_components[i].long_name;
                      console.log('1');
                      console.log(streetConcatinate);
                  }*/
                if (placeDetails.result.address_components[i].types[0] == "street_number") {
                    streetConcatinate += ' ' + placeDetails.result.address_components[i].long_name;
                    console.log('2');
                    console.log(streetConcatinate);
                }
                if (placeDetails.result.address_components[i].types[0] == "route") {
                    streetConcatinate += ' ' + placeDetails.result.address_components[i].long_name;
                    console.log('3');
                    console.log(streetConcatinate);
                }

                if (placeDetails.result.address_components[i].types[0] == "locality") {
                    component.set("v.city", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "administrative_area_level_1") {
                    component.set("v.state", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "country") {
                    component.set("v.country", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "postal_code") {
                    component.set("v.zip", placeDetails.result.address_components[i].long_name);
                }
            }
            console.log('*********streetConcatinate***');
            console.log(streetConcatinate);
            if (streetConcatinate != null) {
                component.set("v.street", streetConcatinate);
            }

            component.set('v.predictions', []);
        }, params);
    },

    handleClick: function(component, event, helper) {
        //   alert("You clicked: " + event.getSource().get("v.label"));
        console.log('On Click');
        console.log(component.get("v.street"));
        var city = component.get("v.city")
        var state = component.get("v.state");
        var country = component.get("v.country");
        var zip = component.get("v.zip");
        var action = component.get("c.getAddress");
        action.setParams({
            "dealId": component.get("v.recordId"),
            "street": component.get("v.street"),
            "city": city,
            "state": state,
            "country": country,
            "zip": zip,

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('**state**');
            console.log(state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                var wrapeObj = JSON.parse(response.getReturnValue());
                if (wrapeObj.isSuccess) {
                    toastEvent.setParams({
                        "type": "success",
                        "message": "Address has been updated Sucessfully"
                    });
                    toastEvent.fire();
                } else if (!wrapeObj.isSuccess) {
                    toastEvent.setParams({
                        "type": "error",
                        "message": wrapeObj.errormessage
                    });
                    toastEvent.fire();
                }

                $A.get('e.force:refreshView').fire();

            } else {

            }
        });
        $A.enqueueAction(action);
    }
})