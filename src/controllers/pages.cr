before_all "/pages/*" do |env|
  if false
    puts "You are authenticated"
  else
    puts "You are not authenticated"
  end
end

private def fetch_params(env)
  path = env.params.url["path"]
  {
    path:         path,                        # basic path from the params unmodified
    file_path:    Mdwikiface::Page.jail(path), # jail the path (safety)
    display_path: path,                        # TODO: clean the path
    title:        path.split("/").last,        # keep only the name of the file
  }
end

macro render_page(page)
  render {{ "src/views/pages/" + page + ".html.slang" }}, "src/views/layout.html.slang"
end

require "markdown"
get "/pages/*path" do |env|
  locals = fetch_params(env).to_h
  locals[:body] = (File.read(locals[:file_path]) rescue "")
  puts "File.read #{locals[:file_path]}"
  if (env.params.query["edit"]?) || !File.exists?(locals[:file_path])
    render_page("edit")
  else
    locals[:body_html] = Markdown.to_html(locals[:body])
    render_page("show")
  end
end

post "/pages/*path" do |env|
  locals = fetch_params(env).to_h
  if (env.params.body["body"]?)
    Dir.mkdir_p(File.dirname(locals[:file_path]))
    File.write locals[:file_path], env.params.body["body"]
    puts "File.write #{locals[:file_path]}, ..."
    env.redirect "/pages/#{locals[:path]}"
  else
    File.delete locals[:file_path] rescue nil
    env.redirect "/pages/README"
  end
end
