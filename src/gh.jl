
using Requests
using JSON
import Base: ==

immutable NewPackage
    name::String
    author::String
    url::String
    pubdate::DateTime
    description::String
end


function ==(pkg1::NewPackage, pkg2::NewPackage)
    return all(getfield(pkg1, f) == getfield(pkg2, f) for f in fieldnames(pkg1))
end


const GH_BASE_URL = "https://api.github.com"
const TOKEN = ENV["GITHUB_AUTH"]


function gh_get(endpoint::String; params=Dict())
    headers = Dict("Accept" => "application/vnd.github.v3+json")
    url = GH_BASE_URL * endpoint
    query = merge(Dict("access_token" => TOKEN), params)
    resp = get(url; headers=headers, query=query)
    return JSON.parse(String(resp.data))
end


function pull_requests(last_n::Int)
    params = Dict("state" => "closed", "sort" => "merged_at",
                  "direction" => "desc", "per_page" => last_n)
    return gh_get("/repos/JuliaLang/METADATA.jl/pulls"; params=params)
end


function is_registration_pr(pr::Dict)
    return (pr["state"] == "closed" &&
            pr["merged_at"] != nothing &&
            ismatch(r"^[Rr]egister.*", pr["title"]))
end


function to_new_package(pr::Dict)
    resp = get(pr["diff_url"]; query=Dict("access_token" => TOKEN))
    diff = String(resp.data)
    url = "<unknown>"
    for line in split(diff, "\n")
        m = match(r"^\+(https://github.com/.+/.+\.jl.git)$", line)
        if !isa(m, Void)
            url = m.captures[1]
            break
        end
    end
    name = match(r"^https://github.com/.+/(.+\.jl).git", url).captures[1]
    author = match(r"^https://github.com/(.+)/.+\.jl.git", url).captures[1]
    pubdate = DateTime(pr["merged_at"], "yyyy-mm-ddTHH:MM:SSZ")
    description = pr["body"]
    return NewPackage(name, author, url, pubdate, description)
end


function retrieve_new_packages()
    prs = pull_requests(200)
    new_pkg_prs = filter(is_registration_pr, prs)
    return [to_new_package(pr) for pr in new_pkg_prs]
end
    
