require "../table_of_content"
require "../../lockable"

# And Index is an object that associate a file with a lot of meta-data
# like related url, the title, the table of content, ...
struct Wikicr::Page
  class Index < Lockable
    class Entry
      include YAML::Serializable
      property path : String  # path of the file /srv/wiki/data/xxx
      property url : String   # real url of the page /pages/xxx
      property title : String # Any title
      property slug : String  # Exact matching title
      property toc : Page::TableOfContent::Toc
      property tags : Array(String)

      def initialize(@path, @url, @title, toc : Bool = false)
        @slug = Entry.title_to_slug title
        @toc = toc ? Page::TableOfContent.toc(@path) : Page::TableOfContent::Toc.new
        # @intlinks = Page::InternalLinks::LinkList.new
        @tags = [] of String
      end

      def self.title_to_slug(title : String) : String
        title.gsub(/[^[:alnum:]^\/]/, "-").gsub(/-+/, '-').downcase
      end
    end
  end
end
