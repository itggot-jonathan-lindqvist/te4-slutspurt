require 'sequel'

class BaseClass


  def self.db
    @db ||= Sequel.connect('postgres://ormuser:ormpassword@localhost/ormtest')
  end

  def self.table_name(table_name)
    @table_name = table_name
    return nil
  end
  
  def self.column(hash)
    @columns ||= {}
    @columns.merge!(hash)
    attr_reader hash.keys.first
  end
  
  def self.create_table(use_row_id)
    start_query = "CREATE TABLE IF NOT EXISTS #{@table_name}("
    columns_query = self.join_columns(@columns, use_row_id)

    final_query = start_query + columns_query
    db.run(final_query)
    return nil
  end

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

  def self.extract_values(hash)
    columns = []
    values = []
    hash.each_pair do |key,value|
      if value.is_a? Array
        columns << key.to_s
        result = self.valid_requirements?(value[1][:requirements], key.to_s, value.first, values)
        if result.is_a? Array
          values = result[1]
        elsif result
          values << value[0]
        else
          return false
        end

      else
        columns << key.to_s
        values << value
      end
    end
    return values, columns
  end

  # TODO: change so it can be used by all models
  def save(title, content)
    db.run("INSERT INTO posts (title, content) VALUES (?, ?)", title, content)
  end

  def self.create(params)
    if insert(params)
      self.new(params)
    end
  end

  #Item.all({color: red}) { {join: 'manufacturer'}}
  #def self.all(hash = {})
  def self.all() 
    query = "SELECT * FROM #{@table_name}"
    db[query]
  end

  # def self.drop
  #   db.run("DROP TABLE posts")
  # end

  def self.find(id)
    id = id.to_s
    query = "SELECT * FROM #{@table_name} WHERE id = #{id}"
    db[query]
  end

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

  def self.destroy(params)
    query = "DELETE FROM #{@table_name} WHERE id = #{params[:id]}"
    db.run(query)
  end

end