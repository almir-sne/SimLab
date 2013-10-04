class Usuario < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nome
  attr_accessible :entrada_usp, :saida_usp, :cpf, :contratos_attributes
  attr_accessible :role, :address_id, :formado, :status, :data_de_nascimento
  attr_accessible :address_attributes, :rg, :telefones_attributes, :contas_attributes, :curso

  has_one  :address, :dependent => :destroy
  has_many :projetos, :through => :workons
  has_many :workons
  has_many :telefones
  has_many :contas
  has_many :contratos
  has_many :coordenacoes

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :telefones, :allow_destroy => true
  accepts_nested_attributes_for :contas, :allow_destroy => true
  accepts_nested_attributes_for :contratos, :allow_destroy => true
  accepts_nested_attributes_for :coordenacoes, :allow_destroy => true

  validates :nome, :presence => true,
    :uniqueness => true

  has_many :meses
  has_many :dias
  has_many :atividades
  
  def projetos_coordenados
    Projeto.joins(:workons).where(workons: {id: Workon.select(:id).joins(:coordenacoes).where(coordenacoes: {usuario_id: self})}).group("projetos.id")
    #projetos = self.projetos.includes(:workon).where("workons.coordenador" => true)
    #projetos.map{|z|  z.sub_projetos.empty? ? z : [z, z.sub_projetos] }.flatten.uniq
  end

  #def projetos_coordenados
    #self.projetos.includes(:workon).where("workons.coordenador" => true)
  #end

  def equipe_coordenada
    equipe_coordenada(projetos_coordenados)
  end
  
  def equipe_coordenada_por_projetos(projeto)
  Usuario.joins(:workons).where(workons: {id: Workon.select(:id).joins(:coordenacoes).where(projeto_id: projeto, coordenacoes: {usuario_id: self})})
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

end
