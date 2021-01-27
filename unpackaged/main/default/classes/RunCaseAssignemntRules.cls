// test class : CaseTriggerHandlerTest.testcaseassignmentrules
public class RunCaseAssignemntRules {
    @InvocableMethod
    Public static void Caseassignmentrule(List<id> Caseid){
        AssignmentRule ar = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId = ar.id;
        List<Case> Cases = [Select id from Case where id IN : Caseid];
        Database.update(Cases, dmlOpts);
    }
}