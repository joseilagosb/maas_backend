# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def respond_with(current_user, _opts = {})
      if resource.persisted?
        render json: {
          status: { code: 200, message: 'Signed up successfully.' },
          user: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
        }
      elsif duplicate_email?
        render json: {
          status: { message: "User couldn't be created successfully. Email already taken." }
        }, status: :unauthorized
      else
        render json: {
          status: { message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    end

    def duplicate_email?
      return false unless resource.errors.key?(:email)

      resource.errors.details[:email].any? do |hash|
        hash[:error] == :taken
      end
    end
  end
end
