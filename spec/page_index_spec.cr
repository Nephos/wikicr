describe Wikicr::Page::Index do
  it "test basic" do
    index = Wikicr::Page::Index.new(file: "placeholder")
    page = Wikicr::Page.new ""

    entries = [] of Wikicr::Page::Index::Entry
    entries << Wikicr::Page::Index::Entry.new "path 1", "url 1", "title 1"
    entries << Wikicr::Page::Index::Entry.new "path 2", "url 2", "title 2"
    entries << Wikicr::Page::Index::Entry.new "path 3", "url 3", "Title 3"
    entries << Wikicr::Page::Index::Entry.new "path 4", "url 4", "Title 3"

    index.entries["page 1"] = entries[0]
    index.entries["page 2"] = entries[1]
    index.entries["page 3"] = entries[2]
    index.entries["page 4"] = entries[3]

    title2 = index.one_by_title_or_url "title 2", page
    url2 = index.one_by_title_or_url "url 2", page
    urlnil = index.one_by_title_or_url "url nil", page

    title2.should eq entries[1]
    url2.should eq entries[1]
    urlnil.should eq nil
  end
end
