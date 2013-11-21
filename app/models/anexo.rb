class Anexo < ActiveRecord::Base
  attr_accessible :arquivo, :nome, :tipo, :usuario_id, :data
#  attr_accessible :size, :content_type, :filename, :arquivo_blob, :blob
  belongs_to :usuario
  mount_uploader :arquivo, ArquivoUploader
end
