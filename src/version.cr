module Wikicr
  VERSION = {{ `git tag|sort -h`.split("\n")[-2] }}
end
