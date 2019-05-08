class Fruit < BaseClass
  table_name("fruits")
  column(id: "serial")
  column(name: "text")
  column(yeet: "text")
  column(score: "integer")

  create_table(false)

  def initialize(hash)
    @name = hash[:name]
    @yeet = hash[:yeet]
    @score = hash[:score]
  end
  
end