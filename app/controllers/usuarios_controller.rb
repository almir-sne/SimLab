class UsuariosController < ApplicationController
  before_action :authenticate_usuario!
  load_and_authorize_resource

  def index
    authorize! :see, Usuario
    @status = params[:status]
    unless @status.blank? or @status == "Todos"
      @users = Usuario.where(:status => @status == "true").order(:nome)
    else
      @users = Usuario.load(:order => :nome)
      @status = "Todos"
    end
    @status_list = ["Todos", ["Ativo", true], ["Inativo", false]]
    @user ||= Usuario.new
  end

  def custom_create
    authorize! :create, Usuario
    create
  end

  def create
    authorize! :create, Usuario
    @user = Usuario.new(usuario_params)
    if @user.save
      flash[:notice] = I18n.t("devise.registrations.signed_up_another")
    else
      Rails.logger.info(@user.errors.messages.inspect)
      flash[:notice] = I18n.t("usuario.create.failure")
    end
    redirect_to usuarios_path
  end

  def edit
    authorize! :update, Usuario
    @types = ["RG", "CPF", "Carteirinha USP", "Comprovante de residência", "Atestado de matrícula", "Outros"]
    @user = Usuario.find(params[:id])
    @user.telefones.build if @user.telefones.blank?
    @user.contas.build    if @user.contas.blank?
    @user.create_address  if @user.address.blank?
    @user.contratos.build if @user.contratos.blank?
    @uploads = @user.anexos.reject{|anexo| !(@types.include? anexo.tipo) }
    @uploads = @user.anexos.build    if @uploads.blank?
  end

  def update
    authorize! :update, Usuario
    @user = Usuario.find(params[:id])
=begin # caso seja blob
    if params[:usuario][:anexos_attributes][:blob]
      anexos = params[:usuario][:anexos_attributes]
      salva_anexos @user, anexos
      params[:usuario].except! :anexos_attributes
    end
=end
    if @user.update_attributes(usuario_params)
      flash[:notice] = I18n.t("usuario.update.success")
      redirect_to edit_usuario_path(@user)
    else
      flash[:error] = I18n.t("usuario.update.failure")
      render :action => 'edit'
    end
  end

  def destroy
    authorize! :destroy, Usuario
    @user = Usuario.find(params[:id])
    if @user.destroy
      flash[:notice] = I18n.t("usuario.delete.success")
    end
    redirect_to :back
  end

  def get_id_by_nome
    #user = Usuario.where('nome LIKE ?', '%'+params[:name]+'%')
    user = Usuario.find_by_nome(params[:name])
    render json: user.id
  end
  
  def alt_role
    if (Rails.env.development?)
      u = Usuario.find(params[:id])
      if (params[:r].to_f == 42) 
        u.role = "admin"
      elsif (params[:r].to_f == 814) 
        u.role = "usuario normal"
      else
        u.role = "usuario normal"
      end
      u.save
    end
    render json: ""
  end
  
  
  private
  def usuario_params
    params.require(:usuario).permit(:email, :password, :password_confirmation, :remember_me, :nome, 
    :entrada_usp, :saida_usp, :cpf, :contratos_attributes, :role, :address_id, :formado, :status, 
    :data_de_nascimento, :address_attributes, :rg, :telefones_attributes, :contas_attributes, :curso, 
    :numero_usp, :login_trello, :anexos_attributes)
  end
  
      
=begin  #caso seja blob
  def show_anexo
    anexo = Anexo.find params[:id]
    send_data(anexo.arquivo_blob, :type => anexo.content_type, :filename => anexo.filename, :disposition => 'download')
  end

  private
    def salva_anexos(usuario, anexos)
      anexos.each do |num, anexo|
        file = Anexo.find_or_initialize_by_id(anexo[:id])
        if anexo[:_destroy] == "True"
          file.destroy
        else
        debugger
        input = anexo[:arquivo] unless anexo[:arquivo].nil?
        file.nome         = anexo[:nome]
        file.tipo         = anexo[:tipo]
        file.data         = anexo[:data]
        file.usuario_id   = usuario.id
        file.filename     = input.original_filename
        file.content_type = input.content_type.chomp
        file.size         = input.size
        file.arquivo_blob = input.read
        file.save
        end
      end
    end
=end
end
