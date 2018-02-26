require 'sinatra'
require 'redis'
require 'redis-load'
require 'json'

require_relative 'helpers/formulaire'

enable :sessions
set :session_secret, "secret"

redis = Redis.new

get '/init' do
	redis.flushall

	loader = RedisLoad::Loader.new(redis)
	loader.load_json("tests/test.json")

	database_content = ""

	redis.keys.each do |key|
		database_content += key + "<br>"
		redis.hgetall(key).each do |field, value|
			database_content += field + " : " + value + "<br>"
		end
		database_content += "<br>"
	end

	database_content

end

get '/' do
	erb :'#_identification', layout: false
end

post '/identification' do
	if params[:identifiant].empty? || params[:date_naiss].empty?
		session[:erreur_id_ou_date_naiss_absente] = true
		redirect '/'
	end

	identifiant = params[:identifiant]
	date_naiss_fournie = params[:date_naiss]
	date_naiss_secrete = get_date_naiss_eleve(redis, identifiant)

	if date_naiss_secrete == date_naiss_fournie
		session[:identifiant] = identifiant
		session[:demarche] = get_demarche(redis, session[:identifiant])
		redirect '/accueil'
	else
		session[:erreur_id_ou_date_naiss_incorrecte] = true
		redirect '/'
	end
end

get '/accueil' do
	erb :'0_accueil', locals: { redis: redis }
end

get '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = get_eleve(redis, identifiant)
	erb :'1_eleve', locals: eleve
end

post '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = get_eleve(redis, identifiant)
	eleve_modifie =
		{
			prenom: eleve["prenom"],
			nom: params[:nom],
			sexe: params[:sexe],
			date_naiss: "1995-11-19",
			ville_naiss: params[:ville_naiss],
			pays_naiss: params[:pays_naiss],
			nationalite: params[:nationalite],
			classe_ant: params[:classe_ant],
			ets_ant: params[:ets_ant]
		}
	redis.hmset "dossier_eleve:#{identifiant}", :eleve, eleve_modifie.to_json
	redirect to('/resp_legal_1')
end


get '/scolarite' do
	erb :'2_scolarite'
end

get '/famille' do
	erb :'3_famille'
end

get '/administration' do
	erb :'4_administration'
end

get '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre'
end

get '/validation' do
	erb :'6_validation'
end

get '/confirmation' do
	erb :'7_confirmation'
end

get '/agent' do
	erb :'agent', layout: :layout_agent
end

# REINSCRIPTIONS

get '/r0' do
	erb :'r0_accueil'
end

get '/r1' do
	erb :'r1_scolarite'
end

get '/r2' do
	erb :'r2_famille'
end

get '/r3' do
	erb :'4_administration'
end

get '/r4' do
	erb :'5_pieces_a_joindre'
end

get '/r5' do
	erb :'6_validation'
end

get '/r6' do
	erb :'7_confirmation'
end