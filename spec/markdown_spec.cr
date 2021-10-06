describe Wikicr::MarkdPatch do
  page = Wikicr::Page.new "", real_url: false
  index = Wikicr::Page::Index.new "/tmp/specs.index.yaml"

  it "basic markd patching" do
    raw = "hello <<test1>>"
    html = %Q{<p>hello <a href="/test1" title="tiiitle">test1</a></p>\n}
    Wikicr::MarkdPatch.to_html(raw, page, index).should eq(html)
  end

  it "wiki tag markd patching" do
    raw = "hello {{test2}}"
    html = %Q{<p>hello <a href="/test2" title="tiiitle">test2</a></p>\n}
    Wikicr::MarkdPatch.to_html(raw, page, index).should eq(html)
  end
end
