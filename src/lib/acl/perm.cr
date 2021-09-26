# Permission levels of the Acl system.
#
# The values are ordered and hide a bitmask (read=1, write=2, read+write=3) but for simplicity at usage,
# since nothing can have the value 2, we don't explicitly have a write-only value at 2.
enum Acl::Perm
  # level 0. Cannot read, cannot write.
  None = 0

  # level 1. Can read, cannot write.
  Read = 1

  # level 3. Can read, can write.
  Write = 3
end
