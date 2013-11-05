class Anexo < ActiveRecord::Base
  attr_accessible :arquivo, :nome, :tipo, :usuario_id
  belongs_to :usuario
  mount_uploader :arquivo, ArquivoUploader
end
