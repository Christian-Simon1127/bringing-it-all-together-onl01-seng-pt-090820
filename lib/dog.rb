class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end
  
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
    DB[:conn].execute("DROP TABLE dogs;")
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update 
    sql = <<-SQL
    UPDATE dogs SET dogs.name = ?, dogs.breed = ? WHERE dogs.id = ?;
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save 
    if self.id 
      self.update
    else 
      sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   end
   self
  end
  
  def self.create(attributes)
    dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
    dog.save 
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      temp_dog = dog[0]
      dog = Dog.new(id: temp_dog[0], name: temp_dog[1], breed: temp_dog[2])
    else
      dog = Dog.new(name: name, breed: breed)
    end
    
  end
  
end