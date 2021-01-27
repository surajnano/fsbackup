/* **************************************************************************
* Copyright © 2015-2020, Neilon Technologies LLP.
* All rights reserved
*
* Controller Class: edCustomS3FileUploadController
* Created by Suresh Meghnathi, 05/06/2020
*
* This is the conroller for custom S3 file upload.

* - Modifications:
* - Suresh Meghnathi, 05/06/2020 – Initial Development
************************************************************************** */
public class edCustomS3FileUploadController {
    /**************************************************************************
       Purpose: This method is used to get the folder
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
   	@AuraEnabled
    public static String getFolder(String parentRecordId){
		try{
			// Check account id
			if(String.isBlank(parentRecordId)){
				throw new apApplicationException('Account Id cannot be empty. Please contact System Admin.');
			}
			
			// Get default bucket
            List<NEILON__Folder__c> buckets = [Select Name, NEILON__Bucket_Region__c From NEILON__Folder__c Where NEILON__Parent__c = null AND NEILON__Default__c = true AND NEILON__Active__c = true LIMIT 1];
            if(buckets.isEmpty()){
                throw new apApplicationException('Amazon S3 bucket is not configured. Please contact System Admin.');
            }
            
			// Folder id
            String folderId;
            String objectName = VertevaUtils.findObjectNameFromRecordIdPrefix(parentRecordId);
			
			// Get existing record home folder for orders
            String filterByParent;

            switch on objectName {
                when 'Account' {
                    filterByParent = ' AND NEILON__Account__c = :parentRecordId';
                }
                when 'Application__c' {
                    filterByParent = ' AND Application__c = :parentRecordId';
                }
                when 'loan__Loan_Account__c' {
                    filterByParent = ' AND Loan_Account__c = :parentRecordId';
                }
            }
            
            String folderQuery = 'SELECT Id, Name, NEILON__Bucket_Name__c, NEILON__Bucket_Region__c FROM NEILON__Folder__c WHERE NEILON__Record_Home__c = true ' + filterByParent;
            
            List<NEILON__Folder__c> existingRecordHomeFolders = Database.query(folderQuery);
			
			
			// Remove orders with existing folders
			if(existingRecordHomeFolders != null && !existingRecordHomeFolders.isEmpty()){
				folderId = existingRecordHomeFolders[0].Id;
			} else{
                // Get GUID
                
                String query = 'SELECT Id, Name, ExternalId__c FROM ' + objectName + ' WHERE Id = :parentRecordId LIMIT 1';
                List<sObject> records = Database.query(query);

				//Account account  = [Select Id, Name, ExternalId__c From Account Where Id =: parentRecordId LIMIT 1];
				
				// Prepare map of folder name by id
                Map<Id, String> folderNamesById = new  Map<Id, String>();

                if(objectName == 'loan__Loan_Account__c')
                    folderNamesById.put( (String) records[0].get('Id'), (String) records[0].get('Id'));
                else 
                    folderNamesById.put( (String) records[0].get('Id'), (String) records[0].get('ExternalId__c'));
				
				// Create folder structure
				Map<Id, NEILON__Folder__c> updatedRecordHomeFoldersByAccountId = NEILON.apGlobalUtils.buildFolderArchitecture(new Set<Id>{parentRecordId}, folderNamesById);
				
				// Get folder for account
				NEILON__Folder__c folderForAccount = updatedRecordHomeFoldersByAccountId.get(parentRecordId);
				if(folderForAccount != null){
					folderId = folderForAccount.Id;
				}
			}
            
            
            // Check root folder
            if(String.isBlank(folderId)){
                throw new apApplicationException('We are not able to create folder. Please contact S3-Link Support team.');
            }
            
            // Return folder
            return folderId;
		} catch(Exception ex){
            // Throw error
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /*
    Exception Info
    */
    public class apApplicationException extends Exception{
    }
}