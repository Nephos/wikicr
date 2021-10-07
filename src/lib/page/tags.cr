class Wikicr::Page
  module TagsReader
    def parse_tags!(index : Index)
      Wikicr::MarkdPatch.to_html(input: self.read, index: index, context: self, parse_tags: true)
    end

    # def self.all(path : String) : Index::Entry::Tags
    #   Index::Entry::Tags.new
    # end
  end
end
