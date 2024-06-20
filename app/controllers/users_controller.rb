require 'net/http'
require 'json'

class UsersController < ApplicationController
  before_action :get_users

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    get_albums(@user.id)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def search
    key = params[:query].downcase.strip
    if key.present?
      @users = User.where('LOWER(username) LIKE ?', "%#{key}%")
    else
      @users = User.all
    end
    render :index
  end

  def show_photo
    @photo = Photo.find(params[:photo_id])

    respond_to do |format|
      format.html 
      format.turbo_stream
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      respond_to do |format|
        format.html {redirect_to user_path(user_params), notice: "User was successfully updated"}
        format.turbo_stream {redirect_to user_path(user_params), notice: "User was successfully updated"}
      end
    end
  end

  private

  def get_users
    uri = URI('https://jsonplaceholder.typicode.com/users')
    response = Net::HTTP.get(uri)
    users = JSON.parse(response)

      users.each do |user_data|
        profile_photo_uri = URI("https://picsum.photos/id/#{user_data["id"]}/info")
        res = Net::HTTP.get(profile_photo_uri)
        photo = JSON.parse(res)
        User.find_or_create_by!(
          id: user_data['id']
        ) do |user|
          user.name = user_data['name']
          user.username = user_data['username']
          user.email = user_data['email']
          user.phone = user_data['phone']
          user.address = user_data['address']
          user.profile_photo = photo["download_url"]
        end
    end
  end

  def get_albums(user_id)
    if Album.where(user_id: user_id).exists?
      @albums = Album.where(user_id: user_id)
    else
      uri = URI("https://jsonplaceholder.typicode.com/albums?userId=#{user_id}")
      response = Net::HTTP.get(uri)
      albums = JSON.parse(response)
      
      album_data = albums.map do |album_res|
        {
          id: album_res['id'],
          user_id: user_id,
          title: album_res['title'],
          created_at: Time.current,
          updated_at: Time.current
        }
      end
  
      Album.insert_all(album_data, unique_by: :id) unless album_data.empty?
      @albums = Album.where(user_id: user_id)
  
      album_ids = albums.map { |album| album['id'] }
      album_ids.each { |album_id| get_photos(album_id) }
    end
  end

  def get_photos(album_id)
    if Photo.where(album_id: album_id).exists?
      @photos = Photo.where(album_id: album_id)
    else
      uri = URI("https://jsonplaceholder.typicode.com/photos?albumId=#{album_id}")
      response = Net::HTTP.get(uri)
      photos = JSON.parse(response)
      filtered_photos = photos.select { |photo| photo['albumId'] == album_id }.take(1)
  
      photo_data = filtered_photos.map do |photo_res|
        {
          id: photo_res['id'],
          album_id: album_id,
          title: photo_res['title'],
          url: photo_res['url'],
          thumbnail_url: photo_res['thumbnailUrl'],
          created_at: Time.current,
          updated_at: Time.current
        }
      end
  
      Photo.insert_all(photo_data, unique_by: :id) unless photo_data.empty?
      @photos = Photo.where(album_id: album_id)
    end
  end
  

  def user_params
    params.require(:user).permit(:name, :username, :email, :phone, :address, :profile_photo)
  end
end
