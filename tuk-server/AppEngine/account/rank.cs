using System.Collections.Specialized;
using Anna.Request;
using Shared;
using NLog;

namespace AppEngine.account
{
    class rank : RequestHandler
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
                    Write(context, "<Error>Account not allowed to manage ranks.</Error>");
                    return;
                }

                var msg = "<Success>Role not found. Default to 0</Success>";
                var dId = query["dId"];
                var role = query["role"];
                var rank = 0;
                foreach (var r in Program.Resources.RoleRanks)
                {
                    if (!r.role.Equals(role))
                        continue;

                    rank = r.rank;
                    msg = "<Success/>";
                    break;
                }

                Database.RankDiscord(dId, rank);
                Write(context, msg);
                RankManagerLog.Info($"[{acc.Name}] Discord rank changed ({dId}:{rank})");
            }
            else
                Write(context, "<Error>" + status.GetInfo() + "</Error>");
        }
    }
}