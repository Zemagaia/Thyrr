﻿using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Dynamic;
using System.Linq;

namespace Anna.Request; 

public class ArgumentsDynamic : DynamicObject {
    private IDictionary<string, string> args;

    public ArgumentsDynamic(NameValueCollection nameValueCollection) {
        args = nameValueCollection.Keys.OfType<string>()
            .ToDictionary(k => k.ToString(),
                k => nameValueCollection[k],
                StringComparer.InvariantCultureIgnoreCase);
    }

    public ArgumentsDynamic(IDictionary<string, string> args) {
        this.args = args;
    }

    public override bool TryGetMember(GetMemberBinder binder, out object result) {
        // Converting the property name to lowercase
        // so that property names become case-insensitive.
        var name = binder.Name.ToLower();

        // If the property name is found in a dictionary,
        // set the result parameter to the property value and return true.
        // Otherwise, return false.
        result = !args.TryGetValue(name, out var value) ? null : value;
        return true;
    }
}