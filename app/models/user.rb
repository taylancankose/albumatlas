class User < ApplicationRecord
    has_many :albums, dependent: :destroy

    
    validates :name, :username, presence: true
end
