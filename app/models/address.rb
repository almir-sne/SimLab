class Address < ActiveRecord::Base
  attr_accessible :bairro, :cep, :city, :complemento, :number, :state, :street, :usuario_id

  belongs_to :usuario
end
