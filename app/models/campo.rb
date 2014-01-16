class Campo < ActiveRecord::Base
  belongs_to :projeto
  has_many :dados
  validates_presence_of :projeto_id
end
