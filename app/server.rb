require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require 'sinatra/activerecord'

#uso esto para cargar todos los modelos
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

class App < Sinatra::Application
  enable :sessions
  set :session_secret, 'a8c9fbd7c52e145ab67dcfae2378c99a4e761b6e34899c021d8fa1ce75cb68f1cbd7ea8cfb2e7a1ee5c9b7c3643c3a8a'

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

  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !current_user.nil?
    end
  end
    
  get '/' do
    erb :login, layout: false
  end

  post '/' do
    username = params[:username]
    password = params[:password]
    @user = User.find_by(username: username, password: password)

    if @user
      session[:user_id] = @user.id
      redirect '/home'
    else
      @error = "Usuario o contraseña incorrectos"
      erb :login, layout: false
    end
  end

  get '/home' do
    if current_user
      erb :home
    else
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/register' do
    erb :register, layout: false
  end
    
  post '/register' do
    begin
      ActiveRecord::Base.transaction do
        person = Person.create!(
          dni: params[:dni],
          first_name: params[:first_name],
          last_name: params[:last_name],
          birth_date: params[:birth_date],
          phone: params[:phone],
          email: params[:email],
        )
        user = User.create!(
          username: params[:username],
          password: params[:password],
          admin_check: false,
          person: person
        )
        ts = Time.current.strftime('%Y%m%d%H%M%S%6N')
        Account.create!(
          alias: params[:first_name] + params[:dni] + "P",
          cvu: ts + params[:dni],
          balance: 0,
          amount_point: 0,
          coin: "Peso",
          status: "Activo",
          level: "1",
          user: user
        )
      end
      redirect '/'
    rescue ActiveRecord::RecordInvalid => e
      @error = "Error al registrar: #{e.message}"
      erb :register, layout: false
    end
    
  end

  get '/income' do
    erb :income
  end

  post '/income' do
    if current_user
      account = current_user.accounts.first
      movement = Movement.new(
        amount: params[:amount].to_f,
        date: Time.now,
        movement_type: "Ingreso",
        status: "Pendiente",
        reason: nil,
        origin: account,
        destination: nil,
        history: account,
        user: nil
      )
      if movement.save
        @message = "Ingreso generado correctamente, espere a ser autorizado"
        erb :income
      else
        @error = "Error: no se pudo procesar el ingreso"
        erb :income
      end
    else
      redirect '/'
    end
  end

  get '/manage_incomes' do
    # Verifico que el usuario sea admin
    halt(403, "No autorizado") unless current_user&.admin_check

    @notice = session.delete(:notice)
    @notice = session.delete(:error)

    @movements = Movement.where(movement_type: "Ingreso", status: "Pendiente").order(date: desc)
    @notice = session.delete(:notice)

    erb :manage_incomes
  end

  post 'manage_incomes/:id/accept' do
    # Verifico que el usuario sea admin
    halt(403, "No autorizado") unless current_user&.admin_check

    movement = Movement.find(params[:id])
    if movement && movement.status == "Pendiente" && movement.movement_type == "Ingreso"
      movement.update(status: "Exitosa")
      account = movement.origin
      account.balance += movement.amount
      account.save!
    end

    #Muestro un mensaje que determina que la operacion fue exitosa
    session[:notice] = "Ingreso aprobado. Balance actualizado. Muchas gracias por su paciencia."
  
    redirect '/manage_incomes'
  end

  post 'manage_incomes/:id/reject' do
    # Verifico que el usuario sea admin
    halt(403, "No autorizado") unless current_user&.admin_check

    movement = Movement.find(params[:id])
    if movement && movement.status == "Pendiente" && movement.movement_type == "Ingreso"
      movement.update(status: "Rechazada")
      session[:notice] = "Ingreso rechazado"
    else
      session[:error] = "No se pudo rechazar el ingreso"
    end
  
    redirect '/manage_incomes'
  end

  get '/new_saving' do
    erb :new_saving
  end
    
  post '/new_saving' do
    if current_user
    account = current_user.accounts.first
    
    saving = Saving.new(
      description: params[:description],
      goal_amount: params[:goal_amount].to_f,
      account: account
    )
    if saving.save
      "Ahorro creado correctamente"
    else
      "Error: no se pudo crear el ahorro"
    end
    else
      redirect '/'
    end
  end

  get '/my_saving' do
    if current_user
      account = current_user.accounts.first
      @savings = account.savings
      erb :my_saving
    else
      redirect '/'
    end
  end

  get '/add_to_saving/:id' do
    if current_user
      @saving = Saving.find(params[:id])
      if @saving.account.user == current_user
        @account = @saving.account
        erb :add_to_saving
      else
        "No tenés permiso para acceder a este ahorro."
      end
    else
      redirect '/'
    end
  end

  get '/add_to_saving/:id' do
    if current_user
      @saving = Saving.find(params[:id])
      if @saving.account.user == current_user
        @account = @saving.account
        erb :add_to_saving
      else
        "No tenés permiso para acceder a este ahorro."
      end
    else
      redirect '/'
    end
  end

  post '/confirm_add_to_saving/:id' do
    if current_user
      saving = Saving.find(params[:id])
      account = saving.account

      if account.user == current_user
        amount = params[:amount].to_f

        if amount <= 0
          "El monto debe ser mayor a cero."
        elsif amount > account.balance
          "No tenés suficiente saldo en la cuenta."
        elsif amount > saving.goal_amount
          "Superarías la meta del ahorro."
        else
          # Restar a la cuenta y sumar al ahorro
          account.balance -= amount
          saving.current_amount += amount

          if saving.save && account.save
            redirect '/my_saving'
          else
            "Error al guardar los cambios."
          end
        end
      else
        "No tenés permiso para modificar este ahorro."
      end
    else
      redirect '/'
    end
  end

end
