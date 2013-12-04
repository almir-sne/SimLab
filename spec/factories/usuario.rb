FactoryGirl.define do
  factory :desenvolvedor, class: Usuario do
    nome "Usuario Desenvolvedor Teste"
    email "userDE@example3.com"
    password "12345678"
		password_confirmation "12345678"
    role "usuario normal"
  end

  factory :admin, class: Usuario do
    nome "Usuario Admin Teste"
    email "userAD@example3.com"
    password "12345678"
		password_confirmation "12345678"
    role "admin"
  end

  factory :coordenador, class: Usuario do
    nome "Usuario Coordenador Teste"
    email "userCO@example3.com"
    password "12345678"
		password_confirmation "12345678"
    role "coordenador"
  end
 end
