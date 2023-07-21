using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Crypto.Encodings;
using Org.BouncyCastle.Crypto.Engines;
using Org.BouncyCastle.OpenSsl;

namespace wServer.networking
{
    public class RSA
    {

        public static readonly RSA Instance = new(@"
-----BEGIN RSA PRIVATE KEY-----
MIIBOQIBAAJBAJYcGYP8085tR3BvhI/PIyG5zsWjCbGFGIdO8h9zcwWCMQI0rmMf
iNXY779YssKiQwrj3PDDsxmw1+V6Qd1uVNkCAwEAAQJAeqNUeVALH8CKOCL0E6Xw
lvI+K5wLJFyP8KQgDm/9DgbNeM+64jwSVsYTLc0ipj607wODB5PWAjEZlAI4hguT
7QIhAOn9wNrRF0m2pTD2OZfD2cPeKFMZe8DuqV8fJicudGcPAiEApDqTICuXIU6Z
24875UzuJdz5pWUEBEAeWdb98v0ZxZcCIH7OIYFz5qbv8D3Echmo7Y6UCk5edQ5t
SCRggRCiwDpJAiB9RGSWxEkZ0b+P9rhEFiMM5HnTy7J9n37HHjNEVgSDbwIgBZ1+
3U0hLxrqshAv6jtqFBsRp9lMn0ssKT3bKjomonE=
-----END RSA PRIVATE KEY-----");

        RsaEngine engine;
        AsymmetricKeyParameter key;

        private RSA(string privPem)
        {
            key = (new PemReader(new StringReader(privPem.Trim())).ReadObject() as AsymmetricCipherKeyPair).Private;
            engine = new RsaEngine();
            engine.Init(true, key);
        }

        public string Decrypt(string str)
        {
            if (string.IsNullOrEmpty(str)) return "";
            byte[] dat = Convert.FromBase64String(str);
            var encoding = new Pkcs1Encoding(engine);
            encoding.Init(false, key);
            return Encoding.UTF8.GetString(encoding.ProcessBlock(dat, 0, dat.Length));
        }

        public string Encrypt(string str)
        {
            if (string.IsNullOrEmpty(str)) return "";
            byte[] dat = Encoding.UTF8.GetBytes(str);
            var encoding = new Pkcs1Encoding(engine);
            encoding.Init(true, key);
            return Convert.ToBase64String(encoding.ProcessBlock(dat, 0, dat.Length));
        }
    }
}