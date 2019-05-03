class Post < BaseClass
  puts "reeeee"
  table_name("posts")
  column(id: "serial")
  column(title: "text")
  column(content: "text")

  create_table(false)
  #attr_reader :title, :content

  def initialize(title, content)
    @title = title
    @content = content
  end
  
end