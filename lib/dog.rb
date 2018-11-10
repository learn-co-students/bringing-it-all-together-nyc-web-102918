require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name=hash[:name]
    @id=hash[:id]
    @breed=hash[:breed]
  end

  def self.create_table
  sql= <<-SQL
  CREATE TABLE dogs(
  id INTEGER PRIMARY KEY,
  name TEXT,
  breed TEXT
  )
  SQL
  DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    hash={id: row[0], name: row[1], breed: row[2]}
    Dog.new(hash)
  end


  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * from dogs WHERE name = ?
    SQL
    record=DB[:conn].execute(sql, name)
    self.new_from_db(record.flatten)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * from dogs WHERE id = ?
    SQL
    record=DB[:conn].execute(sql, id)
    self.new_from_db(record.flatten)
  end

  def self.find_or_create_by(hash)
    sql="SELECT * from dogs WHERE name = ? AND breed = ? LIMIT 1"

    found=DB[:conn].execute(sql,hash[:name],hash[:breed])[0]
    if found
      new_from_db(found)
    else
      create(hash)
    end
  end


def self.create(hash)
  Dog.new(hash).save
end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      id=DB[:conn].execute("SELECT id from dogs ORDER BY id DESC limit 1")
      self.id=id[0][0]
      self
    else
      update
    end

  end

  def update
    sql="UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed,self.id)
    self
  end






end
