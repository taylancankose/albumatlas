require 'net/http'
require 'json'

class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    get_albums(@user.id)
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
    uri = URI("https://jsonplaceholder.typicode.com/albums?userId=#{user_id}")
    response = Net::HTTP.get(uri)
    albums = JSON.parse(response)

    albums.each do |album_res|
      album = Album.find_or_create_by!(id: album_res['id'], user_id: user_id) do |a|
        a.title = album_res['title']
      end
      get_photos(album.id)
    end
  end

  def get_photos(album_id)
    uri = URI("https://jsonplaceholder.typicode.com/photos?albumId=#{album_id}")
    response = Net::HTTP.get(uri)
    photos = JSON.parse(response)
    filtered_photos = photos.select { |photo| photo['albumId'] == album_id }.take(1)

    filtered_photos.each do |photo_res|
      Photo.find_or_create_by!(id: photo_res['id'], album_id: album_id) do |photo|
        photo.title = photo_res['title']
        photo.url = photo_res['url']
        photo.thumbnail_url = photo_res['thumbnailUrl']
      end
    end
  end
end
