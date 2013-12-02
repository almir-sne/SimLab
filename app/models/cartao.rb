class Cartao < ActiveRecord::Base
  attr_accessible :trello_id, :estimativa, :rodada, :id, :estimado, :pai_id
  validates :trello_id, :uniqueness => true, :presence => true
  
  has_many :estimativas
  has_many :atividades
  
  belongs_to :pai, :class_name => "Cartao"
  
  def rodada_concluida?(rodada)
    if rodada < self.rodada
      true
    elsif rodada == self.rodada and self.estimado?
      true
    else
      false
    end
  end
  
  def media(rodada)
    self.estimativas.where("valor > 0 and rodada = ?", rodada).average(:valor)
  end
  
  def estimativas_na_rodada(rodada)
    self.estimativas.where("valor is not null and rodada = ?", rodada).count
  end
  
  def estimativa_string
    if read_attribute(:estimativa) == -2.0
      "Infinito"
    elsif read_attribute(:estimativa) == -1.0
      "?"
    else
      read_attribute(:estimativa)
    end
  end
  
  def minimo(rodada)
    self.estimativas.where("valor >= 0 and rodada = ?", rodada).minimum(:valor)
  end
  
  def maximo(rodada)
    unless self.estimativas.where(valor: -2.0, rodada: rodada).blank?
      "Infinito"
    else
      self.estimativas.where("valor >= 0 and rodada = ?", rodada).maximum(:valor)
    end
  end
  
  def self.horas_trabalhadas(trello_id)
    Cartao.where(trello_id: trello_id).last.atividades.sum(:duracao)/3600
  end
  
  def self.horas_trabalhadas_format(cid)
    h = self.horas_trabalhadas(cid)
    "#{h.to_i}:#{((h - h.to_i) * 60).round}"
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
