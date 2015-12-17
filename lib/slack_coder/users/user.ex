defmodule SlackCoder.Users.User do
  use GenServer
  alias SlackCoder.Repo
  alias SlackCoder.Models.User
  alias SlackCoder.Slack
  import SlackCoder.Users.Help

  # Server API

  def start_link(user) do
    GenServer.start_link __MODULE__, user
  end

  def init(user) do
    {:ok, user}
  end

  for type <- SlackCoder.Users.Help.default_config_keys() do
    def handle_cast({unquote(type), user_for, message}, user) do
      if configured_to_send_message(unquote(type), user_for, user) do
        Slack.send_to(user.slack, message)
      end
      {:noreply, user}
    end
  end
  # Don't send unknown messages
  def handle_cast({_unknown, _user_for, _message}, user) do
    {:noreply, user}
  end

  def handle_cast({:help, message}, user) do
    {new_config, reply} = handle_message(message |> String.downcase |> String.split(" "), user.config)
    # {:ok, user} = User.changeset(user, %{config: new_config}) |> Repo.update
    if reply do
      Slack.send_to(user.slack, reply)
    end
    {:noreply, user}
  end
  def handle_cast({:update, new_user}, _user) do
    {:noreply, new_user}
  end

  def handle_call(:get, _from, user) do
    {:reply, user, user}
  end

  defp configured_to_send_message(type, user_for, user) do
    user.slack == user_for && user.config["#{type}_self"] || user.slack != user_for && user.config["#{type}_monitors"]
  end

  # Client API

  def notification(user_pid, {type, user, message}) do
    GenServer.cast user_pid, {type, user, message}
  end

  def help(user_pid, message) do
    GenServer.cast user_pid, {:help, message}
  end

  def get(user_pid) do
    GenServer.call user_pid, :get
  end

  def update(user_pid, user) do
    GenServer.cast user_pid, {:update, user}
  end

end
