using System.Collections.Specialized;
using Anna.Request;
using common;
using log4net;
using wServer.networking;

namespace server.account
{
    class changePassword : RequestHandler
    {
        private static readonly ILog PassLog = LogManager.GetLogger("PassLog");

        public override void HandleRequest(RequestContext context, NameValueCollection query)
        {
            DbAccount acc;
            var password = RSA.Instance.Decrypt(query["password"]);
            var status = Database.Verify(query["guid"], password, out acc);
            if (status == LoginStatus.OK)
            {
                var newPassword = RSA.Instance.Decrypt(query["newPassword"]);
                if (newPassword.Length < 10)
                {
                    Write(context, "<Error>The password is too short</Error>");
                    return;
                }

                Database.ChangePassword(query["guid"], newPassword);
                Write(context, "<Success />");
                PassLog.Info(
                    $"Password changed. IP: {context.Request.ClientIP()}, Account: {acc.Name} ({acc.AccountId})");
            }
            else
                Write(context, "<Error>" + status.GetInfo() + "</Error>");
        }
    }
}