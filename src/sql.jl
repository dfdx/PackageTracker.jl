
using SQLite
using DataFrames

const DB_PATH = Pkg.dir("PackageTracker", "db.sqlite3")

empty_package_dataframe() = DataFrame(name=String[], author=String[],
                                      url=String[], pubdate=DateTime[],
                                      description=String[])


function to_dataframe(pkgs::Vector{NewPackage})
    df = empty_package_dataframe()
    for pkg in pkgs
        push!(df, [pkg.name pkg.author pkg.url pkg.pubdate pkg.description])
    end
    return df
end


function from_dataframe(df::DataFrame)
    pkgs = Array{NewPackage}(0)
    for row in eachrow(df)
        pkg = NewPackage(get(row[:name]), get(row[:author]), get(row[:url]),
                         get(row[:pubdate]), get(row[:description]))
        push!(pkgs, pkg)
    end
    return pkgs
end


function ensure_packages_table(db::SQLite.DB)
    flds = fieldnames(NewPackage)
    fld_str = join(flds, ",")
    SQLite.execute!(db, "create table if not exists packages ($fld_str)")
end


function insert_package(db::SQLite.DB, pkg::NewPackage)
    flds = fieldnames(pkg)
    params = chop(repeat("?,", length(flds)))
    stmt = SQLite.Stmt(db, "insert into packages values (?,?,?,?,?)")
    for (i, fld) in enumerate(flds)
        SQLite.bind!(stmt, i, getfield(pkg, fld))
    end
    SQLite.execute!(stmt)
end

function insert_packages(pkgs::Vector{NewPackage})
    db = SQLite.DB(DB_PATH)
    ensure_packages_table(db)
    for pkg in pkgs
        insert_package(db, pkg)
    end
end


function save_packages(pkgs::Vector{NewPackage})
    db = SQLite.DB(DB_PATH)
    ensure_packages_table(db)
    df = to_dataframe(pkgs)
    SQLite.load(db, "packages", df)
end

function load_packages()
    db = SQLite.DB(DB_PATH)
    try
        df = SQLite.query(db, "select * from packages")
        return from_dataframe(df)
    catch ex
        # table doesn't exist
        if isa(ex, SQLite.SQLiteException)
            return NewPackage[]
        else
            throw(ex)
        end
    end

end
