class Board < ActiveRecord::Base
  attr_accessible :board_id, :projeto_id
  belongs_to :projeto
end
