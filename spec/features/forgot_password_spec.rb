require 'spec_helper'

feature 'User' do
  include ActiveSupport::Testing::TimeHelpers

  before do
    @user = create_user
    visit '/'
    @emails_sent = ActionMailer::Base.deliveries.length
    click_on 'Login'
    click_on 'Forgot Password?'
  end

  scenario 'user sent email and given message when when email entered' do
    fill_in 'user[email]', :with => "#{@user.email}"
    click_on 'Send Password Reset Instructions'
    expect(page).to have_content 'Email with instructions on resetting your password has been sent'
    expect(ActionMailer::Base.deliveries.length).to eq (@emails_sent + 1)
  end

  scenario 'user enters an email that does not exist, but sees a message saying it was sent (anti-phishing)' do
    fill_in 'user[email]', :with => 'not_in_database@example.com'
    click_on 'Send Password Reset Instructions'
    expect(page).to have_content 'Email with instructions on resetting your password has been sent'
    expect(ActionMailer::Base.deliveries.length).to eq (@emails_sent)
  end

  scenario 'invalid email given' do
    fill_in 'user[email]', :with => 'something'
    click_on 'Send Password Reset Instructions'
    expect(page).to have_content 'Please enter a valid email address'
  end

  scenario 'no email is given' do
    fill_in 'user[email]', :with => ''
    click_on 'Send Password Reset Instructions'
    expect(page).to have_content 'Please enter a valid email address'
  end

  scenario 'A user can reset their password' do
    mail_sent = ActionMailer::Base.deliveries.length
    visit '/'
    click_on 'Login'
    click_on 'Forgot Password'
    fill_in 'user[email]', with: @user.email
    click_on 'Send Password Reset Instructions'

    expect(ActionMailer::Base.deliveries.length).to eq(mail_sent + 1)
    expect(page).to have_content("Email with instructions on resetting your password has been sent")

    mail = ActionMailer::Base.deliveries.last
    @doc = Nokogiri::XML(mail.body.to_s)
    link = @doc.xpath("//a").first['href']

    visit link

    expect(page).to have_content("#{@user.email} has requested a password reset. Please enter:")


    fill_in 'user[new_password]', with: 'newpassword'
    fill_in 'user[new_password_confirmation]', with: 'newpassword'
    click_on 'Update'


    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'newpassword'
    click_on 'login'

    expect(page).to have_content("Welcome back #{@user.email}")
  end

  scenario 'A user cannot reset their password after time has expired, then will be able to successfully reset password' do
    mail_sent = ActionMailer::Base.deliveries.length
    visit '/'
    click_on 'Login'
    click_on 'Forgot Password'
    fill_in 'user[email]', with: @user.email
    click_on 'Send Password Reset Instructions'

    expect(ActionMailer::Base.deliveries.length).to eq(mail_sent + 1)
    expect(page).to have_content("Email with instructions on resetting your password has been sent")

    mail = ActionMailer::Base.deliveries.last
    @doc = Nokogiri::XML(mail.body.to_s)
    link = @doc.xpath("//a").first['href']
    travel_to(1.day.from_now) do

      visit link

      expect(page).to have_content 'Your password reset token has expired. Request a new password by clicking Forgot Password.'
      expect(page).to have_content 'Forgot your password?'
    end

    mail_sent = ActionMailer::Base.deliveries.length

    fill_in 'user[email]', with: @user.email
    click_on 'Send Password Reset Instructions'

    expect(ActionMailer::Base.deliveries.length).to eq(mail_sent + 1)
    expect(page).to have_content("Email with instructions on resetting your password has been sent")

    mail = ActionMailer::Base.deliveries.last
    @doc = Nokogiri::XML(mail.body.to_s)
    link = @doc.xpath("//a").first['href']

    visit link

    expect(page).to have_content("#{@user.email} has requested a password reset. Please enter:")

    fill_in 'user[new_password]', with: 'newpassword'
    fill_in 'user[new_password_confirmation]', with: 'newpassword'
    click_on 'Update'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'newpassword'
    click_on 'login'

    expect(page).to have_content("Welcome back #{@user.email}")

  end
end