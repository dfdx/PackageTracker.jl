
using HttpServer

handler = HttpHandler() do req::Request, resp::Response
    if startswith(req.resource, "/rss")
        return rss_feed(req)
    elseif startswith(req.resource, "/update")
        return update_rss(req)
    else
        return Response(404, "Not found")
    end
end


function update_rss(req::Request)
    new_pkgs = retrieve_new_packages()
    old_pkgs = Set(load_packages())
    upd_pkgs = [pkg for pkg in new_pkgs if !in(pkg, old_pkgs)]
    add_packages(upd_pkgs)
    return Response(200, "OK")
end

function rss_feed(req::Request)
    pkgs = load_packages()
    pkgs = sort(pkgs; by=pkg->pkg.pubdate, rev=true)
    xml = create_rss(pkgs)
    return Response(200, xml)
end


function main()
    server = Server(handler)
    run(server, host=IPv4(0,0,0,0), port=8000)
end



