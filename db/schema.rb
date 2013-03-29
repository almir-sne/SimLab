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

ActiveRecord::Schema.define(:version => 20130328234934) do

  create_table "banco_de_horas", :force => true do |t|
    t.date     "data"
    t.float    "horas"
    t.text     "observacao"
    t.integer  "projeto_id"
    t.integer  "usuario_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "projetos", :force => true do |t|
    t.string   "name"
    t.datetime "data_de_inicio"
    t.text     "descricao"
    t.float    "valor"
    t.integer  "horas_totais"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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
    t.integer  "horario_mensal"
    t.float    "valor_da_hora"
    t.date     "entrada_usp"
    t.date     "saida_usp"
    t.string   "cpf"
    t.string   "banco"
    t.integer  "conta"
    t.integer  "agencia"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "role"
  end

  add_index "usuarios", ["email"], :name => "index_usuarios_on_email", :unique => true
  add_index "usuarios", ["reset_password_token"], :name => "index_usuarios_on_reset_password_token", :unique => true

end
