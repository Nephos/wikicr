require "../table_of_content"
require "../../lockable"

# And Index is an object that associate a file with a lot of meta-data
# like related url, the title, the table of content, ...
struct Wikicr::Page
  class Index < Lockable
    class Entry
      alias Tag = String
      alias Tags = Array(Tag)

      include YAML::Serializable
      property path : String  # path of the file /srv/wiki/data/xxx
      property url : String   # real url of the page /pages/xxx
      property title : String # Any title
      property slug : String  # Exact matching title
      property toc : Page::TableOfContent::Toc
      property tags : Tags

      def initialize(@path, @url, @title, toc : Bool = false, @tags : Tags = Tags.new)
        @slug = Entry.title_to_slug title
        @toc = toc ? Page::TableOfContent.toc(@path) : Page::TableOfContent::Toc.new
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
        title.gsub(/[^[:alnum:]^\/]/, "-").gsub(/-+/, '-').downcase
      end
    end
  end
end
