#region

using common.resources;
using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;

#endregion

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ Misc = () => Behav()
                .Init("Skeletou",
                    new State(
                        new Timed(5000, new AddImmunity(Immunity.StunImmune, false, 3000)),
                        new Shoot(10, coolDown: 666)
                    ),
                    new Threshold(0.1,
                        new ItemLoot("Diabolic Halberd", 1)
                    )
                )

            /* .Init("Exploring Quest",
                new State(
                    new State("Default",
                        new AddImmunity(Immunities.StasisImmune, true),
                        new AddImmunity(Immunities.PetrifyImmune, true),
                        new PlayerWithinTransition(50, "Pick World", true, true)
                    ),
                    new State("Pick World",
                        new WorldTransition("Undead Lair", "UDL EXPLORATION")
                    ),
                    new State("UDL EXPLORATION",
                        new SayInWorld("Exploration Goal",
                            "Your goal in this quest is to eliminate Septavius the Ghost God."),
                        new EntityNotExistsTransition("Septavius the Ghost God", 9999, "UDL EXPLORATION FINISHED")
                    ),
                    new State("UDL EXPLORATION FINISHED",
                        new FinishExplorationQuest(),
                        new SayInWorld("Exploration Goal",
                            "Septavius the Ghost God has been eliminated and the exploration quest has been finished. Reconnecting to nexus shortly."),
                        new SendToNexus(5)
                    )
                )
            )*/;
    }
}