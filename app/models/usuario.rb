class Usuario < ActiveRecord::Base
  before_save :default_values
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_one  :address, :dependent => :destroy
  #has_many :boards, :through => :projetos, -> { where ativo: true }
  has_many :workons, :dependent => :destroy
  has_many :telefones, :dependent => :destroy
  has_many :contas, :dependent => :destroy
  has_many :contratos
  has_many :coordenacoes
  has_many :ausencias, :through => :dias
  has_many :anexos, :dependent => :destroy
  has_many :dias
  has_many :atividades
  has_many :registros
  has_many :boards, -> { where projetos: { ativo: true} }, :through => :projetos
  
  accepts_nested_attributes_for :address,      :allow_destroy => true
  accepts_nested_attributes_for :telefones,    :allow_destroy => true
  accepts_nested_attributes_for :contas,       :allow_destroy => true
  accepts_nested_attributes_for :contratos,    :allow_destroy => true
  accepts_nested_attributes_for :coordenacoes, :allow_destroy => true
  accepts_nested_attributes_for :anexos,       :allow_destroy => true

  has_many :projetos, :through => :workons

  validates :nome, presence: true, uniqueness: true
      
  def default_values
    self.role ||= "usuario normal"
    self.status ||= true
  end
   
  def projetos_coordenados
    Projeto.joins(:workons).where(workons: {usuario_id: 17, permissao_id: Permissao.find_by(nome: ['admin', 'coordenador'])})
  end

  def equipe_coordenada
    Usuario.where(id: Workon.where(ativo: true, id: coordenacoes.pluck(:workon_id)).pluck(:usuario_id), status: true).uniq
  end

  def horario_data(data)
    contrato_vigente_em(data).hora_mes
  end

  def contrato_vigente_em(data)
    contrato = contratos.where("inicio <= ? and fim >= ?", data, data).first
    contrato ||= contratos.last
  end
  
  def existe_contrato_em(data)
    contrato = contratos.where("inicio <= ? and fim >= ?", data, data)
    return !contrato.blank?
  end

  def contrato_atual
    self.contratos.order(:fim).last
  end

  def equipe
    Usuario.joins(:workons).where(workons: {
        projeto_id: self.projetos.to_a, usuario_id: Usuario.select(:id).where(status: true)
      }).group(:id).order(:nome)
  end

  def meus_projetos_array
    if self.role == 'admin'
      Projeto.ativos.order(nome: :asc).pluck([:nome, :id])
    else
      self.projetos.merge(Projeto.filhos).merge(Projeto.ativos).order(:nome).pluck([:nome, :id])
    end
  end
  
  def self.por_status
    usuarios = Usuario.order(:nome).pluck([:nome, :status, :id]).group_by{|x| x[1]}
    usuarios["Ativo"] = usuarios.delete(true)
    usuarios["Inativo"] = usuarios.delete(false)
    usuarios
  end
end
