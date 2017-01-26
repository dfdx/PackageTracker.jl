
using LightXML


const DATE_FORMAT = "e, dd u yyyy HH:MM:SS"

function create_rss(pkgs::Vector{NewPackage})
    doc = XMLDocument()
    root = create_root(doc, "rss")
    set_attribute(root, "xmlns:content",
                  "http://purl.org/rss/1.0/modules/content/")
    set_attribute(root, "version", "2.0")
    channel = new_child(root, "channel")
    title = new_child(channel, "title")
    add_cdata(doc, title, "Julia: New Shiny Packages")
    link = new_child(channel, "link")
    add_text(link, "http://TODO")
    description = new_child(channel, "description")
    add_text(description, "Julia packages recently added to METADATA.jl")
    pub_date = new_child(channel, "pubDate")
    add_text(pub_date, Dates.format(Dates.now(), DATE_FORMAT))
    for pkg in pkgs
        add_item!(doc, channel, pkg)
    end
    xml = string(doc)
    free(doc)
    return xml
end


function add_item!(doc::XMLDocument, channel::XMLElement, pkg::NewPackage)
    item = new_child(channel, "item")
    title = new_child(item, "title")
    add_cdata(doc, title, pkg.name)
    author = new_child(item, "author")
    add_text(author, pkg.author)
    pub_date = new_child(item, "pubDate")
    add_text(pub_date, Dates.format(pkg.pubdate, DATE_FORMAT))
    link = new_child(item, "link")
    add_text(link, pkg.url)
    description = new_child(item, "description")
    add_cdata(doc, description, pkg.description)
end
