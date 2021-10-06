page = Wikicr::Page.new ""

describe Wikicr::Page::Index do
  it "one by title or url" do
    index = Wikicr::Page::Index.new(file: "placeholder")

    index.entries["page1"] = Wikicr::Page::Index::Entry.new path: "path1", url: "url1", title: "title1"
    index.entries["page2"] = Wikicr::Page::Index::Entry.new path: "path2", url: "url2", title: "title2"
    index.entries["page3"] = Wikicr::Page::Index::Entry.new path: "path3", url: "url3", title: "Title3"
    index.entries["page4"] = Wikicr::Page::Index::Entry.new path: "path4", url: "url4", title: "Title3"

    title2 = index.one_by_title_or_url text: "title2", context: page
    title2.should eq index.entries["page2"]

    url2 = index.one_by_title_or_url text: "url2", context: page
    url2.should eq index.entries["page2"]

    urlnil = index.one_by_title_or_url text: "urlnil", context: page
    index.entries.each { |_, entry| urlnil.should_not eq(entry) }
  end

  it "all by tags" do
    index = Wikicr::Page::Index.new(file: "placeholder")
    index.entries["entry1"] = Wikicr::Page::Index::Entry.new(
      path: "path 1",
      url: "url 1",
      title: "title 1",
      tags: ["tag1", "tag12", "tag13", "tag14"]
    )
    index.entries["entry2"] = Wikicr::Page::Index::Entry.new(
      path: "path 2",
      url: "url 2",
      title: "title 2",
      tags: ["tag12"]
    )
    index.entries["entry3"] = Wikicr::Page::Index::Entry.new(
      path: "path 3",
      url: "url 3",
      title: "title 3",
      tags: ["tag13", "tag134"]
    )
    index.entries["entry4"] = Wikicr::Page::Index::Entry.new(
      path: "path 4",
      url: "url 4",
      title: "title 4",
      tags: ["tag14", "tag134"]
    )

    expected = {"entry1" => index.entries["entry1"]}
    index.all_by_tags(tags_line: "tag1", context: page).should eq(expected)

    expected = {"entry1" => index.entries["entry1"], "entry2" => index.entries["entry2"]}
    index.all_by_tags(tags_line: "tag12", context: page).should eq(expected)

    expected = {"entry2" => index.entries["entry2"]}
    index.all_by_tags(tags_line: "tag12 -tag1", context: page).should eq(expected)

    expected = {"entry1" => index.entries["entry1"]}
    index.all_by_tags(tags_line: "tag12 +tag13", context: page).should eq(expected)

    expected = {"entry1" => index.entries["entry1"], "entry2" => index.entries["entry2"], "entry3" => index.entries["entry3"]}
    index.all_by_tags(tags_line: "tag12 tag13", context: page).should eq(expected)
  end
end
