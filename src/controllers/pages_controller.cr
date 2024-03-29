require "./application_controller"
require "../lib/wikimd/*"

class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    pages = Wikicr::FileTree.build Wikicr::OPTIONS.basedir
    render "sitemap.slang"
  end

  # get /pages/search?q=
  def search
    query = params.query["q"]
    page = Wikicr::Page.new(query)
    # TODO: a real search
    redirect_to query.empty? ? "/pages/home" : page.real_url
  end

  # get /pages/*path
  def show
    acl_permit! :read
    flash["danger"] = params.query["flash.danger"] if params.query["flash.danger"]?
    page = Wikicr::Page.new url: params.url["path"], parse_title: true
    if (params.query["edit"]?) || !page.exists?
      show_edit(page)
    else
      show_show(page)
    end
  end

  private def show_edit(page)
    body = page.read rescue ""
    flash["info"] = "The page #{page.url} does not exist yet." if !page.exists?
    acl_permit! :write
    render "edit.slang"
  end

  private def show_show(page)
    index = Wikicr::PAGES.load!
    body_html = Wikicr::MarkdPatch.to_html(input: page.read, index: index, context: page)

    groups_read = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Read, true
    groups_write = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Write, true
    history << page
    render "show.slang"
  end

  # post /pages/*path
  def update
    acl_permit! :write
    page = Wikicr::Page.new url: params.url["path"], parse_title: true
    if params.body["rename"]?
      update_rename(page)
    elsif (params.body["body"]?.to_s.empty?)
      update_delete(page)
    else
      update_edit(page)
    end
  end

  private def update_rename(page)
    if !params.body["new_path"]?.to_s.strip.empty?
      # TODO: verify if the user can write on new_path
      # TODO: if new_path do not begin with /, relative rename to the current path
      renamed_page = page # will be change in the transaction
      Wikicr::PAGES.transaction! do |index|
        index.delete page
        renamed_page = page.rename current_user, params.body["new_path"]
        renamed_page.parse_tags! index
        index.add renamed_page
      end
      flash["success"] = "The page #{page.url} has been moved to #{renamed_page.url}."
      redirect_to renamed_page.real_url # "/pages/#{params.body["new_path"]}"
    else
      redirect_to page.real_url
    end
  end

  private def update_delete(page)
    begin
      Wikicr::PAGES.transaction! { |index| index.delete page }
      page.delete current_user
      flash["success"] = "The page #{page.url} has been deleted."
      redirect_to "/pages/home"
    rescue err
      # TODO: what if the page is not deleted but not indexed anymore ?
      # Wikicr::PAGES.transaction! { |index| index.add page }
      flash["danger"] = "Error: cannot remove #{page.url}, #{err.message}"
      redirect_to page.real_url
    end
  end

  private def update_edit(page)
    begin
      page.write current_user, params.body["body"]
      page.parse_title!
      Wikicr::PAGES.transaction! do |index|
        page.parse_tags! index
        index.add page
      end
      flash["success"] = "The page #{page.url} has been updated."
      redirect_to page.real_url
    rescue err
      flash["danger"] = "Error: cannot update #{page.url}, #{err.message}"
      redirect_to page.real_url
    end
  end
end
