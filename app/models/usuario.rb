class Usuario < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nome, :horario_mensal
  attr_accessible :valor_da_hora, :entrada_usp, :saida_usp, :cpf, :banco, :conta, :agencia
  # attr_accessible :title, :body

  validates :email, :length => {:minimum => 3, :maximum => 254},
                    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}

  validates :nome, :presence => true

  has_many :banco_de_horas
  has_many :mes
  has_many :dias
  has_many :atividades
  
  

end
