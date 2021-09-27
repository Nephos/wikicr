require "markd"
require "../page/index"

module WikiMarkd
  module Rule
    WIKI_TAG = {
      autolink: /^<<([[:graph:] ]+)>>/i,
      default:  /^\{\{([[:graph:] ]+)\}\}/i,
    }
  end

  class Parser::Inline < ::Markd::Parser::Inline
    # patch the autolink <...> to add new tags
    private def auto_link(node : ::Markd::Node)
      # puts "> Parser::Inline.auto_link Here you go <"
      if text = match(Rule::WIKI_TAG[:autolink])
        node.append_child(wiki_internal_link(text))
      else
        super
      end
    end

    private def wiki_tag(node : ::Markd::Node)
      if text = match(Rule::WIKI_TAG[:default])
        node.append_child(wiki_internal_link(text))
      end
    end

    private def wiki_internal_link(text : String) : ::Markd::Node
      # puts "> Parser::Inline.wiki Here you go <"
      input_title = text[2..-3]
      target_page = page_index.find input_title, page_context
      node = ::Markd::Node.new(::Markd::Node::Type::Link)
      node.data["title"] = target_page[0]
      node.data["destination"] = target_page[1]
      node.append_child(text(target_page[0]))
      node
    end

    # rewrite to add {
    private def process_line(node : Node)
      char = char_at?(@pos)

      return false unless char && char != Char::ZERO

      res = case char
            when '\n'
              newline(node)
            when '\\'
              backslash(node)
            when '`'
              backtick(node)
            when '*', '_'
              handle_delim(char, node)
            when '\'', '"'
              @options.smart? && handle_delim(char, node)
            when '['
              open_bracket(node)
            when '!'
              bang(node)
            when ']'
              close_bracket(node)
            when '<'
              auto_link(node) || html_tag(node)
            when '&'
              entity(node)
            when '{'
              wiki_tag(node) || string(node)
            else
              string(node)
            end

      unless res
        @pos += 1
        node.append_child(text(char))
      end

      true
    end

    # rewritte to add {
    private def main_char?(char)
      case char
      when '\n', '`', '[', ']', '\\', '!', '<', '&', '*', '_', '\'', '"', '{'
        false
      else
        true
      end
    end

    def page_index
      @options.as(Options).page_index
    end

    def page_context
      @options.as(Options).page_context
    end
  end

  class Parser::Block < ::Markd::Parser::Block
    def initialize(@options : Options)
      super(@options)
      @inline_lexer = Parser::Inline.new(@options.as(Options))
    end
  end

  class Options < ::Markd::Options
    property page_index : Wikicr::Page::Index
    property page_context : Wikicr::Page

    def initialize(
      @time = false,
      @gfm = false,
      @toc = false,
      @smart = false,
      @source_pos = false,
      @safe = false,
      @prettyprint = false,
      @base_url = nil,
      @page_index = nil,
      @page_context = nil
    )
    end
  end

  module Parser
    include ::Markd::Parser

    def self.parse(source : String, options = Options.new)
      Block.parse(source, options)
    end
  end

  include Markd

  def self.to_html(source : String, options = Options.new)
    return "" if source.empty?
    document = Parser.parse(source, options)
    renderer = HTMLRenderer.new(options)
    renderer.render(document)
  end
end
