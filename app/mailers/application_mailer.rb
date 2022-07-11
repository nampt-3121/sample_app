class ApplicationMailer < ActionMailer::Base
  default from: ENV["host_email"]
  layout "mailer"
end
