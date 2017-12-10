require 'sinatra'
require 'sinatra/json'
require_relative './lib/renfe.rb'

if development?
  require 'sinatra/reloader'
end

get '/nucleos' do
  erb :nucleos, locals: { nucleos: Nucleo.all }
end

get '/estaciones/:id' do |id|
  erb :estaciones, locals: { nucleo: Nucleo.find(id) }
end

get '/horario' do
  origen = Estacion.find(params[:origen].to_i)
  destino = Estacion.find(params[:destino].to_i)
  date = Date.parse(params[:date])
  from = params[:from].split(':').first.to_i
  to = params[:to].split(':').first.to_i
  horario = Horario.new(origen, destino, date: date, hora_inicio: from, hora_fin: to)
  template = horario.transbordo? ? :transbordo : :simple
  erb template, locals: { horario: horario }
end
