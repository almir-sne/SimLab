# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SinLab::Application.initialize!

def extract_tags(string)
    regex_tags = /(\[(.*?)\])+/
    preprocessed = string
    tag_processada = "unclean"
    tags_remoto = Array.new
    while (tag_processada != "" and !tag_processada.nil?)
      tag_processada = preprocessed.match(regex_tags)
      preprocessed = preprocessed.sub(regex_tags,"")
      if (!tag_processada.nil?)
        tags_remoto << tag_processada.to_s.sub("[","").sub("]","").to_s
      end      
    end
    tags_remoto    
  end
  
  def remove_tags(string)
    regex_tags = /(\[(.*?)\])+/
    preprocessed = string
    tag_processada = "unclean"
    while (tag_processada != "" and !tag_processada.nil?)
      tag_processada = preprocessed.match(regex_tags)
      preprocessed = preprocessed.sub(regex_tags,"")  
    end
    preprocessed
  end
