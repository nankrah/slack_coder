defmodule SlackCoder.ErrorView do
  use SlackCoder.Web, :view
  require Logger

  def render("400.html", _assigns) do
    render "500.html"
  end

  def render("401.json", _assigns) do
    %{status: 401, message: "That resource is not authorized"}
  end

  def render("404.json", _assigns) do
    %{status: 404, message: "Not found"}
  end

  def render("500.json", _assigns) do
    %{status: 500, message: "Internal Server Error"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(template, assigns) do
    Logger.error "Unable to find template #{template} with assigns #{inspect assigns}"
    render "500.html", assigns
  end
end
