class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    # Validasi untuk memastikan username, password, dan email tidak kosong
    validates :username, presence: true
    validates :password, presence: true
    validates :email, presence: true
    
    # Validasi untuk memastikan format email benar
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, format: { with: VALID_EMAIL_REGEX, message: "format is invalid" }
  
    # Jika Anda ingin memastikan email unik di seluruh database
    validates :email, uniqueness: true
    validates :username, uniqueness: true
  end
  