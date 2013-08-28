class Usuario < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nome, :horario_mensal
  attr_accessible :valor_da_hora, :entrada_usp, :saida_usp, :cpf, :banco, :conta, :agencia
  attr_accessible :role, :address_id, :valor_da_bolsa_fau, :horas_da_bolsa_fau, :funcao
  attr_accessible :data_admissao_fau, :data_demissao_fau, :formado
  attr_accessible :address_attributes, :rg, :telefones_attributes, :contas_attributes, :curso

  has_one  :address, :dependent => :destroy
  has_many :projetos, :through => :workon
  has_many :workon
  has_many :telefones
  has_many :contas

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :telefones, :allow_destroy => true
  accepts_nested_attributes_for :contas, :allow_destroy => true

  validates :nome, :presence => true,
    :uniqueness => true

  has_many :mes
  has_many :dias
  has_many :atividades
end
