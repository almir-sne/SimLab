class ReunioesController < ApplicationController
  before_action :set_reuniao, only: [:show, :edit, :update, :destroy]

  # GET /reunioes
  def index
    @reunioes = Reuniao.all
  end

  # GET /reunioes/1
  def show
  end

  # GET /reunioes/new
  def new
    @reuniao = Reuniao.new
  end

  # GET /reunioes/1/edit
  def edit
    if current_user.role == 'admin'
      @projetos = Projeto.order(:nome)
    else
      @projetos = current_user.projetos_coordenados
    end
    @projeto = @reuniao.projeto || @projetos.first
    @usuarios = @projeto.try(:usuarios)
  end

  # POST /reunioes
  def create
    @reuniao = Reuniao.new(reuniao_params)

    if @reuniao.save
      redirect_to @reuniao, notice: 'Reunião criada com sucesso.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /reunioes/1
  def update
    @reuniao.criador_id = current_user.id
    if @reuniao.update(reuniao_params)
      create_participantes(@reuniao, params[:participantes])
      redirect_to :back, notice: 'Reunião atualizada com sucesso.'
    else
      render action: 'edit'
    end
  end

  # DELETE /reunioes/1
  def destroy
    @reuniao.destroy
    redirect_to reunioes_url, notice: 'Reunião removida com sucesso.'
  end
  
  def usuarios
    projeto = Projeto.find params[:projeto_id]
    @reuniao = Reuniao.find params[:reuniao_id]
    @usuarios = projeto.usuarios
    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_reuniao
    @reuniao = Reuniao.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def reuniao_params
    params.require(:reuniao).permit(:inicio, :concluida, :projeto_id)
  end
    
  def create_participantes(reuniao, params)
    reuniao.participantes.each do |p|
      unless p.usuario.projetos.pluck(:id).include? reuniao.projeto_id
        p.destroy
      end
    end
    
    params.each do |index, vals|
      if vals[:check]
        p = Participante.find_or_create_by reuniao_id: reuniao.id, usuario_id: index
        p.duracao = horas_to_int(vals[:horas])
        p.save
      else
        p = Participante.find_by reuniao_id: reuniao.id, usuario_id: index
        p.destroy if p
      end
    end
  end
  
end
