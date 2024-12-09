module Users
  class CreateService
    include ModelValidationHelper

    def initialize(params)
      @params = params
      @errors = {}
    end

    def execute
      user = User.new(@params)

      validate_model(user)

      if @errors.any?
        raise ValidationError.new(@errors)
      end

      user.save!
      user
    end
  end
end
