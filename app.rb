#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?',[name]).length > 0
end

def seed_db db, barbers

	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute('insert into Barbers (name) values (?)',[barber])
		end
	end

end

def get_db
	db = SQLite3::Database.new('barbershop.db')
	db.results_as_hash = true
	return db
end

before do
	db = get_db
	@barbers = db.execute("select * from Barbers")
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"username" TEXT,
			"phone" TEXT,
			"datestamp" TEXT,
			"barber" TEXT,
			"color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"name" TEXT
		)'

	seed_db db, ['Jessie Pinkman','Waler White','Gus Fring','Mike Ehrmantraut']	
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/showusers' do
	db = get_db
	@results = db.execute("select*from Users order by id desc")
	erb :showusers
end

post '/visit' do
	
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

	hh = { :username => 'Введите имя',
		   :phone => 'Введите телефон', 
		   :datetime => 'Введите дату и время',
		   }

	@error = hh.select{|key,value| params[key] == ''}.values.join(', ') 

	if @barber == 'Выберите парикмахера из списка'
		@error = @error + ", Выберите парикмахера"
	end

	if @error != ''
		return erb :visit
	end

	db = get_db
	db.execute('insert into Users (username, phone, datestamp, barber, color) 
		values (?,?,?,?,?)',[@username, @phone, @datetime, @barber, @color])

	erb "<h2>Спасибо #{@username}, Вы записались</h2>"
end

post '/contacts' do

	@email = params[:email]
	@message = params[:message]

	hh = { :email => 'Введите email', :message => 'Введите сообщение'}
	@error = hh.select{|key,value| params[key] == ''}.values.join(', ')
	if @error != ''
		return erb :contacts
	end

	Pony.mail({
	:from => params[:email],
    :to => 'stream13k@gmail.com',
    :subject => params[:email] + " has contacted you via the Website",
    :body => params[:message],
    :via => :smtp,
    :via_options => {
     :address              => 'smtp.gmail.com',
     :port                 => '587',
     :enable_starttls_auto => true,
     :user_name            => 'stream13k@gmail.com',
     :password             => '*********',
     :authentication       => :plain, 
     :domain               => "localhost.localdomain" 
     }
    })

	erb "Ваше сообщение отправлено"
end