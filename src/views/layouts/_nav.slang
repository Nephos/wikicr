/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav class="navbar navbar-default"
  .col-xs-6
    .pull-left
      - if user_signed_in?
        a.btn.btn-md href="/" = current_user.name
      a.btn.btn-md href="/" Home
      a.btn.btn-md href="/sitemap" Sitemap
      - if !user_signed_in?
        a.btn.btn-md href="/users/register" Register
        a.btn.btn-md href="/users/login" Login
      - if Wikicr::ACL.permitted?(current_user, "/admin/users", Acl::Perm::Read)
        a.btn.btn-md href="/admin/users" Users
      - if Wikicr::ACL.permitted?(current_user, "/admin/acls", Acl::Perm::Read)
        a.btn.btn-md href="/admin/acls" ACLs
  .col-xs-6
    .pull-right
      form#search-page action="/pages/search" method="get" role="form"
        .input-group.input-group-md
          input.input-md.form-control name="q" placeholder="Search query" autocomplete="on" list="search-list"
          datalist#search-list
            - Wikicr::PAGES.entries.values.each do |entry|
              option value=entry.url = entry.title
          span.input-group-btn
            button.btn.btn-md
              span.glyphicon.glyphicon-search
              | Search

nav(aria-label="breadcrumb")
  ol.breadcrumb
    li.breadcrumb-item.active
      | History
    - history.each do |page_url|
      li.breadcrumb-item
        a href=page_url
          - root_page = Wikicr::Page.new "/"
          = Wikicr::PAGES.load!.one_by_url(page_url[7..-1], root_page).title
