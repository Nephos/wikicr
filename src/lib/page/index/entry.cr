require "../table_of_content"
require "../tags"
require "../../lockable"

# And Index is an object that associate a file with a lot of meta-data
# like related url, the title, the table of content, ...
class Wikicr::Page
  class Index < Lockable
    class Entry
      alias Tag = String
      alias Tags = Array(Tag)

      include YAML::Serializable
      property path : String  # path of the file /srv/wiki/data/xxx
      property url : String   # real url of the page /pages/xxx
      property title : String # Any title
      property slug : String  # Exact matching title
      property toc : Page::TableOfContentReader::Toc
      property tags : Tags

      def initialize(@path, @url, @title, @tags : Tags = Tags.new, read_toc : Bool = false)
        @slug = Entry.title_to_slug title
        @toc = read_toc ? Page::TableOfContentReader.toc(@path) : Page::TableOfContentReader::Toc.new
      end

      def self.from_context(context : Page, title : String, url : String? = nil)
        url = url || title
        new(
          title: title,
          url: File.join(context.real_url_dirname, Entry.title_to_slug(url)),
          path: File.join(context.dirname, "#{Entry.title_to_slug(url)}.md"),
        )
      end

      def self.title_to_slug(title : String) : String
        title.gsub(/[\s\.]/, '-').gsub(/-+/, '-').downcase
      end
    end
  end
end
