require 'attr_extras'
require 'nokogiri'
require 'net/http'

Estacion = Struct.new(:id, :nombre)
Nucleo = Struct.new(:id, :nombre, :estaciones)

class EstacionesScrapper
  attr_reader_initialize :url

  def run
    select.css('option').map do |o|
      id = o.attributes['value'].value.strip.to_i
      name = o.text.strip
      next if name.match(/Seleccione Estación/)
      Estacion.new(id, name)
    end.reject(&:nil?)
  end

  def select
    page.css('select#o')
  end

  def page
    @page ||= Nokogiri::HTML(Net::HTTP.get(page_url))
  end

  def page_url
    URI.parse(url)
  end
end

class NucleoScrapper
  attr_reader_initialize :url_name

  def run
    estaciones = EstacionesScrapper.new(iframe_url).run
    Nucleo.new(id, nombre, estaciones)
  end

  def nombre
    iframe_title.sub(/Cercanías |Rodalies /, '').strip
  end

  def id
    iframe_url.match(/NUCLEO=(\d+)/)[1].to_i
  end

  def iframe_title
    iframe.attributes["title"].value
  end

  def iframe_url
    iframe.attributes["src"].value
  end

  def iframe
    page.css('iframe')[0]
  end

  def page
    @page ||= Nokogiri::HTML(Net::HTTP.get(page_url))
  end

  def page_url
    URI.parse("http://www.renfe.com/viajeros/cercanias/#{url_name}/index.html")
  end

end

class Scrapper

  NUCLEOS = [
    "asturias",
    "barcelona",
    "bilbao",
    "cadiz",
    "madrid",
    "malaga",
    "murciaalicante",
    "sansebastian",
    "santander",
    "sevilla",
    "valencia",
    "zaragoza",
  ]

  def run
    NUCLEOS.map do |nucleo|
      NucleoScrapper.new(nucleo).run
    end
  end
end

nucleos = Scrapper.new.run

puts "CREATE TABLE nucleos (id INTEGER NOT NULL, nombre  VARCHAR(30) NOT NULL, PRIMARY KEY (id));"
puts "CREATE TABLE estaciones (id INTEGER NOT NULL, nucleo_id INTEGER NOT NULL, nombre VARCHAR(50) NOT NULL, FOREIGN KEY (nucleo_id) REFERENCES nucleos(id), PRIMARY KEY (id));"

nucleos.each do |nucleo|
  values = nucleo.estaciones.map{ |e| "(#{e.id}, #{nucleo.id}, \"#{e.nombre}\")" }.join(',')
  puts "INSERT INTO nucleos (id, nombre) VALUES (#{nucleo.id}, \"#{nucleo.nombre}\");"
  puts "INSERT INTO estaciones (id, nucleo_id, nombre) VALUES #{values};"
  puts ""
end
