# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131008192621) do

  create_table "addresses", :force => true do |t|
    t.string   "state"
    t.string   "city"
    t.string   "bairro"
    t.string   "street"
    t.integer  "number"
    t.string   "cep"
    t.string   "complemento"
    t.integer  "usuario_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "atividades", :force => true do |t|
    t.integer  "projeto_id"
    t.float    "duracao"
    t.integer  "usuario_id"
    t.text     "observacao"
    t.integer  "mes_id"
    t.integer  "dia_id"
    t.boolean  "aprovacao"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "mensagem"
    t.integer  "avaliador_id"
    t.date     "data"
  end

  create_table "ausencias", :force => true do |t|
    t.integer  "usuario_id"
    t.integer  "mes_id"
    t.string   "justificativa"
    t.boolean  "abonada"
    t.string   "mensagem"
    t.integer  "avaliador_id"
    t.float    "horas"
    t.integer  "dia"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "boards", :force => true do |t|
    t.integer  "projeto_id"
    t.string   "board_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cartoes", :force => true do |t|
    t.string   "cartao_id"
    t.integer  "atividade_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "duracao"
  end

  create_table "contas", :force => true do |t|
    t.string   "agencia"
    t.string   "banco"
    t.string   "numero"
    t.integer  "usuario_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contratos", :force => true do |t|
    t.date     "inicio"
    t.date     "fim"
    t.decimal  "valor_hora",                      :precision => 5, :scale => 2
    t.integer  "hora_mes"
    t.integer  "usuario_id"
    t.string   "tipo"
    t.string   "contratante"
    t.string   "funcao"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "dia_inicio_periodo", :limit => 1
  end

  create_table "coordenacoes", :force => true do |t|
    t.integer  "usuario_id"
    t.integer  "workon_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dias", :force => true do |t|
    t.integer  "numero"
    t.datetime "entrada"
    t.datetime "saida"
    t.float    "intervalo"
    t.integer  "usuario_id"
    t.integer  "mes_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "meses", :force => true do |t|
    t.integer  "numero"
    t.integer  "ano"
    t.integer  "usuario_id"
    t.float    "valor_hora"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "horas_trabalhadas", :default => 0
  end

  create_table "pagamentos", :force => true do |t|
    t.integer  "mes_id"
    t.integer  "usuario_id"
    t.integer  "criador_id"
    t.decimal  "valor",      :precision => 7, :scale => 2
    t.date     "data"
    t.string   "fonte"
    t.string   "motivo"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "projetos", :force => true do |t|
    t.string   "nome"
    t.date     "data_de_inicio"
    t.text     "descricao"
    t.float    "valor"
    t.integer  "horas_totais"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "super_projeto_id"
  end

  create_table "telefones", :force => true do |t|
    t.integer  "ddd"
    t.string   "numero"
    t.integer  "usuario_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "usuarios", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "nome"
    t.date     "entrada_usp"
    t.date     "saida_usp"
    t.string   "cpf"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "role"
    t.text     "address"
    t.string   "rg"
    t.string   "curso"
    t.boolean  "formado"
    t.boolean  "status"
    t.date     "data_de_nascimento"
    t.string   "authentication_token"
  end

  add_index "usuarios", ["email"], :name => "index_usuarios_on_email", :unique => true
  add_index "usuarios", ["reset_password_token"], :name => "index_usuarios_on_reset_password_token", :unique => true

  create_table "workons", :force => true do |t|
    t.integer  "projeto_id"
    t.integer  "usuario_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
