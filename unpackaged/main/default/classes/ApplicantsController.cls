public with sharing class ApplicantsController {

    @AuraEnabled
    public static List<Applicant__c> getApplicants(String applicationId){

        return [SELECT  Id, Account__r.Name, Application__c, Application__r.SubmittedDate__c,
                        (SELECT    Id
                          FROM     ApplicantEmployments__r
                          ORDER BY CreatedDate DESC
                          LIMIT    1),
                        (SELECT    Id
                            FROM   ApplicantAddresses__r WHERE ResidenceType__c = 'Present Address'
                          ORDER BY CreatedDate DESC
                          LIMIT    1),
        (SELECT Id,Name FROM Applicant_Identities__r ORDER BY CreatedDate DESC)
                FROM    Applicant__c 
                WHERE   Application__c = :applicationId];
        
    }
}