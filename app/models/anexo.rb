class Anexo < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :pagamento
  belongs_to :ausencia
  mount_uploader :arquivo, ArquivoUploader
end
