# Para iniciar digite no console
# thin start -R faye.ru -p 9292 -e production -d
require 'faye'
Faye::WebSocket.load_adapter('thin')
app = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
run app