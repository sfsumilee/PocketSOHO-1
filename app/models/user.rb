class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:twitter, :facebook, :linkedin]
  scope :business_owners, -> { where(type: 'Business Owner') }
  scope :customers, -> { where(type: 'Customer') }

  validates :email, uniqueness: true

  has_many :businesses

  def self.from_omniauth(auth)
    puts "****************************************"
    puts "from omniauth"
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = Devise.friendly_token[0,20]
      # user.twitter_handle = auth.info.name   # assuming the user model has a name
      user.image_url = auth.info.image # assuming the user model has an image
    end
  end

  def self.new_with_session(params, session)
    puts "****************************************"
    puts "new with session"
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
