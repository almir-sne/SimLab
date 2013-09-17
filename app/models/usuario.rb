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
  has_many :projetos, :through => :workon
  has_many :workon
  has_many :telefones
  has_many :contas
  has_many :contratos

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :telefones, :allow_destroy => true
  accepts_nested_attributes_for :contas, :allow_destroy => true
  accepts_nested_attributes_for :contratos, :allow_destroy => true

  validates :nome, :presence => true,
    :uniqueness => true

  has_many :mes
  has_many :dias
  has_many :atividades

  def projetos_coordenados
    self.projetos.includes(:workon).where("workons.coordenador" => true)
  end

  def equipe_coordenada
    equipe(projetos_coordenados)
  end

  def equipe(projetos)
    coord = Array.new
    projetos.each{ |p|
      p.usuarios.each  { |u|
        coord << u if (!coord.include? u)
      }
    }
    coord.sort
  end

  def horario_data(data)
    contrato_vigente_em(data).hora_mes
  end

  def contrato_vigente_em(data)
    contrato = contratos.where("inicio <= ? and fim >= ?", data, data).first
    contrato ||= contratos.last
  end

end
