require "./options"

module Wikicr::Git
  extend self

  # Initialize the data repository (where the pages are stored).
  def init!
    Dir.mkdir_p Wikicr::OPTIONS.basedir
    current = Dir.current
    Dir.cd Wikicr::OPTIONS.basedir
    `git init .`
    Dir.cd current
  end

  # Save the modifications on the *file* into the git repository
  # TODO: lock before commit
  # TODO: security of jailed_file and self.name ?
  def commit!(user : Wikicr::User, message, files : Array(String) = [] of String)
    dir = Dir.current
    begin
      Dir.cd Wikicr::OPTIONS.basedir
      puts `git add -- #{files.join(" ")}`
      puts `git commit --no-gpg-sign --author "#{user.name} <#{user.name}@localhost>" -m "#{message}" -- #{files.join(" ")}`
    ensure
      Dir.cd dir
    end
  end
end

Wikicr::Git.init!
