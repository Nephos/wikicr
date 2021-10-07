require "markd"
require "../page/index"

module Wikicr::MarkdPatch
  module Rule
    WIKI_TAG_OPENNER = /(\{\{|<<)/
    WIKI_TAG_CLOSER  = /(\}\}|>>)/

    # default must be matched last because it matches all the other tags
    WIKI_TAG = {
      autolink: /^#{WIKI_TAG_OPENNER}(link:)([[:graph:] ]+)#{WIKI_TAG_CLOSER}/i,
      tag:      /^#{WIKI_TAG_OPENNER}(tag:)([[:graph:] ]+)#{WIKI_TAG_CLOSER}/i,
      table:    /^#{WIKI_TAG_OPENNER}(table:)([[:graph:] ]+)#{WIKI_TAG_CLOSER}/i,
      default:  /^#{WIKI_TAG_OPENNER}([[:graph:] ]+)#{WIKI_TAG_CLOSER}/i,
    }
  end

  class Parser::Inline < ::Markd::Parser::Inline
    # patch the autolink <...>
    # if we match a wiki tag use it, else we can fallback on default markdown behavior
    private def auto_link(node : ::Markd::Node)
      # puts "> Parser::Inline.auto_link Here you go <"
      begin
        wiki_tag(node, raise_when_no_match: true)
      rescue
        super
      end
    end

    # generate a wiki tag if matching a rule
    private def wiki_tag(node : ::Markd::Node, raise_when_no_match : Bool = false)
      if text = match(Rule::WIKI_TAG[:tag])
        node.append_child(wiki_keyword(text))
      elsif text = match(Rule::WIKI_TAG[:autolink])
        node.append_child(wiki_internal_link(text))
      elsif text = match(Rule::WIKI_TAG[:default])
        node.append_child(wiki_internal_link(text, prefix: 0))
      else
        raise "No Match" if raise_when_no_match
        node
      end
    end

    # generate a keyword to group pages
    # TODO: link to a wiki page that generate a list of all pages using this keyword
    private def wiki_keyword(text : String, prefix : Int = 4) : ::Markd::Node
      # puts "> Parser::Inline.wiki Here you go <"
      input_tags = text[(2 + prefix)..-3].strip
      tags_node = ::Markd::Node.new(::Markd::Node::Type::HTMLInline)
      input_tags.split(' ').each do |input_tag|
        puts "page context.tags = #{page_context.tags}"
        page_context.tags << input_tag
        puts "added << #{input_tag}, now #{page_context.tags}"
        tags_node.text += "<a class=\"badge badge-primary\" href=\"/tags/#{input_tag}\">#{input_tag}</a>"
      end
      tags_node.text += "\n"

      tags_node
    end

    # generate an internal link using the page_index to find a page
    # the page is related to the page context (option of the parser)
    # if the page is not found it will link to a new page based on the find algorithm
    private def wiki_internal_link(text : String, prefix : Int = 5) : ::Markd::Node
      # puts "> Parser::Inline.wiki Here you go <"
      input_text = text[(2 + prefix)..-3]
      input_array = input_text.split('|', 2)
      target_page =
        if input_array.size == 2
          # we have a {{title|url}}
          input_title = input_array[0]
          input_url = input_array[1]
          page_index.one_by_url input_url, page_context, input_title
        else
          # we have a {{title}} only
          page_index.one_by_title_or_url input_text, page_context
        end
      node = ::Markd::Node.new(::Markd::Node::Type::Link)
      node.data["title"] = target_page.title
      node.data["destination"] = target_page.url
      node.append_child(text(target_page.title))
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
    property parse_tags : Bool

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
      @page_context = nil,
      @parse_tags = false
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

  def self.to_html(source : String, options = Options.new) : String
    return "" if source.empty?
    document = Parser.parse(source, options)
    renderer = HTMLRenderer.new(options)
    renderer.render(document)
  end

  def self.to_html(
    input : String,
    context : Wikicr::Page,
    index : Wikicr::Page::Index,
    parse_tags : Bool = false
  ) : String
    context.tags = [] of String # reset the tags first
    to_html(
      input,
      Options.new(page_index: index, page_context: context, parse_tags: parse_tags),
    )
  end
end
