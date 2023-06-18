-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
return
  {name = "microbox/tag"
  ,version = "0.0.1"
  ,author =
    {name = "Daniel Barney"
    ,email = "daniel@pagodabox.com"}
  ,tags =
    {"failover"
    ,"cluster"}
  ,license = "MIT"
  ,homepage = "https://github.com/mu-box/tag"
  ,description = "Tag nodes and enjoy automatic failover for your cluster!"
  ,dependencies =
    {"luvit/tap@0.1.0-1"
    ,"luvit/require@1.2.0"
    ,"luvit/core@1.0.2-1"
    ,"luvit/fs@1.2.0"
    ,"luvit/json@2.5.0"
    ,"pagodabox/cauterize@0.1.0"
    ,"pagodabox/lmmdb@0.1.0"
    ,"pagodabox/logger@0.1.0"
    ,"pagodabox/splode@0.1.0"}
  ,files =
    {"**.lua"
    ,"**.txt"
    ,"**.so"
    ,"!examples"
    ,"!tests"}}
