class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable, :omniauth_providers => [:facebook]

  has_many :subscriptions, -> {where(active: true)}, dependent: :destroy
  has_many :courses, through: :subscriptions
  has_many :reviews, dependent: :destroy
  has_many :user_tasks, dependent: :destroy

  def self.from_omniauth(auth)
	where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
		user.email = auth.info.email
		user.password = Devise.friendly_token[0,20]
		user.name = auth.info.name   # assuming the user model has a name
		# user.image = auth.info.image # assuming the user model has an image
		# If you are using confirmable and the provider(s) you use validate emails,
		# uncomment the line below to skip the confirmation emails.
		user.skip_confirmation!
  end
end

   def self.new_with_session(params, session)
    super.tap do |user|
      data = session["devise.facebook_data"]
      if  data.present? && data["extra"] && data["extra"]["raw_info"]
        user.email = data["info"]["email"] if user.email.blank?
      end
    end
  end
  def has_course?(course)
    courses.include?(course)
  end

  def has_course_review?(course)
    reviews.where(course: course).first
  end
  def complete_task(task)
    user_tasks.find_or_create_by(task: task).update_attributes(completed: true)
  end
  def has_completed_task?(task)
    user_tasks.completed.where(task: task).first
  end
end
