
using SQLite
using DataFrames

const DB_PATH = "db.sqlite3"

function to_dataframe(pkgs::Vector{NewPackage})
    df = DataFrame(name=String[], author=String[], url=String[],
                   pubdate=DateTime[], description=String[])
    for pkg in pkgs
        push!(df, [pkg.name pkg.author pkg.url pkg.pubdate pkg.description])
    end
    return df
end

function from_dataframe(df::DataFrame)
    pkgs = Array{NewPackage}(0)
    for row in eachrow(df)
        pkg = NewPackage(row[:name], row[:author], row[:url],
                         row[:pubdate], row[:description])
        push!(pkgs, pkg)
    end
    return pkgs
end

function save_packages(pkgs::Vector{NewPackage})
    db = SQLite.DB(DB_PATH)
    df = to_dataframe(pkgs)
    SQLite.load(db, "packages", df)
end

function load_package()
    db = SQLite.DB(DB_PATH)
    df = SQLite.query(db, "select * from packages")
    return from_dataframe(df)
end
