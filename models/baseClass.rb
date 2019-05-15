require 'sequel'

class BaseClass

  # Setups a connection to a postgres database
  #
  # @return [@db] Returns the connection to the database
  def self.db
    @db ||= Sequel.connect('postgres://ormuser:ormpassword@localhost/ormtest')
  end

  # Declares tablename
  #
  # Example: 
  #   Post.table_name( "posts" ) 
  #   #=> nil
  # 
  # @param table_name [String] is just the table name
  # @return [nil]
  def self.table_name(table_name)
    @table_name = table_name
    return nil
  end
  
  # Stores all the column names for a table and the column type
  #
  # @param hash [Hash] the column name and type
  def self.column(hash)
    @columns ||= {}
    @columns.merge!(hash)
    attr_reader hash.keys.first
  end
  
  # Creates the a table if said table does not exists
  #
  # Example: 
  #   Post.create_table( false ) 
  #   #=> nil
  # 
  # @param use_row_id [Boolean] if you want the databae to create a
  #   id column or if you created one yourself
  # @return [nil]
  def self.create_table(use_row_id)
    start_query = "CREATE TABLE IF NOT EXISTS #{@table_name}("
    columns_query = self.join_columns(@columns, use_row_id)

    final_query = start_query + columns_query
    db.run(final_query)
    @columns = {}
    return nil
  end

  # Creates a sql query for the columns and its types
  #
  # Example: 
  #   Post.join_columns( { :id=>"serial", :title=>"text", :content=>"text" }, false ) 
  #   #=> "id serial PRIMARY KEY,name text,yeet text,score integer)"
  #
  # @param hash [Hash] is the hash of all columns and its types.
  # @param use_row_id [Boolean] if you want the databae to create a
  #   id column or if you created one yourself.
  # @return [String] is the final query for the columns.
  def self.join_columns(hash, use_row_id)
    final_string = ""
    i = 0
    hash.each_pair do |key,value|
      if !use_row_id && i == 0
        final_string += "#{key.to_s} #{value} PRIMARY KEY,"
      else
        final_string += "#{key.to_s} #{value},"
      end
      i += 1
    end
    final_string = final_string[0..-2] + ")"
    return final_string
  end

  # Creates a query to insert new values into the right table
  # It then executes that query
  #
  # Example:
  #   Post.insert({ title: "Yoo", content: "The boy said Yooo." })
  #   #=> True
  #
  # @param hash [Hash] of the values that will be inserted
  # @return [Boolean]
  def self.own_insert(hash)
    result = extract_values(hash)
    values = []
    columns = []
    query_values = ""
    eval_string = "db[query,"
    if result
      values = result[0]
      columns = result[1]
    else
      return false
    end

    query = "INSERT INTO #{@table_name} ("
    columns.each do |column|
      query += column + ','
    end

    query = query[0..query.length-2] 
    query += ") VALUES ("
    values.each_with_index do |value, index|
      query += "?" + ','
      query_values += "values[#{index}],"
    end

    eval_string += query_values
    eval_string = eval_string[0..eval_string.length-2] + "]"

    query = query[0..query.length-2] 
    query += ');'
       
    evaled = eval(eval_string)
    evaled.insert

    return true
  end

  # Separates the value from the key and add them to an array
  #
  # Example:
  #   Fruit.extract_values( {"name"=>"Bob", "yeet"=>"Good", "score"=>"99"} )
  #   #=> ["Bob", "Good", "99"], ["name", "yeet", "score"]
  # @param hash [Hash] of the values that will be inserted
  # @return [Array] columns
  # @return [Array] values
  def self.extract_values(hash)
    columns = []
    values = []
    hash.each_pair do |key,value|
      if value.is_a? Array
        columns << key.to_s
      else
        columns << key.to_s
        values << value
      end
    end
    return values, columns
  end

  # If the values are successfully inserted then it creates a new instance of the class
  #
  # Example:
  #   Post.create( {"title"=>"THis is the tile", "content"=>"and this is the content"} )
  #   #=> #<Post:0x00007f9e7ac4d338 @title="THis is the tile", @content="and this is the content">
  #
  # @param params [Hash] is the params returned from the form
  def self.create(params)
    if own_insert(params)
      self.new(params)
    end
  end

  # Creates a query that returns all the rows from a specified table and then executes the query
  #
  # Example:
  #   Post.all()
  #   #=> #<Sequel::Postgres::Dataset: "SELECT * FROM posts">
  #
  # @return [Dataset]
  def self.all() 
    query = "SELECT * FROM #{@table_name}"
    db[query]
  end

  # Finds a specific row in a table
  #
  # Example:
  #   Post.find(1)
  #   #=> #<Sequel::Postgres::Dataset: "SELECT * FROM posts WHERE id = 1">
  #
  # @param id [Integer]
  # @return [Dataset]
  def self.find(id)
    id = id.to_s
    query = "SELECT * FROM #{@table_name} WHERE id = ?"
    db[query, id]
  end

  # Builds a query that updates a specefic row and then executes it
  #
  # Example:
  #   Post.update( { id: 1, title: "Yoo", content: "The boy said Yooo."} )
  #   #=> nil
  #
  # @param params [Hash] are all the values from the form
  def self.update(params)
    id_query = ""
    query = "UPDATE #{@table_name} SET "
    params.each do |param|
      if param[0] == "id"
        id_query = " WHERE id = #{param[1]}"
      else
        query += param[0] + " = " + "'" + param[1] + "'" + ", "
      end
    end
    query = query[0..query.length-3] 
    query = query + id_query
    p query
    db.run(query)
  end

  # Deletes an row from the table
  #
  # Example:
  #   Post.destroy( { id: 1 } )
  #   #=> nil
  #
  # @param params [Hash] is just the id
  def self.destroy(params)
    query = "DELETE FROM #{@table_name} WHERE id = #{params[:id]}"
    db.run(query)
  end

end