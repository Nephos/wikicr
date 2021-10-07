describe Wikicr::Page do
  it "test basic" do
    page = Wikicr::Page.new(url: "home", real_url: false, parse_title: false)
    page.url.should eq "home"
    page.real_url.should eq "/pages/home"
    page.path.should eq File.expand_path("data/home.md")
  end

  it "test another basic" do
    page = Wikicr::Page.new(url: "/pages/home", real_url: true, parse_title: false)
    page.url.should eq "home"
    page.real_url.should eq "/pages/home"
    page.path.should eq File.expand_path("data/home.md")
  end
end
