class Api::V1::BaseApiController < ApplicationController
  def current_user
    @current_user ||= User.first
    # @current_user ||= User.find_by(id: session[:id])
  end

  # Controllerでつかえるようにhelper_method :current_userを付け加えている
  # 今回はBaseApiを引き継いだcontrollerでメソッドを呼び出すので必要なし
  # helper_method :current_user
end
