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

end
