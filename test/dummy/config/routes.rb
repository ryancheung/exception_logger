Rails.application.routes.draw do

  get "simulate/failure"

  mount ExceptionLogger::Engine => "/logger"
end
