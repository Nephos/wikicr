require "./options"

module Wikicr::Git
  extend self
  @@repo = nil.as(LibGit2::X_Repository)

  def repo
    @@repo
  end

  def init!
    puts "------------ INIT ! -----------------"

    pp Wikicr::OPTIONS.basedir
    pp Wikicr::Git.repo
    pp Wikicr::Git.repo.address
    pp Wikicr::Git.repo.value

    Dir.mkdir_p Wikicr::OPTIONS.basedir
    # TODO: check result
    if LibGit2.repository_open(pointerof(@@repo), Wikicr::OPTIONS.basedir) != 0
      LibGit2.repository_init(pointerof(@@repo), Wikicr::OPTIONS.basedir, 0)
    end

    pp Wikicr::OPTIONS.basedir
    pp Wikicr::Git.repo
    pp Wikicr::Git.repo.address
    pp Wikicr::Git.repo.value
  end
end

Wikicr::Git.init!
require "./users"
Wikicr::Page.new("testX").write("OK", Wikicr::USERS.read!.find("arthur.poulet@mailoo.org"))
