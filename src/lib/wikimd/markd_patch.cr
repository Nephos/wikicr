require "markd"

module WikiMarkd
  module Rule
    WIKI_TAG = /^<<[[:graph:] ]+>>/i
  end

  class Parser::Inline < ::Markd::Parser::Inline
    # patch the autolink <...> to add new tags
    private def auto_link(node : ::Markd::Node)
      # puts "> Parser::Inline.auto_link Here you go <"
      if text = match(Rule::WIKI_TAG)
        node.append_child(wiki(text))
      else
        super
      end
    end

    private def wiki(text : String) : ::Markd::Node
      # puts "> Parser::Inline.wiki Here you go <"
      node = ::Markd::Node.new(::Markd::Node::Type::Link)
      node.data["title"] = "tiiitle"
      node.data["destination"] = "http://test.cr"
      node.append_child(text(text[2..-3]))
      node
    end
  end

  class Parser::Block < ::Markd::Parser::Block
    def initialize(@options : Options)
      # puts "> Parser::Block.new Here you go <"
      super
      @inline_lexer = Parser::Inline.new(@options)
    end
  end

  class Options < ::Markd::Options
    property page_index : Hash(String, String)? # TODO

    def initialize(
      @time = false,
      @gfm = false,
      @toc = false,
      @smart = false,
      @source_pos = false,
      @safe = false,
      @prettyprint = false,
      @base_url = nil,
      @page_index = nil
    )
      # puts "> Options.new Here you go <"
    end
  end

  module Parser
    include ::Markd::Parser

    def self.parse(source : String, options = Options.new)
      # puts "> Parser#parse Here you go <"
      Block.parse(source, options)
    end
  end

  include Markd

  def self.to_html(source : String, options = Options.new)
    # puts "> Markd#to_html Here you go <"
    return "" if source.empty?
    document = Parser.parse(source, options)
    renderer = HTMLRenderer.new(options)
    renderer.render(document)
  end
end
