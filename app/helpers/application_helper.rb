module ApplicationHelper
  def link_to_submit(*args, &block)
    link_to_function (block_given? ? capture(&block) : args[0]), "$(this).closest('form').submit()", args.extract_options!
  end
  
  def int_to_horas(h)
    h = h.to_i/3600.0
    "#{h.to_i}:#{pad ((h - h.to_i) * 60).round}"
  end
  
  def pad(string)
    ("%2d" % string).gsub(" ", "0")
  end
  
  #  http://railscasts.com/episodes/260-messaging-with-faye?view=asciicast
  def broadcast(channel, &block)
    message = {:channel => channel, :data => capture(&block)}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
  
end
