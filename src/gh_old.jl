
using GitHub

function is_registration_pr(pr::PullRequest)
    return (!isnull(pr.state) && get(pr.state) == "closed" &&
            !isnull(pr.merged_at) &&
            !isnull(pr.title) && ismatch(r"^[Rr]egister.*", get(pr.title)))
end


function to_dict(pr::PullRequest)
    d = Dict{Symbol,Any}()
    d[:title] = "TODO"
    d[:author] = get(get(pr.user).login)  # TODO: use repo URL instead
    d[:link] = string(get(pr.url))
    d[:date] = DateTime(get(pr.merged_at))
    d[:description] = get(pr.body)
end


function retrieve_new_packages()    
    auth = GitHub.authenticate(ENV["GITHUB_AUTH"])    
    params = Dict("state" => "closed", "per_page" => 200)
    prs = pull_requests("JuliaLang/METADATA.jl";
                        params=params, auth=auth, page_limit=1)[1]
    new_package_prs = filter(is_registration_pr, prs)
    return new_package_prs
end
