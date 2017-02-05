

function to_json(pkg::NewPackage)
    return JSON.json(pkg)
end


function from_json(jstr::String)
    d = JSON.parse(jstr)
    pubdate = DateTime(d["pubdate"], "yyyy-mm-ddTHH:MM:SSZ")
    return NewPackage(d["name"], d["author"], d["url"], pubdate, d["description"])
end

function add_packages(pkgs::Vector{NewPackage})
    conn = RedisConnection()
    for pkg in pkgs
        print("here")
        set(conn, pkg.name, to_json(pkg))
    end
    disconnect(conn)
end


function load_packages()
    conn = RedisConnection()
    pkgs = NewPackage[]
    next_cur, ks = scan(conn, 0)
    for k in ks
        if endswith(k, ".jl")
            jstr = get(conn, k)
            push!(pkgs, from_json(jstr))
        end
    end
    disconnect(conn)
    return pkgs
end

