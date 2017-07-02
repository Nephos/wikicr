require "./options"

module Wikicr
  REPO = Git::Repo.open(Wikicr::OPTIONS.basedir)

  extend self

  def repo
    REPO
  end

  def init!
  end
end

require "./users"
Wikicr::Page.new("testX").write("OK", Wikicr::USERS.read!.find("arthur"))
