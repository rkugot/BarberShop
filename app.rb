#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

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

post '/visit' do
	
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

	hh = { :username => 'Введите имя',
		   :phone => 'Введите телефон', 
		   :datetime => 'Введите дату и время'}

	@error = hh.select{|key,value| params[key] == ''}.values.join(', ') 

	if @error != ''
		return erb :visit
	end

	f = File.open("./public/users.txt","a")
	f.write("Имя: #{@username}, телефон: #{@phone}, записан на #{@date} к #{@barber}, цвет краски: #{@color}\n")
	f.close

	erb "#{@username}, Вы записаны на #{@datetime} к мастеру #{@barber}, цвет краски: #{@color}"
end

post '/contacts' do

	@email = params[:email]
	@message = params[:message]

	hh = { :email => 'Введите email', :message => 'Введите сообщение'}
	@error = hh.select{|key,value| params[key] == ''}.values.join(', ')
	if @error != ''
		return erb :contacts
	end

	Pony.mail(
	  :mail => params[:email],
	  :body => params[:message],
	  :to => 'stream13k@gmail.com',
	  :subject => "Sinatra has contacted you",
	  :body => params[:message],
	  :port => '587',
	  :via => :smtp,
	  :via_options => { 
	    :address              => 'smtp.gmail.com', 
	    :port                 => '587', 
	    :enable_starttls_auto => true, 
	    :user_name            => 'stream13k', 
	    :password             => 'qwe7891', 
	    :authentication       => :plain, 
	    :domain               => 'localhost.localdomain'
	  })


	erb "Ваше сообщение отправлено"

end