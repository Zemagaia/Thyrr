using System.Collections.Specialized;
using Anna.Request;

namespace server.account
{
    class blank : RequestHandler
    {
        public override void HandleRequest(RequestContext context, NameValueCollection query)
        {
            Write(context, new byte[0], true);
        }
    }
}