require "yaml"

require "./index/entry"

# And Index is an object that associate a file with a lot of meta-data
# like related url, the title, the table of content, ...
struct Wikicr::Page
  class Index < Lockable
    include YAML::Serializable
    property file : String
    property entries : Hash(String, Entry) # path, entry
    property find_index : Hash(String, String)
    property find_tags : Hash(String, Array(String))

    def initialize(@file : String)
      @entries = {} of String => Entry
      @find_index = Hash(String, String).new
      @find_tags = Hash(String, Array(String)).new
    end

    # Find a matching *text* into the Index.
    # If no matching content, return a default value.
    def one_by_title_or_url(text : String, context : Page) : Index::Entry
      found = find_by_title(text, context) || find_by_url(text, context)
      if found.nil?
        STDERR.puts "warning: no page \"#{text}\" found"
        Index::Entry.new(
          title: text,
          url: "#{context.real_url_dirname}/#{Entry.title_to_slug text}",
          path: "#{context.dirname}/#{Entry.title_to_slug text}.md",
        )
      else
        return found
      end
    end

    # Find a specific url into the Index.
    # If no matching content, return a default value.
    # If the page is not found, the title of the entry will be the default_title or the url
    def one_by_url(url : String, context : Page, default_title : String? = nil) : Index::Entry
      found = find_by_url(url, context)
      if found.nil?
        STDERR.puts "warning: no page \"#{url}\" found"
        Index::Entry.new(
          title: default_title || url,
          url: "#{context.real_url_dirname}/#{Entry.title_to_slug url}",
          path: "#{context.dirname}/#{Entry.title_to_slug url}.md",
        )
      else
        return found
      end
    end

    # Find a matching *text* into the Index.
    # If no matching content, return a default value.
    # def all_by_tag(tag : String, context : Page) : Array(Page)
    #   found = find_tags[tag]? || [] of String
    # end

    # Find the closest `Index`' `Entry` to *text* based on the entries title
    # and searching for the closer url as possible to the context
    private def find_by_title(text : String, context : Page) : Entry?
      # exact_matched = @entries.select{|_, entry| entry.title == text }.values
      # return choose_closer_url(exact_matched, context) unless exact_matched.empty?
      slug_matched = @entries.select { |_, entry|
        entry.slug == Index::Entry.title_to_slug(text)
      }.values
      return choose_closer_url(slug_matched, context) unless slug_matched.empty?
      nil
    end

    # Find the url which is the closest as possible than the context url (start with the maxmimum common chars).
    private def choose_closer_url(entries : Array(Entry), context : Page) : Entry
      raise "Cannot handle empty array" if entries.empty?
      entries.reduce { |lhs, rhs| Index.url_closeness(context.url, lhs.url) >= Index.url_closeness(context.url, rhs.url) ? lhs : rhs }
    end

    # Computes the amount of common chars at the beginning of each string
    def self.url_closeness(from : String, to : String)
      from.size.times do |i|
        return i if from[i] != to[i]
      end
      return from.size
    end

    private def find_by_url(text : String, context : Page) : Entry?
      slug_matched = @entries.select { |_, entry|
        entry.url == Index::Entry.title_to_slug(text)
      }.values
      return choose_closer_url(slug_matched, context) unless slug_matched.empty?
      nil
    end

    # Add a new `Entry`.
    def [](page : Wikicr::Page) : Index::Entry
      @entries[page.path]
    end

    # Add a new `Entry`.
    def []?(page : Wikicr::Page) : Index::Entry?
      @entries[page.path]?
    end

    # Add a new `Entry`.
    def add(page : Wikicr::Page)
      @entries[page.path] = Entry.new page.path, page.url, page.title, toc: true
      self
    end

    # Remove an `Entry` from the `Index` based on its path.
    def delete(page : Wikicr::Page)
      @entries.delete page.path
      self
    end

    # Replace the old Index using the state registrated into the *file*.
    def load!
      if File.exists?(@file) && (new_index = Index.read(@file) rescue nil)
        @entries = new_index.entries
        # @file = index.file
      else
        @entries = {} of String => Entry
      end
      self
    end

    def self.read(file : String)
      Index.from_yaml File.read(file)
    end

    # Save the current state into the file
    def save!
      File.write @file, self.to_yaml
      self
    end
  end
end
