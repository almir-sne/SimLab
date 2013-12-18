class Cartao < ActiveRecord::Base
  attr_accessible :trello_id, :estimativa, :rodada, :id, :pai_id
  validates :trello_id, :uniqueness => true, :presence => true
  
  has_many :atividades
  has_many :rodadas
  
  belongs_to :pai, :class_name => "Cartao"
  
  def self.horas_trabalhadas(trello_id)
    Cartao.where(trello_id: trello_id).last.atividades.sum(:duracao)/3600
  end
  
  def self.horas_trabalhadas_format(cid)
    h = self.horas_trabalhadas(cid)
    "#{h.to_i}:#{((h - h.to_i) * 60).round}"
  end
  
  def rodada_aberta?
    !self.rodadas.where(fechada: false).blank?
  end
  
  def fechar_rodada(user)
    rodada = self.rodadas.where(fechada: false).last
    if rodada
      rodada.fechada = true
      rodada.fim = Time.now
      rodada.finalizador = user
      rodada.save
    end
  end
  
  def self.update_on_trello(key, token, id)
    data = get_trello_data(key, token, id)
    unless (data == :error)
      regex = /[ ][(]\d+[.]?\d*[)]$/
      horas_remoto = data["name"].match(regex).to_s.match(/\d+[.]?\d*+/).to_s
      horas_local = "%.1f" % Cartao.horas_trabalhadas(id)
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
