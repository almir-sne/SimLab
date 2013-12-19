class Tag < ActiveRecord::Base
  attr_accessible :nome, :cartoes
  
  has_and_belongs_to_many :cartoes
end