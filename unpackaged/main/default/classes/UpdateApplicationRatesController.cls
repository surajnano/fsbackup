/**
 * Created by Muhammad on 12/11/20.
 */

public with sharing class UpdateApplicationRatesController {
    @AuraEnabled
    public static String executeBatch(){
            BatchUpdateApplicationRates bular = new BatchUpdateApplicationRates();

            return Database.executeBatch(bular, 5);

        }
}