require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require 'sinatra/activerecord'
require 'securerandom'
require 'pony'

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
    set :public_folder, 'public'



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
    @custom_css = "/css/login.css"
    erb :login, layout: :header
  end

  post '/' do
    username = params[:username]
    password = params[:password]
    @user = User.find_by(username: username)

    #como estamos usando bcrypt tengo que usar un metodo para encontrar la contraseña ya que no se guarda en texto plano
    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      redirect '/home'
    else
      @error = "Usuario o contraseña incorrectos"
      @custom_css = "/css/login.css"
      erb :login, layout: :header
    end
  end

  get '/home' do
  if current_user
    @account = current_user.accounts.first
    @movements = Movement
      .where("origin_id = :id OR destination_id = :id", id: @account.id)
      .where(status: ['Pendiente', 'Exitosa'])
      .order(created_at: :desc)
      .limit(8)
    @account_discounts = @account.discounts 
    @account_promos = @account.promos 
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
    @custom_css = "/css/register.css"
    erb :register, layout: :header
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
          alias: (params[:first_name] + params[:dni] + "P").gsub(" ", ""),
          cvu: ts + params[:dni],
          balance: 0,
          amount_point: 0,
          coin: "Peso",
          status: "Activo",
          level: "1",
          user: user
        )
      end
      @message = "Cuenta creada con exito"
      @custom_css = "/css/login.css"
      erb :login, layout: :header
    rescue ActiveRecord::RecordInvalid
      @error = "Error al registrarse"
      @custom_css = "/css/register.css"
      erb :register, layout: :header
    end
    
  end

  get '/income' do
    if current_user
      @message = session.delete(:message)
      @custom_css = "/css/income.css"
      erb :income
    else
      redirect '/'
    end
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
        session[:message] = "Ingreso generado correctamente, espere a ser autorizado"
        @custom_css = "/css/income.css"
        redirect '/income'
      else
        @error = "Error: no se pudo procesar el ingreso"
        @custom_css = "/css/income.css"
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
    @error = session.delete(:error)

    @movements = Movement.where(movement_type: "Ingreso", status: "Pendiente").order(date: :desc)
    @notice = session.delete(:notice)

    erb :manage_incomes
  end

  post '/manage_incomes/:id/accept' do
    
    halt(403, "No autorizado") unless current_user&.admin_check

    Movement.transaction do
      movement = Movement.lock.find(params[:id]) # bloqueo fila para evitar race conditions

      if movement.status == "Pendiente" && movement.movement_type == "Ingreso"
        movement.update!(status: "Exitosa")
        session[:notice] = "Ingreso aprobado. Balance actualizado."
      else
        session[:error] = "El ingreso ya fue procesado."
      end
    end

    redirect '/manage_incomes'

  end

  post '/manage_incomes/:id/reject' do
    puts "Intentando rechazar movimiento #{params[:id]}"
    halt(403, "No autorizado") unless current_user&.admin_check

    movement = Movement.find(params[:id])
    puts "Movimiento encontrado: status=#{movement.status.inspect}, tipo=#{movement.movement_type.inspect}"

    if movement && movement.status == "Pendiente" && movement.movement_type == "Ingreso"
      if movement.update(status: "Rechazada")
        session[:notice] = "Ingreso rechazado"
      else
        session[:error] = "No se pudo rechazar el ingreso (update falló)"
      end
    else
      session[:error] = "No se pudo rechazar el ingreso (condición no cumplida)"
    end

    redirect '/manage_incomes'
  end

  get '/manage_discounts' do
    @discounts = Discount.all
    erb :manage_discounts
  end

  post '/manage_discounts' do
    Discount.create(
      description: params[:description],
      cost: params[:cost],
      percentage: params[:percentage]
    )
    redirect '/manage_discounts'
  end

  post '/manage_discounts/:id/delete' do
    discount = Discount.find(params[:id])
    discount.destroy
    redirect '/manage_discounts'
  end

  get '/manage_promos' do
    @promos = Promo.all
    erb :manage_promos
  end

  post '/manage_promos' do
    Promo.create(
      description: params[:description],
      cost: params[:cost],
      end_date: params[:end_date]
    )
    redirect '/manage_promos'
  end

  post '/manage_promos/:id/delete' do
    promo = Promo.find(params[:id])
    promo.destroy
    redirect '/manage_promos'
  end

  get '/transfer' do
    redirect '/' unless logged_in?
    @accounts = current_user.accounts
    @account = @accounts.first #Tomo la primera cuenta del usuario, modificar para dar listado en la view
    erb :transfer
  end

  post '/transfer' do
    redirect '/' unless logged_in?
    @accounts = current_user.accounts 
    @account = @accounts.first 

    #Obtenés las cuentas por ID que viene del form
    origin = Account.find_by(id: params[:origin_id])
     destination = Account.find_by(alias: params[:destination]) || Account.find_by(cvu: params[:destination])
    amount = params[:amount].to_f
    reason = params[:reason]

    # Verificación de seguridad: la cuenta origen debe pertenecer al usuario logueado
    unless origin && current_user.accounts.include?(origin)
      @error = "Cuenta de origen inválida o no autorizada."
      return erb :transfer
    end

    if destination.nil?
      @error = "Cuenta de destino no encontrada."
      return erb :transfer
    end

    if amount <= 0
      @error = "El monto debe ser mayor a cero."
      return erb :transfer
    end

    begin
      Movement.transfer(origin: origin, destination: destination, amount: amount, reason: reason)
      redirect '/home'
    rescue => e
      @error = "Error en la transferencia: #{e.message}"
      erb :transfer
    end
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
        session[:message] = "Ahorro creado!"
                redirect '/my_saving'

    else
      @error = "Error: no se pudo crear el ahorro"
        erb :new_saving
    end
    else
      redirect '/'
    end
  end

  get '/my_saving' do
    if current_user
      account = current_user.accounts.first
      @savings = account.savings
      @message = session.delete(:message)

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
      @saving = Saving.find(params[:id])
      @account = @saving.account

      if @account.user == current_user
        amount = params[:amount].to_f

        if amount <= 0
          @error = "El monto debe ser mayor a cero."
        erb :add_to_saving
        elsif amount > @account.balance
          @error = "No tenés suficiente saldo en la cuenta."
        erb :add_to_saving
        elsif @saving.current_amount + amount > @saving.goal_amount
          @error = "Superarías la meta del ahorro."
        erb :add_to_saving

        else
          @account.balance -= amount
          @saving.current_amount += amount

          if @saving.save && @account.save
            @success = "Se agregó correctamente al ahorro."
          erb :add_to_saving
          else
            @error = "Error al guardar los cambios."
          erb :add_to_saving

          end
        end
      else
        "No tenés permiso para modificar este ahorro."
      end
    else
      redirect '/'
    end
  end

