﻿namespace Shared
{
    public interface ISellableItem
    {
        ushort ItemId { get; }
        int Price { get; }
        int Count { get; }
    }
}