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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140116171649) do

  create_table "addresses", force: true do |t|
    t.string   "state"
    t.string   "city"
    t.string   "bairro"
    t.string   "street"
    t.integer  "number"
    t.string   "cep"
    t.string   "complemento"
    t.integer  "usuario_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "anexos", force: true do |t|
    t.string   "nome"
    t.string   "tipo"
    t.string   "arquivo"
    t.integer  "usuario_id"
    t.integer  "pagamento_id"
    t.date     "data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "ausencia_id"
  end

  create_table "atividades", force: true do |t|
    t.integer  "projeto_id"
    t.float    "duracao"
    t.integer  "usuario_id"
    t.text     "observacao"
    t.integer  "dia_id"
    t.boolean  "aprovacao"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "avaliador_id"
    t.date     "data"
    t.integer  "cartao_id"
  end

  create_table "ausencias", force: true do |t|
    t.string   "justificativa"
    t.boolean  "abonada"
    t.string   "mensagem"
    t.integer  "avaliador_id"
    t.float    "horas"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "dia_id"
    t.integer  "projeto_id"
  end

  create_table "boards", force: true do |t|
    t.integer  "projeto_id"
    t.string   "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campos", force: true do |t|
    t.text     "nome"
    t.integer  "tipo"
    t.text     "formato"
    t.integer  "projeto_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "categoria"
  end

  create_table "cartoes", force: true do |t|
    t.string   "estimativa"
    t.string   "trello_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "pai_id"
  end

  create_table "cartoes_tags", force: true do |t|
    t.integer "cartao_id"
    t.integer "tag_id"
  end

  create_table "contas", force: true do |t|
    t.string   "agencia"
    t.string   "banco"
    t.string   "numero"
    t.integer  "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contratos", force: true do |t|
    t.date     "inicio"
    t.date     "fim"
    t.decimal  "valor_hora",                   precision: 5, scale: 2
    t.integer  "hora_mes"
    t.integer  "usuario_id"
    t.string   "tipo"
    t.string   "contratante"
    t.string   "funcao"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "dia_inicio_periodo", limit: 1
  end

  create_table "coordenacoes", force: true do |t|
    t.integer  "usuario_id"
    t.integer  "workon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dados", force: true do |t|
    t.integer "campo_id"
    t.text    "dado"
    t.integer "usuario_id"
  end

  create_table "decks", force: true do |t|
    t.string   "nome"
    t.integer  "minimum_id"
    t.integer  "maximum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dias", force: true do |t|
    t.float    "intervalo"
    t.integer  "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "data"
    t.datetime "entrada"
    t.datetime "saida"
  end

  create_table "estimativas", force: true do |t|
    t.integer  "cartao_id"
    t.integer  "usuario_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "rodada_id"
    t.integer  "planning_card_id"
  end

  create_table "horarios", force: true do |t|
    t.integer  "dia_id"
    t.datetime "entrada"
    t.datetime "saida"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mensagens", force: true do |t|
    t.text     "conteudo"
    t.integer  "atividade_id"
    t.integer  "autor_id"
    t.boolean  "visto",        default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "meses", force: true do |t|
    t.integer  "numero"
    t.integer  "ano"
    t.integer  "usuario_id"
    t.float    "valor_hora"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "horas_trabalhadas", default: 0
  end

  create_table "pagamentos", force: true do |t|
    t.integer  "usuario_id"
    t.integer  "criador_id"
    t.decimal  "valor",      precision: 7, scale: 2
    t.date     "data"
    t.string   "fonte"
    t.string   "motivo"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "pares", force: true do |t|
    t.integer  "par_id"
    t.integer  "atividade_id"
    t.float    "duracao"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "planning_cards", force: true do |t|
    t.string   "nome"
    t.float    "valor"
    t.integer  "deck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projetos", force: true do |t|
    t.string   "nome"
    t.date     "data_de_inicio"
    t.text     "descricao"
    t.float    "valor"
    t.integer  "horas_totais"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "super_projeto_id"
  end

  create_table "registros", force: true do |t|
    t.text     "modificacao"
    t.integer  "autor_id"
    t.integer  "atividade_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "rodadas", force: true do |t|
    t.integer  "cartao_id"
    t.datetime "inicio"
    t.datetime "fim"
    t.integer  "deck_id"
    t.integer  "criador_id"
    t.integer  "finalizador_id"
    t.integer  "numero"
    t.boolean  "fechada"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "tags", force: true do |t|
    t.text     "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "telefones", force: true do |t|
    t.integer  "ddd"
    t.string   "numero"
    t.integer  "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usuarios", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "nome"
    t.date     "entrada_usp"
    t.date     "saida_usp"
    t.string   "cpf"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "role"
    t.text     "address"
    t.string   "rg"
    t.string   "curso"
    t.boolean  "formado"
    t.boolean  "status"
    t.date     "data_de_nascimento"
    t.string   "authentication_token"
    t.integer  "numero_usp"
    t.string   "login_trello"
  end

  add_index "usuarios", ["email"], name: "index_usuarios_on_email", unique: true, using: :btree
  add_index "usuarios", ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true, using: :btree

  create_table "workons", force: true do |t|
    t.integer  "projeto_id"
    t.integer  "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
