
using HttpServer

handler = HttpHandler() do req::Request, resp::Response
    if startswith(req.resource, "/rss")
        return rss_feed(req)
    else
        return Response(404, "Not found")
    end
end


function rss_feed(req::Request)
    pkgs = retrieve_new_packages()
    xml = create_rss(pkgs)
    return Response(200, xml)
end


function main()
    server = Server(handler)
    run(server, host=IPv4(0,0,0,0), port=8000)
end



