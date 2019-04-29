require 'sequel'

class BaseClass

  def self.table_name(table_name)
    @table_name = table_name
    return nil
  end
  
  def self.column(hash)
    @columns ||= {}
    @columns.merge!(hash)
  end
  
  def self.create_table(use_row_id)
    p "fuck"
    @db ||= Sequel.connect('postgres://ormuser:ormpassword@localhost/ormtest')
    p @db
    p "rhenjlwq"
    start_query = "CREATE TABLE IF NOT EXISTS #{@table_name}("
    columns_query = self.join_columns(@columns, use_row_id)

    final_query = start_query + columns_query
    p final_query
    @db.run(final_query)
    return nil
  end

  def self.join_columns(hash, use_row_id)
    final_string = ""
    i = 0
    hash.each_pair do |key,value|
      p key
      p value
      if !use_row_id && i == 0
        final_string += "#{key.to_s} #{value} PRIMARY KEY,"
      else
        final_string += "#{key.to_s} #{value},"
      end
      i += 1
    end
    final_string = final_string[0..-2] + ")"
    p final_string
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

    columns_query = ""
    columns.each do |column|
        columns_query += column + ','
    end
    columns_query = columns_query[0..columns_query.length-2]
    start_query = "INSERT INTO #{@table_name}(" + columns_query + ') '
    values_query = "VALUES("
    values.each do |value|
        values_query += '?,'
    end
    values_query[values_query.length-1] = ')'
    final_query = start_query + values_query
    p final_query
    p values
    @db.execute(final_query, values)
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

end