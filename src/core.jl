
using Requests
using JSON
using LightXML
using HttpServer
import Redis: RedisConnection, disconnect, set, get, scan
import Base: ==

include("gh.jl")
include("rss.jl")
include("store.jl")
include("web.jl")
