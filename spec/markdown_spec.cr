describe Wikicr::MarkdPatch do
  page = Wikicr::Page.new "", real_url: false
  index = Wikicr::Page::Index.new "/tmp/specs.index.yaml"

  it "basic markd patching" do
    raw = "hello <<test1>>"
    html = %Q{<p>hello <a href="/test1" title="test1">test1</a></p>\n}
    Wikicr::MarkdPatch.to_html(raw, page, index).should eq(html)
  end

  it "wiki tag markd patching" do
    raw = "hello {{test2}}"
    html = %Q{<p>hello <a href="/test2" title="test2">test2</a></p>\n}
    Wikicr::MarkdPatch.to_html(raw, page, index).should eq(html)

    raw = "hello {{title 2|test2}}"
    html = %Q{<p>hello <a href="/test2" title="title 2">title 2</a></p>\n}
    Wikicr::MarkdPatch.to_html(raw, page, index).should eq(html)
  end
end
