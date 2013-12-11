class Anexo < ActiveRecord::Base
#  attr_accessible :size, :content_type, :filename, :arquivo_blob, :blob
  belongs_to :usuario
  belongs_to :pagamento
  belongs_to :ausencia
  mount_uploader :arquivo, ArquivoUploader
end
