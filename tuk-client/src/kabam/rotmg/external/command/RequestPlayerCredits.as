package kabam.rotmg.external.command {
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.external.service.RequestPlayerCreditsTask;

public class RequestPlayerCredits {

    public function RequestPlayerCredits() {
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new RequestPlayerCreditsTask());
        Global.taskMonitor.add(sequence);
        sequence.start();
    }


}
}
