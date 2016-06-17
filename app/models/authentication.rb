class Authentication < ActiveRecord::Base
  attr_accessor :existing_password, :expertise_ids, :parent_guardian_email, :date_of_birth

  has_secure_password

  has_many :authentication_roles, dependent: :destroy
  has_many :roles, through: :authentication_roles

  Role.names.each do |role_name, role_value|
    has_one "#{role_name}_role".to_sym, -> { where(roles: { name: role_value }) },
            class_name: "AuthenticationRole"
  end

  validates :email, presence: true, uniqueness: true
  validates :existing_password, valid_password: true, if: :changes_require_password?

  def self.has_token?(token)
    exists?(auth_token: token)
  end

  def self.find_with_token(token)
    find_by(auth_token: token) || NoAuthFound.new
  end

  def self.find_role_with_token(token, roles)
    roles.map { |role|
      find_with_token(token).send("#{role}_role")
    }.compact.first || NoRolesFound.new(*roles)
  end

  private
  def changes_require_password?
    persisted? && (email_changed? || password_digest_changed?)
  end

  class NoAuthFound
    Role.names.keys.each do |role_name|
      define_method "#{role_name}_role" do
        NoRolesFound.new(role_name)
      end
    end
  end

  class NoRolesFound
    def initialize(*attempted_roles)
      @attempted_roles = attempted_roles
    end

    def authenticated?
      false
    end
  end
end
