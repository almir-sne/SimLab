class Cartao < ActiveRecord::Base
  validates :trello_id, :uniqueness => true, :presence => true

  has_many :atividades
  has_many :rodadas

  belongs_to :pai, :class_name => "Cartao"
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :tags
  
  def horas_trabalhadas
    atividades.sum(:duracao)
  end

  def rodada_aberta?
    !self.rodadas.where(fechada: false).blank?
  end
  
  def pai_trello_id
    self.pai.try(:trello_id)
  end
  
  def pai_trello_id=(val)
    self.pai = Cartao.find_or_create_by(trello_id: val)
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

  def self.update_on_trello(key, token, id, tags)
    data = get_trello_data(key, token, id)
    unless (data == :error)
      regex_horas = /[ ][(]\d+[.]?\d*[)]$/

      horas_remoto = data["name"].match(regex_horas).to_s.match(/\d+[.]?\d*+/).to_s
      horas_local = "%.1f" % Cartao.horas_trabalhadas(id)
      nome_novo = remove_tags(data["name"]);
      tags_texto = ""
      unless tags.nil?
        tags.each do |t|
          tags_texto += "[" + t.to_s + "] "
        end
        if (!tags_texto.blank?)
          nome_novo = tags_texto + " " + nome_novo
        end
      end

      if (horas_remoto != horas_local)
        name = "#{nome_novo.sub(regex_horas, "")} (#{horas_local})"
      else
        name = nome_novo
      end
      uri = URI('https://trello.com/1/cards/' + id + '/name')
      uri.query = URI.encode_www_form({:key => key, :token => token })
      req = Net::HTTP::Put.new(uri)
      req.set_form_data({"value" => name})
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      http.request(req)
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
  
  def tags_string
    tags.pluck(:nome).join(", ")
  end
  
  def tags_string=(val)
    self.tags = val.split(",").collect{|t| Tag.find_or_create_by(nome: t.strip)}
  end
end
