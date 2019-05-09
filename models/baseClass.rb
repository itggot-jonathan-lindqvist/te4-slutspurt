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
  # @param table_name [String] is just the table name, ex: posts
  # @return [nil]
  def self.table_name(table_name)
    @table_name = table_name
    return nil
  end
  
  # Stores all the column names for a table and the column type
  #
  # @param hash [Hash] the column name and type, ex: title: "text"
  def self.column(hash)
    @columns ||= {}
    @columns.merge!(hash)
    attr_reader hash.keys.first
  end
  
  # Creates the a table if said table does not exists
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
  # @param hash [Hash] of the values that will be inserted, ex: { title: "Yoo", content: "The boy said Yooo." }
  # @return [Boolean]
  def self.insert(hash)
    result = extract_values(hash)
    values = []
    columns = []
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
    values.each do |value|
      query += "'" + value + "'" + ','
    end

    query = query[0..query.length-2] 
    query += ')'
    db.run(query)
    return true
  end

  # Separates the value from the key and add them to an array
  #
  # @param hash [Hash] of the values that will be inserted, ex: { title: "Yoo", content: "The boy said Yooo." }
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
  # @param params [Hash] is the params returned from the form
  def self.create(params)
    if insert(params)
      self.new(params)
    end
  end

  # Creates a query that returns all the rows from a specified table and then executes the query
  #
  # @return [Dataset]
  def self.all() 
    query = "SELECT * FROM #{@table_name}"
    db[query]
  end

  # Finds a specific row in a table
  #
  # @param id [Integer]
  # @return [Dataset]
  def self.find(id)
    id = id.to_s
    query = "SELECT * FROM #{@table_name} WHERE id = #{id}"
    db[query]
  end

  # Builds a query that updates a specefic row and then executes it
  #
  # @param params [Hash] are all the values from the form, ex:  { id: 1, title: "Yoo", content: "The boy said Yooo."}
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
    db.run(query)
  end

  # Deletes an row from the table
  #
  # @param params [Hash] is just the id
  def self.destroy(params)
    query = "DELETE FROM #{@table_name} WHERE id = #{params[:id]}"
    db.run(query)
  end

end