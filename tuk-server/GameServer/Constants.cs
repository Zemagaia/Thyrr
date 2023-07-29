namespace GameServer;

// Immunities for AddImmunity behavior
// these match the StatsType id
public enum Immunity : byte
{
    // Ids for Entity.Immunities
    SlowImmune = 0,
    StunImmune = 1,
    UnarmoredImmune = 2,
    StasisImmune = 3,
    ParalyzeImmune = 4,
    CurseImmune = 5,
    PetrifyImmune = 6,
    CrippledImmune = 7,
}