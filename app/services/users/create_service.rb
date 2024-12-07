module Users
  class CreateService
    def initialize(params)
      @params = params
      @errors = {}
    end

    def execute
      validate_params!

      user = User.create(name: @params[:name])

      unless user.persisted?
        raise ErrorService.new(user.errors.messages)
      end

      user
    end

    private

    def validate_params!
      ValidationErrorHelper.add_error(@errors, :name, "Can't be blank") if @params[:name].blank?

      raise ErrorService.new(@errors) if @errors.any?
    end
  end
end
