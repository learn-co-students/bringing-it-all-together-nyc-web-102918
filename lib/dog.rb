class Dog
	def self.create_table
		DB[:conn].execute(<<-SQL
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			) 
			SQL
		)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS dogs")
	end

	def self.create(name:, breed:)
		dog = self.new(name: name, breed: breed)

		dog.save
	end

	def self.find_by_id(id)
		DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
			self.new_from_db(row)
		end.first
	end

	def self.find_or_create_by(name:, breed:)
		data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
		unless data.empty?
			dogdat = data[0]
			dog = self.new(id: dogdat[0], name: dogdat[1], breed: dogdat[2])
		else
			dog = self.create(name: name, breed: breed)
		end

		dog
	end

	def self.new_from_db(row)
		self.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(name)
		DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
			self.new_from_db(row)
		end.first
	end

	attr_accessor  :name, :breed
	attr_reader :id

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	def save
		if self.id
			self.update
		else
			DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?, ?)", self.name, self.breed)

			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end

		self
	end

	def update
		DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
	end
end