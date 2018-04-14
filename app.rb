require 'sinatra'
require_relative './lib/renfe.rb'

require 'sinatra/reloader' if development?

get '/' do
  erb :index
end

get '/nucleos' do
  erb :nucleos, locals: { nucleos: Nucleo.all.sort_by(&:nombre) }
end

get '/estaciones/:id' do |id|
  erb :estaciones, locals: { nucleo: Nucleo.find(id) }
end

get '/horario' do
  origen = Estacion.find(params[:origen].to_i)
  destino = Estacion.find(params[:destino].to_i)
  date = 
  all_day = ["1", "on", 1, true, "true"].include?(params[:all_day])
  options = {
    date: Date.parse(params[:date])
  }.tap do |options|
    break if all_day
    options[:hora_inicio] = params[:from].split(':').first.to_i
    options[:hora_fin] = params[:to].split(':').first.to_i
  end
  horario = Horario.new(origen, destino, options)
  template = horario.transbordo? ? :transbordo : :simple
  erb template, locals: { horario: horario }
end
