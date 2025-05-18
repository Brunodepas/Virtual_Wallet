require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require 'sinatra/activerecord'

#uso esto para cargar todos los modelos
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

class App < Sinatra::Application
    configure :development do
        enable :logging
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG if development?
        set :logger, logger

        set :views, File.expand_path('../views', __FILE__)


        register Sinatra::Reloader
        after_reload do
            logger.info 'Reloaded!!!'
        end
    end
    
    get '/' do
        "KickStart"
    end
    
    get '/register' do
        erb :register
    end
    
    post '/register' do
        person = Person.new(
            dni: params[:dni],
            first_name: params[:first_name],
            last_name: params[:last_name],
            birth_date: params[:birth_date],
            phone: params[:phone],
            email: params[:email],
        )
        if person.save
            user = User.new(
                username: params[:username],
                password: params[:password],
                admin_check: false,
                person: person
            )
            if user.save
                ts = Time.current.strftime('%Y%m%d%H%M%S%6N')
                account = Account.new(
                    alias: params[:first_name] + params[:dni] + "P",
                    cvu: ts + params[:dni],
                    balance: 0,
                    amount_point: 0,
                    coin: "Peso",
                    status: "Activo",
                    level: "1",
                    user: user
                )
                if account.save
                    redirect '/'
                else
                    "Error cuenta"
                end
            else
                "Error usuario"
            end
        else
            "Error persona"
        end
    end

end
