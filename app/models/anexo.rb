class Anexo < ActiveRecord::Base
  attr_accessible :arquivo, :nome, :tipo, :usuario_id, :pagamento_id, :ausencia_id, :data
#  attr_accessible :size, :content_type, :filename, :arquivo_blob, :blob
  belongs_to :usuario
  belongs_to :pagamento
  belongs_to :ausencia
  mount_uploader :arquivo, ArquivoUploader
end
