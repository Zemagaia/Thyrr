﻿using System.Collections.Specialized;
using Anna.Request;
using Shared;
using NLog;

namespace AppEngine.account
{
    class registerDiscord : RequestHandler
    {
        private static readonly Logger RankManagerLog = LogUtil.GetLogger("RankManagerLog");

        public override void HandleRequest(RequestContext context, NameValueCollection query)
        {
            DbAccount acc;
            var password = RSA.Instance.Decrypt(query["password"]);
            var status = Database.Verify(query["guid"], password, out acc);
            if (status == LoginStatus.OK)
            {
                if (!acc.RankManager)
                {
                    Write(context, "<Error>No permission</Error>");
                    return;
                }

                var accId = Database.ResolveId(query["ign"]);
                if (accId == 0)
                {
                    Write(context, "<Error>Account does not exist</Error>");
                    return;
                }

                var nAcc = Database.GetAccount(accId);
                if (nAcc.DiscordId != null)
                    Database.UnregisterDiscord(nAcc.DiscordId, accId);

                var dId = query["dId"];
                if (string.IsNullOrEmpty(dId))
                {
                    Write(context, "<Error>Invalid discord id</Error>");
                    return;
                }

                Database.RegisterDiscord(dId, accId);
                Write(context, "<Success/>");
                RankManagerLog.Info($"[{acc.Name}] Registered discord to account ({dId}:{accId})");
            }
            else
                Write(context, "<Error>" + status.GetInfo() + "</Error>");
        }
    }
}