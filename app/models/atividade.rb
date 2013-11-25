class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :observacao, :projeto_id, :usuario_id, :aprovacao, :mensagem, :avaliador_id
  attr_accessible :duracao, :data, :cartao_id
  
  scope :periodo, lambda { |range| where(data: range)}
  scope :ano, lambda { |value| where(['extract(year from atividades.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from atividades.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from atividades.data) = ?', value]) if value > 0 }
  scope :projeto, lambda { |value| where(['projeto_id = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| where(['usuario_id = ?', value]) if value > 0 }
  scope :aprovacao, lambda {|value|
    if value == 3
      where('aprovacao is null')
    elsif value == 0 or value == 1
      where(['aprovacao = ?', value])
    end
  }

  belongs_to :cartao
  belongs_to :dia
  belongs_to :projeto
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"

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
    Atividade.joins(:cartao).where(cartao: {trello_id: cid}).sum(:duracao)/3600
  end
  
  def self.horas_trabalhadas_format(cid)
    Time.at(self.horas_trabalhadas(cid) * 3600).utc.strftime("%H:%M")
  end
  
  def self.update_on_trello(key, token, id)
    data = get_trello_data(key, token, id)
    unless (data == :error)
      regex = /[ ][(]\d+[.]?\d*[)]$/
      horas_remoto = data["name"].match(regex).to_s.match(/\d+[.]?\d*+/).to_s
      horas_local = "%.1f" % Atividade.horas_trabalhadas(id)
      unless (horas_remoto == horas_local)
        name = "#{data["name"].sub(regex, "")} (#{horas_local})"
        uri = URI('https://trello.com/1/cards/' + id + '/name')
        uri.query = URI.encode_www_form({:key => key, :token => token })
        req = Net::HTTP::Put.new(uri)
        req.set_form_data({"value" => name})
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true
        http.request(req)
      end
    end
  end
  
  def self.get_trello_data(key, token, id)
    uri = URI('https://trello.com/1/cards/' + id)
    uri.query = URI.encode_www_form({:key => key, :token => token })
    response = Net::HTTP.get_response(uri)
    if response.code == "200"
      JSON.parse response.body
    else
      :error
    end
  end
end
