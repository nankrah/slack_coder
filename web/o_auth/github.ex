defmodule SlackCoder.OAuth.Github do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  defp config do
    [
      strategy: __MODULE__,
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ]
  end

  # Public API

  def client do
    Application.get_env(:slack_coder, :github_oauth)
    |> Keyword.merge(config())
    |> OAuth2.Client.new
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ []) do
    OAuth2.Client.get_token!(client(), params)
  end

  # Strategy Callbacks

 def authorize_url(client, params) do
   AuthCode.authorize_url(client, params)
 end

 def get_token(client, params, headers) do
   client
   |> put_header("Accept", "application/json")
   |> AuthCode.get_token(params, headers)
 end

end
