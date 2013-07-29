require 'rubygems'
require 'google_calendar'
require 'google/api_client'
require 'sinatra'
require 'logger'

enable :sessions

def logger; settings.logger end

def api_client; settings.api_client; end

def calendar_api; settings.calendar; end

def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
  )
end

configure do
  log_file = File.open('calendar.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG
  
  client = Google::APIClient.new
  client.authorization.client_id = '723207254743.apps.googleusercontent.com'
  client.authorization.client_secret = 'zeDwVzuPp9RVPMNSktTn0LfT'
  client.authorization.scope = 'https://www.googleapis.com/auth/calendar'

  calendar = client.discovered_api('calendar', 'v3')

  set :logger, logger
  set :api_client, client
  set :calendar, calendar
end

before do
  # Ensure user has authorized the app
  unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
    redirect to('/oauth2authorize')
  end
end

after do
  # Serialize the access/refresh token to the session
  session[:access_token] = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in] = user_credentials.expires_in
  session[:issued_at] = user_credentials.issued_at
end

get '/oauth2authorize' do
  # Request authorization
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  redirect to('/')
end

event = {
  'summary' => 'Appointment',
  'location' => 'Somewhere',
  'start' => {
    'dateTime' => '2011-06-03T10:00:00.000-07:00'
  },
  'end' => {
      'dateTime' => '2011-06-03T10:25:00.000-07:00'
    },
  'attendees' => [
        {
          'email' => 'attendeeEmail'
        },
  ]
}

result = api_client.execute(:api_method => settings.calendar.events.insert,
		                               :parameters => {'calendarId' => 'primary'},
		                               :body => JSON.dump(event),
		                               :headers => {'Content-Type' => 'application/json'})
print result.data.id

get '/' do
  # Fetch list of events on the user's default calandar
  result = api_client.execute(:api_method => settings.calendar.events.list,
                              :parameters => {'calendarId' => 'primary'},
                              :authorization => user_credentials)
  [result.status, {'Content-Type' => 'application/json'}, result.data.to_json]
end
