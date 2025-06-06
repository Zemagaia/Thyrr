﻿using System.Collections.Specialized;
using Anna.Request;
using Shared;

namespace AppEngine.account
{
    class purchaseSkin : RequestHandler
    {
        public override void HandleRequest(RequestContext context, NameValueCollection query)
        {
            DbAccount acc;
            var password = RSA.Instance.Decrypt(query["password"]);
            var status = Database.Verify(query["guid"], password, out acc);
            if (status == LoginStatus.OK)
            {
                // perhaps the checks should be moved into the purchase skin routine...
                var skinType = (ushort)Utils.FromString(query["skinType"]);
                var skinDesc = Program.Resources.GameData.Skins[skinType];
                var classStats = Program.Database.ReadClassStats(acc);

                if (skinDesc.UnlockLevel > classStats[skinDesc.PlayerClassType].BestLevel ||
                    skinDesc.Cost > acc.Credits ||
                    skinDesc.Restricted ||
                    skinDesc.UnlockSpecial)
                {
                    Write(context, "<Error>Failed to purchase skin</Error>");
                    return;
                }

                Program.Database.PurchaseSkin(acc, skinType, skinDesc.Cost);
                Write(context, "<Success />");
            }
            else
                Write(context, "<Error>" + status.GetInfo() + "</Error>");
        }
    }
}