window._snapinsSnippetSettingsFile = (function() {
console.log("Snippet settings file loaded.");	// Logs that the snippet settings file was loaded successfully
 /*
embedded_svc.snippetSettingsFile.avatarImgURL = 'https://yourwebsite.here/avatar.jpg';
embedded_svc.snippetSettingsFile.smallCompanyLogoImgURL = 'https://yourwebsite.here/company_logo.png';
embedded_svc.snippetSettingsFile.prechatBackgroundImgURL = 'https://yourwebsite.here/prechat_background.jpg';
embedded_svc.snippetSettingsFile.waitingStateBackgroundImgURL = 'https://yourwebsite.here/waiting_background.png';
embedded_svc.snippetSettingsFile.headerBackgroundURL = 'https://yourwebsite.here/header_background.jpg';
embedded_svc.snippetSettingsFile.chatbotAvatarImgURL = 'https://yourwebsite.here/bot_avatar.jpg';
embedded_svc.snippetSettingsFile.autoOpenPostChat = true;
 
embedded_svc.snippetSettingsFile.externalScripts = ['my_scripts'];
embedded_svc.snippetSettingsFile.externalStyles = ['my_styles'];
 
embedded_svc.snippetSettingsFile.directToButtonRouting = function(prechatFormData) {
if(prechatFormData[1].value === "Computer") {
console.log("direct to button routing initiated.");
alert("Alert: direct to button routing initiated!");
return "BUTTONIDHERE";
}
}
 
embedded_svc.snippetSettingsFile.fallbackRouting = ['USERIDHERE', 'BUTTONIDHERE', 'USERID_BUTTONID'];
 */
 
embedded_svc.snippetSettingsFile.extraPrechatFormDetails = [{"label":"FirstName","value":"John","displayToAgent":true},
{"label":"LastName","value":"Doe","displayToAgent":true},
{"label":"Email","value":"john.doe@salesforce.com","displayToAgent":true}];
 
/*
embedded_svc.snippetSettingsFile.extraPrechatInfo = [{
        "entityName": "Account",
        "linkToEntityName": "Case",
        "linkToEntityField": "AccountId",
        "entityFieldMaps": [{
          "isExactMatch": true,
          "fieldName": "Name",
          "doCreate": true,
          "doFind": true,
          "label": "LastName"
        }],

    "entityName": "Contact",
"showOnCreate": true,
"linkToEntityName": "Case",
"linkToEntityField": "ContactId",
"saveToTranscript": "ContactId",
"entityFieldMaps" : [{
"doCreate":true,
"doFind":true,
"fieldName":"FirstName",
"isExactMatch":true,
"label":"First Name"
}, {
"doCreate":true,
"doFind":true,
"fieldName":"LastName",
"isExactMatch":true,
"label":"Last Name"
}, {
"doCreate":true,
"doFind":true,
"fieldName":"Email",
"isExactMatch":true,
"label":"Email"
}],
}, {
"entityName":"Case",
"showOnCreate": true,
"saveToTranscript": "CaseId",
"entityFieldMaps": [{
"isExactMatch": false,
"fieldName": "Subject",
"doCreate": true,
"doFind": false,
"label": "Issue"
}, {
"isExactMatch": false,
"fieldName": "Status",
"doCreate": true,
"doFind": false,
"label": "Status"
}, {
"isExactMatch": false,
"fieldName": "Origin",
"doCreate": true,
"doFind": false,
"label": "Origin"
}]
}]; 

*/
})();