class Post < BaseClass
  puts "reeeee"
  table_name("posts")
  column(id: "integer")
  column(title: "text")
  column(content: "text")

  create_table(false)
  p "reeeee2"
  attr_reader :title, :content

  def initialize(title, content)
    @title = title
    @content = content
  end

  def self.save(title, content)
    @db.run("INSERT INTO posts (title, content) VALUES (?, ?)", title, content)
  end

  def self.create(title, content)
    if insert({ title: title,
                content: content }
      new(title, content)
    end
  end
end