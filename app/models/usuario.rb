class Usuario < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_one  :address, :dependent => :destroy
  has_many :boards, :through => :projetos
  has_many :workons, :dependent => :destroy
  has_many :telefones, :dependent => :destroy
  has_many :contas, :dependent => :destroy
  has_many :contratos
  has_many :coordenacoes
  has_many :ausencias, :through => :dias
  has_many :anexos
  has_many :dias
  has_many :atividades
  has_many :registros

  accepts_nested_attributes_for :address,      :allow_destroy => true
  accepts_nested_attributes_for :telefones,    :allow_destroy => true
  accepts_nested_attributes_for :contas,       :allow_destroy => true
  accepts_nested_attributes_for :contratos,    :allow_destroy => true
  accepts_nested_attributes_for :coordenacoes, :allow_destroy => true
  accepts_nested_attributes_for :anexos,       :allow_destroy => true

  has_many :projetos, :through => :workons

  validates :nome, :presence => true,
    :uniqueness => true


  def projetos_coordenados
    Projeto.joins(:workons).where(workons: {id: Workon.select(:id).joins(:coordenacoes).where(coordenacoes: {usuario_id: self})}).group("projetos.id")
  end

  def equipe_coordenada
    equipe_coordenada_por_projetos(projetos_coordenados)
  end

  def equipe_coordenada_por_projetos(projeto)
    Usuario.joins(:workons).where(workons: {id: Workon.select(:id).joins(:coordenacoes).where(projeto_id: projeto, coordenacoes: {usuario_id: self})})
  end

  def equipe
    Usuario.joins(:workons).where(workons: {projeto_id: self.projetos, usuario_id: self}).group(:id)
  end

  def horario_data(data)
    contrato_vigente_em(data).hora_mes
  end

  def contrato_vigente_em(data)
    contrato = contratos.where("inicio <= ? and fim >= ?", data, data).first
    contrato ||= contratos.last
  end

  def monta_coordenacao_hash
    hash = Hash.new
    workons_coordenados = self.coordenacoes.map{|c| c.workon}
    workons_coordenados.each do |w|
      if (hash[w.projeto_id.to_i] == nil)
        users = Array.new
        users << w.usuario_id.to_i
        hash[w.projeto_id.to_i] = users
      else
        hash[w.projeto_id.to_i] << w.usuario_id.to_i
      end
    end
    return hash
  end

  def contrato_atual
    self.contratos.order(:fim).last
  end

  def equipe
    Usuario.joins(:workons).where(workons: {
        projeto_id: self.projetos.to_a, usuario_id: Usuario.select(:id).where(status: true)
      }).group(:id).order(:nome)
  end

  def meus_projetos
    if (self.role == 'admin')
      Projeto.order(:nome).collect {|p| [p.nome, p.id ] }
    else
      self.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
    end
  end
end