post '/my_saving/:id/redeem' do
  if current_user
    saving = Saving.find(params[:id])
    account = saving.account

    if account.user_id == current_user.id
        account.balance += saving.current_amount

        if account.save
          saving.destroy
          session[:message] = "Ahorro recuperado exitosamente"
        else
          session[:message] = "Error al transferir el dinero."
        end
    else
      session[:message] = "No tenés permiso para acceder a este ahorro."
    end

    redirect '/my_saving'
  else
    redirect '/'
  end
  end



  get '/forgot' do
    @custom_css = "/css/forgot.css"
    erb :forgot, layout: :header
  end

  post '/forgot' do
    email = params[:email]
    user = User.joins(:person).find_by(people: {email: email})

    if user
      codigo = rand(100000..999999).to_s
      session[:codigo] = codigo
      session[:user_id] = user.id
      begin
        Pony.mail(
          to: email,
          subject: "Código de recuperación",
          body: "Tu código de recuperación es: #{codigo}",
          via: :smtp,
          via_options: {
            address: 'smtp.gmail.com',
            port: '587',
            enable_starttls_auto: true,
            user_name: 'winkfinanzas@gmail.com',
            password: 'ueqn loyv ytdr civd',
            authentication: :plain,
            domain: "localhost.localdomain"
          }
        )
        redirect '/verify_code'
      rescue => e
        logger.error "Error al enviar correo: #{e.message}"
        @error = "No se pudo enviar el correo. Intente más tarde."
        @custom_css = "/css/forgot.css"
        erb :forgot, layout: :header
      end
    end
  end

  get '/verify_code' do
    @custom_css = "/css/verify_code.css"
    erb :verify_code, layout: :header
  end

  post '/verify_code' do
    if params[:code] == session[:codigo]
      @custom_css = "/css/reset_password.css"
      redirect '/reset_password'
    else
      @error = "Codigo incorrecto"
      @custom_css = "/css/verify_code.css"
      redirect '/verify_code'
    end
  end

  get '/reset_password' do
    @custom_css = "/css/reset_password.css"
    erb :reset_password, layout: :header
  end

  post '/reset_password' do
    user = User.find_by(id: session[:user_id])
    if user
      user.update(password: params[:password])
      session.clear
      @message = "Contraseña restablecida con exito"
      redirect '/'
    else
      @error = "Hubo un problema"
      @custom_css = "/css/forgot.css"
      redirect '/forgot'
    end
  end

  get '/promos' do
    redirect '/' unless logged_in?
    account = current_user.accounts.first
    @purchased_promos = account.promos
    @available_promos = Promo.where.not(id: @purchased_promos.pluck(:id))
    @message = session.delete(:message)
    erb :promos
  end

  post '/promos/:id/comprar' do
    promo = Promo.find(params[:id])
    account = current_user.accounts.first
  
    if account.promos.include?(promo)
      session[:message] = promo.description + " - Ya compraste esta promo."
    elsif account.amount_point < promo.cost
      session[:message] = "No tenés suficientes puntos."
    else
      # Realizar la compra
      account.promos << promo
      account.update(amount_point: account.amount_point - promo.cost)
      session[:message] = "Promo comprada exitosamente."
    end
    redirect '/promos'
  end

  post '/promos/:id/usar' do
    promo = Promo.find(params[:id])
    account = current_user.accounts.first
  
    if account.promos.include?(promo)
      account.promos.destroy(promo)
      session[:message] = "Promoción usada con éxito."
    else
      session[:message] = "No tenés esta promoción."
    end
  
    redirect '/promos'
  end

  get '/discounts' do
    redirect '/' unless logged_in?
    account = current_user.accounts.first
    @purchased_discounts = account.discounts
    @available_discounts = Discount.where.not(id: @purchased_discounts.pluck(:id))
    @message = session.delete(:message)
    erb :discounts
  end

  post '/discounts/:id/comprar' do
    discount = Discount.find(params[:id])
    account = current_user.accounts.first
  
    if account.discounts.include?(discount)
      session[:message] = discount.description + "Ya compraste este descuento."
    elsif account.amount_point < discount.cost
      session[:message] = "No tenés suficientes puntos."
    else
      # Realizar la compra
      account.discounts << discount
      account.update(amount_point: account.amount_point - discount.cost)
      session[:message] = "Descuento comprado exitosamente."
    end
    redirect '/discounts'
  end
  
  post '/discounts/:id/usar' do
    discount = Discount.find(params[:id])
    account = current_user.accounts.first
  
    if account.discounts.include?(discount)
      account.discounts.destroy(discount)
      session[:message] = "Descuento usado con éxito."
    else
      session[:message] = "No tenés este descuento."
    end
  
    redirect '/discounts'
  end

  get '/exchange' do
    if current_user
      @message = session.delete(:message)
      erb :exchange
    else
      redirect '/'
    end
  end


  post '/exchange' do
    if current_user
      account = current_user.accounts.first
      points = account.amount_point
      amount = params[:amount].to_f
      if amount > 0 && points >= amount
        account.update(amount_point: account.amount_point - amount)
        account.update(balance: account.balance + (amount*100)/1000)
        @message = "Intercambio generado correctamente"
        erb :exchange
      else
        @error = "Error: no se pudo procesar el intercambio"
        erb :exchange
      end
    else
      redirect '/'
    end
  end

  get '/config' do
    redirect '/' unless logged_in?
    @messageDelete = session.delete(:messageDelete)
    @messageEdit = session.delete(:messageEdit)
    @custom_css = "/css/config.css"
    erb :config
  end

  post '/config' do
    redirect '/' unless logged_in?
  
    user = current_user
    if user.admin_check == false
      person = user.person
      account = user.accounts.first
  
      begin
        ActiveRecord::Base.transaction do
          # Solo actualizar si hay un valor nuevo
          person.phone = params[:phone] unless params[:phone].to_s.strip.empty?
          person.email = params[:email] unless params[:email].to_s.strip.empty?
          user.username = params[:username] unless params[:username].to_s.strip.empty?
          unless params[:password].to_s.strip.empty?
            user.password = params[:password]
          end
          account.alias = params[:alias] unless params[:alias].to_s.strip.empty?
  
          person.save!
          user.save!
          account.save!
        end
  
        session[:messageEdit] = "Datos actualizados correctamente"
      rescue => e
        logger.error "Error actualizando datos: #{e.message}"
        session[:messageEdit] = "Hubo un error al actualizar los datos."
      end
  
      redirect '/config'
    else
      session[:messageEdit] = "No se puede modificar una cuenta Admin"
      redirect '/config'
    end
  end  
  
  post '/delete_account' do
    redirect '/' unless logged_in?
  
    user = current_user
    if user.admin_check == false
      begin
        user.destroy
        session.clear
        @message = "Cuenta eliminada con exito"
        @custom_css = "/css/login.css"
        erb :login, layout: :header
      rescue => e
        logger.error "Error al eliminar cuenta: #{e.message}"
        session[:messageDelete] = "Error al eliminar la cuenta."
        redirect '/config'
      end
    else
      session[:messageDelete] = "No se puede eliminar una cuenta Admin"
      redirect '/config'
    end
  end

 get '/history' do
  redirect '/' unless logged_in?
  @account = current_user.accounts.first
  @movements = Movement
    .where("origin_id = :id OR destination_id = :id", id: @account.id)
    .where(status: ['Pendiente', 'Exitosa'])
    .order(created_at: :desc)
  erb :history
  end
end