using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Xml.Linq;
using common;
using wServer.logic.loot;

namespace wServer.logic
{
    public class XmlBehaviorEntry
    {
        public readonly string Id;
        public readonly IStateChildren[] Behaviors;
        public readonly ILootDef[] Loots;

        public XmlBehaviorEntry(XElement e, string id)
        {
            Id = id;
            var behaviorTypes = Assembly.GetCallingAssembly().GetTypes()
                .Where(type => typeof(IStateChildren).IsAssignableFrom(type) && !type.IsInterface)
                .Select(type => type).ToArray();
            var lootTypes = Assembly.GetCallingAssembly().GetTypes()
                .Where(type => typeof(ILootDef).IsAssignableFrom(type) && !type.IsInterface)
                .Select(type => type).ToArray();
            var behaviors = new List<IStateChildren>();
            var loots = new List<ILootDef>();
            ParseStates(e, behaviorTypes, ref behaviors);
            if (e.Elements("LootDef").Count() > 0)
                ParseLoot(e, lootTypes, ref loots);
            Behaviors = behaviors.ToArray();
            Loots = loots.ToArray();
        }

        private static void ParseStates(XElement e, Type[] results, ref List<IStateChildren> behaviors)
        {
            var children = new List<IStateChildren>();
            foreach (var i in e.Elements("State"))
            {
                if (i.Elements("State").ToArray().Length > 0)
                    ParseStates(i, results, ref children);
                if (i.Elements("Behavior").ToArray().Length > 0)
                    ParseBehaviors(i, results, ref children);

                var state = (IStateChildren)Activator.CreateInstance(results.Single(x => x.Name == "State"),
                    i.GetAttribute<string>("id"), children.ToArray());
                behaviors.Add(state);
                children.Clear();
            }
        }

        private static void ParseBehaviors(XElement e, Type[] results, ref List<IStateChildren> behaviors)
        {
            var children = new List<IStateChildren>();
            foreach (var i in e.Elements("Behavior"))
            {
                if (i.Elements("Behavior").ToArray().Length > 0)
                    ParseBehaviors(i, results, ref children);

                var name = i.Attribute("behavior") != null ? i.GetAttribute<string>("behavior") : i.Value;
                IStateChildren behavior;
                if (children.Count > 0)
                    behavior = (IStateChildren)Activator.CreateInstance(results.Single(x => x.Name == name), i,
                        children.ToArray());
                else
                    behavior = (IStateChildren)Activator.CreateInstance(results.Single(x => x.Name == name), i);
                behaviors.Add(behavior);
                children.Clear();
            }
        }

        private static void ParseLoot(XElement e, Type[] results, ref List<ILootDef> loots)
        {
            var children = new List<ILootDef>();
            foreach (var i in e.Elements("LootDef"))
            {
                if (i.Element("LootTemplate") != null)
                {
                    var method = typeof(LootTemplates).GetMethods(BindingFlags.Public | BindingFlags.Static)
                        .FirstOrDefault(x => x.Name == i.GetAttribute<string>("LootTemplate"));
                    if (method != null)
                        foreach (var j in (ILootDef[])method.Invoke(null, null))
                            children.Add(j);
                }
                else if (i.Elements("LootDef").ToArray().Length > 0)
                    ParseLoot(i, results, ref children);

                var name = i.Attribute("behavior") != null ? i.GetAttribute<string>("behavior") : i.Value;
                ILootDef behavior;
                if (children.Count > 0)
                    behavior = (ILootDef)Activator.CreateInstance(results.Single(x => x.Name == name), i,
                        children.ToArray());
                else
                    behavior = (ILootDef)Activator.CreateInstance(results.Single(x => x.Name == name), i);
                if (behavior is null)
                {
                    continue;
                }

                loots.Add(behavior);
                children.Clear();
            }
        }
    }
}