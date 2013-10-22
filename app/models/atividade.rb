class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :observacao, :projeto_id, :usuario_id, :aprovacao, :mensagem, :avaliador_id
  attr_accessible :duracao, :data, :cartao_id
  
  scope :ano, lambda { |value| where(['extract(year from atividade.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from atividade.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from atividade.data) = ?', value]) if value > 0 }

  belongs_to :dia
  belongs_to :projeto
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  has_many :cartoes, :dependent => :destroy

  validates :dia_id, :presence => true
  validates :projeto_id, :presence => true
  validates :usuario_id, :presence => true

  def horas
    unless read_attribute(:duracao).blank?
      read_attribute(:duracao)/60
    else
      0
    end
  end

  def bar_width
    width = duracao.nil? ? "0" : (duracao / 360).to_s
    width + "%"
  end

  def minutos
    duracao/60
  end

  def formata_duracao
    Time.at(duracao).utc.strftime("%H:%M")
  end

  def cor_status
    if self.aprovacao == true
      "green-background"
    elsif self.aprovacao == false
      "red-background"
    else
      ""
    end
  end
  
  def self.horas_trabalhadas(cid)
    Atividade.where(cartao_id: cid).sum(:duracao)/60
  end
  
  def self.horas_trabalhadas_format(cid)
    Time.at(horas_trabalhadas(cid) * 3600).utc.strftime("%H:%M")
  end
  
  def self.update_on_trello(key, token, id)
    data = get_trello_data(key, token, id)
    name = data["name"].sub(/[ ][(][0-9]+[)]/, "") +
      " (" + Cartao.horas_trabalhadas(id).to_s + ")"
    uri = URI('https://trello.com/1/cards/' + id + '/name')
    uri.query = URI.encode_www_form({:key => key, :token => token })
    req = Net::HTTP::Put.new(uri)
    req.set_form_data({"value" => name})
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.request(req)
  end
  
  def self.get_trello_data(key, token, id)
    uri = URI('https://trello.com/1/cards/' + id)
    uri.query = URI.encode_www_form({:key => key, :token => token })
    response = Net::HTTP.get_response(uri)
    JSON.parse response.body
  end
end
