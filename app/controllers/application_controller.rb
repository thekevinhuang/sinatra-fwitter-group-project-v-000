require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "fweets"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if !logged_in?
      erb :'/users/create_user'
    else
      redirect "/tweets"
    end
  end

  post '/signup' do

    user = User.new(username: params[:username], email: params[:email], password: params[:password])

    if user.save
      session[:user_id] = user.id
      redirect "/tweets"
    else
      redirect "/signup"
    end

  end

  get '/login' do
    if !logged_in?
      erb :'/users/login'
    else
      redirect "/tweets"
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/tweets"
    else
      redirect "/login"
    end
  end

  get '/tweets' do
    if logged_in?
      @all_tweets = Tweet.all
      erb :'/tweets/tweets'
    else
      redirect "/login"
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
    end
    redirect "/login"
  end

  get '/users/:slug' do
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      @all_tweet = @user.tweets
      erb :'/users/show'
    else
      redirect "/login"
    end
  end

  get '/tweets/new' do
    if logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect "/login"
    end
  end

  post '/tweets' do

    if !params[:content].empty?
      tweet = Tweet.create(content: params[:content])
      tweet.user = current_user
      tweet.save
      redirect "/tweets/#{tweet.id}"
    else
      redirect "/tweets/new"
    end
  end

  get '/tweets/:id' do

    if logged_in?
      @tweet = Tweet.find(params[:id])
      @user = @tweet.user
      erb :'/tweets/show_tweet'
    else
      redirect "/login"
    end
  end

  delete '/tweets/:id' do
    tweet = Tweet.find(params[:id])
    if logged_in?
      if tweet.user == current_user
        tweet.delete
      end
      redirect "/tweets"
    else
      redirect "/login"
    end
  end

  get '/tweets/:id/edit' do
    @tweet = Tweet.find(params[:id])

    if logged_in?
      if @tweet.user == current_user
        erb :'/tweets/edit_tweet'
      else
        redirect "/tweets"
      end
    else
      redirect "/login"
    end
  end

  patch '/tweets/:id' do
    tweet = Tweet.find(params[:id])

    if !params[:content].empty?
      tweet.update(content: params[:content])

      tweet.save

      redirect "/tweets/#{tweet.id}"
    else
      redirect "/tweets/#{tweet.id}/edit"
    end

  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end
