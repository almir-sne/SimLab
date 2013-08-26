class Usuario < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nome, :horario_mensal
  attr_accessible :valor_da_hora, :entrada_usp, :saida_usp, :cpf, :banco, :conta, :agencia
  attr_accessible :role, :address_id, :cel, :valor_da_bolsa_fau, :horas_da_bolsa_fau, :funcao
  attr_accessible :data_admissao_fau, :data_demissao_fau
  attr_accessible :address_attributes

  attr_accessor :ddd, :tel_numero

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

  validates :cel, :length => {:maximum => 15}
  validates :tel_numero, :length => { :maximum => 15}

  has_many :banco_de_horas
  has_many :mes
  has_many :dias
  has_many :atividades



  def phone(ddd, numero)
    self.ddd = ddd
    self.tel_numero = numero
    self.cel = ddd + numero
  end


end
