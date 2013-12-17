class Tag < ActiveRecord::Base
  attr_accessible :nome, :atividades
  
  has_and_belongs_to_many :atividades
end