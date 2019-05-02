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

  
  def save(title, content)
    db.run("INSERT INTO posts (title, content) VALUES (?, ?)", title, content)
  end

  def self.create(title, content)
    if insert({ title: title, content: content })
      self.new(title, content)
    end
  end

  #Item.all({color: red}) { {join: 'manufacturer'}}
  def self.all(hash = {}) 
    query = "SELECT * FROM posts"
    db.run(query)
  end

  def self.drop
    db.run("DROP TABLE posts")
  end

  def self.show
    db["SELECT * FROM posts WHERE title = 'fak'"]
  end
end