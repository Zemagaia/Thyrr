package kabam.rotmg.account.core.control {
public class IsAccountRegisteredToBuyGoldGuard extends IsAccountRegisteredGuard {


    override protected function getString():String {
        return ("In order to use Gold you must be a registered user.");
    }


}
}
