# mdwikiface

Wiki in crystal and markdown

The pages of the wiki are written in markdown and commited on the git repository where it is started.

## Installation

    make

## Usage

    mdwikiface --help
      -b HOST, --bind HOST             Host to bind (defaults to 0.0.0.0)
      -p PORT, --port PORT             Port to listen for connections (defaults to 3000)
      -s, --ssl                        Enables SSL
      --ssl-key-file FILE              SSL key file
      --ssl-cert-file FILE             SSL certificate file
      -h, --help                       Shows this help

## Development

  * [x] (core) View wiki pages
  * [x] (core) Write new wiki page, edit existing ones
  * [x] (core) Chroot the files to data/: avoid writing / reading files outside of data/
  * [ ] (web)  Configuration page: title of the wiki, rights of the files, etc. should be configurable
  * [ ] (git)  Commit when write on a file: every modification on data/ should be commited
  * [ ] (web)  User login / registration: keep a file with login:group:bcryptpassords
  * [ ] (web)  User LDAP basic (read / write): the groups have rights on directories
  * [ ] (core) Delete pages: remove the content of a page should remove the file
  * [ ] (core) Index of pages (page h1 for + url): each modification of a page should update the index
  * [ ] (edit) Handle `[[tag]]`: markdown extended to search in the page index (url and title)
  * [ ] (web)  Search a page: an input that search a page (content, title) with autocompletion
  * [x] (core) If page does not exists, form to create it: if a file does not exist, display the edit form
  * [ ] (core) Move page (rename): box with "mv X Y" and git commit
  * [ ] (web)  Tags for pages (index): extended markdown and index to keep a list of pages
  * [ ] (core) Extensions loader (.so files + extended markdown ?): extend the wiki features with hooks
  * [ ] (web)  Template loader (files in public/): load css, js etc. from public/
  * [ ] (web)  File upload and lists: page that add a file in uploads/
  * [ ] (git)  List of revisions on a file (using git): list the revision of a file
  * [ ] (git)  Revert a revision (avoid vandalism): button to remove a revision (git revert)
  * [ ] (core) Choose between sqlite3 and the filesystem for the index: sqlite = sql, fs = easier

## Contributing

1. Fork it ( https://github.com/Nephos/mdwikiface/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - creator, maintainer
