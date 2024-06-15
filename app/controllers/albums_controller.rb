# app/controllers/albums_controller.rb
class AlbumsController < ApplicationController
    require 'net/http'
    require 'json'

    def show
      @album = get_album(params[:id])
      @photos = get_photos(@album['id'])
    end
  
    private
  
    def get_album(album_id)
      url = URI.parse("https://jsonplaceholder.typicode.com/albums/#{album_id}")
      response = Net::HTTP.get_response(url)
      albums=JSON.parse(response.body)

      albums.each do |album_data|
        Album.find_or_create_by!(id: album_data['id']) do |album|
          album.title = album_data['title']
          album.user_id = album_data['userId']
        end
      end
    end
  
    def get_photos(album_id)
      url = URI.parse('https://jsonplaceholder.typicode.com/photos')
      response = Net::HTTP.get_response(url)
      photos = JSON.parse(response.body)
      photos.select { |photo| photo['albumId'] == album_id }.take(1)
    end
  end
  