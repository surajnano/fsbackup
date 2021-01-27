public with sharing class OnboardingServiceQueueable implements Queueable, Database.AllowsCallouts {

    String serviceName;

    public OnboardingServiceQueueable(String serviceName){
        this.serviceName = serviceName;
    }

    public void execute(QueueableContext context) {
        OnboardingServices.makeCallout(serviceName, null);
    }
}