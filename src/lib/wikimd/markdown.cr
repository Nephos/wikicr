require "markd"
require "./render"
require "../page"

struct Wikicr::Markdown
  # ```
  # Page::Markdown.to_html("Test of [[internal-link]]", current_page, index_of_internal_links)
  # ```
  def self.to_html(input : String, context : Page, index : Page::Index) : String
    ::WikiMarkd.to_html(
      input,
      ::WikiMarkd::Options.new(page_index: index, page_context: context),
    )
  end
end
