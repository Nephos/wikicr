require "./errors"
require "./sfile"

# A Page is a file and an url part
# Is is used to jail files into the OPTIONS.basedir
struct Wikicr::Page
  getter file : String
  getter name : String

  def initialize(@name)
    @file = Page.name_to_file(@name)
  end

  # translate a name ("/test/title" for example)
  # into a file path ("/srv/data/test/ttle.md)
  def self.name_to_file(name : String)
    File.expand_path(name + ".md", Wikicr::OPTIONS.basedir)
  end

  # :unused:
  # # translate a file into a name
  # # @see #name_to_file
  # def self.file_to_name(file : String)
  #   file.chomp(".md")[Wikicr::OPTIONS.basedir.size..-1]
  # end

  # :unused:
  # # set a new file name, an update the file path
  # def name=(name)
  #   @name = name
  #   @file = Page.name_to_file @name
  # end

  # :unused:
  # # set a new file path, and update the file name
  # def file=(file)
  #   @file = File.expand_path file
  #   @name = Page.file_to_name @file
  # end

  # verify if the file is in the current dir (avoid ../ etc.)
  def jail(user : User)
    chroot = Wikicr::OPTIONS.basedir
    # TODO: consider security of ".git/"
    # TODO: read ACL for user

    # the @file is already expanded (File.expand_path) in the constructor
    if chroot != @file[0..(chroot.size - 1)]
      raise Error403.new "Out of chroot (#{@file} on #{chroot})"
    end
    self
  end

  def dirname
    File.dirname self.file
  end

  def read(user : User)
    self.jail user
    File.read self.file
  end

  def write(body, user : User)
    self.jail user
    Dir.mkdir_p self.dirname
    File.write self.file, body
    commit!(user)
  end

  private def commit!(user)
    puts "---------------  COMMIT ! ------------"
    # You can check git_repository_head_unborn() to see if HEAD points at a reference or not.
    tree_id = Pointer(LibGit2::Oid).null
    parent_id = Pointer(LibGit2::Oid).null
    commit_id = Pointer(LibGit2::Oid).null
    tree = nil.as(LibGit2::X_Tree)
    parent = nil.as(LibGit2::X_Commit)
    index = nil.as(LibGit2::X_Index)

    puts "repository_index"
    puts LibGit2.repository_index(pointerof(index), Wikicr::Git.repo)
    pp index, index.address, index.value
    puts "index_write_tree"
    puts LibGit2.index_write_tree(tree.as(Pointer(LibGit2::Oid)), index)
    pp tree

    puts "reference_name_to_id"
    puts LibGit2.reference_name_to_id(parent_id, Wikicr::Git.repo, "HEAD")
    puts "commit_lookup"
    puts LibGit2.commit_lookup(pointerof(parent), Wikicr::Git.repo, parent_id)

    sign = Pointer(LibGit2::Signature).null
    puts "signature_now"
    puts LibGit2.signature_now(pointerof(sign), user.name, "#{user.name}@localhost")

    puts "commit_create"
    puts LibGit2.commit_create(commit_id, Wikicr::Git.repo, "HEAD", sign, sign, "UTF-8", "update #{self.name}", tree.value, 1, pointerof(parent))
  end

  def delete(user : User)
    self.jail user
    File.delete self.file
  end

  def exists?(user : User)
    self.jail user
    File.exists? self.file
  end
end
