package kabam.rotmg.legends.model {


public class Timespan {

    public static const WEEK:Timespan = new (Timespan)("Week", "week");
    public static const MONTH:Timespan = new (Timespan)("Month", "month");
    public static const ALL:Timespan = new (Timespan)("All Time", "all");
    public static const TIMESPANS:Vector.<Timespan> = new <Timespan>[WEEK, MONTH, ALL];

    private var name:String;
    private var id:String;

    public function Timespan(_arg1:String, _arg2:String) {
        this.name = _arg1;
        this.id = _arg2;
    }

    public function getName():String {
        return (this.name);
    }

    public function getId():String {
        return (this.id);
    }


}
}
