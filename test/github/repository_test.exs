defmodule SlackCoder.Github.RepositoryTest do
  use Pavlov.Case, async: true
  alias SlackCoder.Models.PR
  import SlackCoder.Support.Github
  alias SlackCoder.Github.Helper
  alias SlackCoder.Github.Watchers.Repository, as: Watcher
  use Timex

  before :each do
    Ecto.Adapters.SQL.Sandbox.checkout(SlackCoder.Repo)
  end

  describe "stale notifications" do
    let :now, do: Timex.Date.now
    let :two_hours_ago, do: Timex.Date.now |> Timex.Date.subtract(Timex.Time.to_timestamp(2, :hours))
    let :three_hours_ago, do: Timex.Date.now |> Timex.Date.subtract(Timex.Time.to_timestamp(3, :hours))
    let :ten_hours_ago, do: Timex.Date.now |> Timex.Date.subtract(Timex.Time.to_timestamp(10, :hours))
    describe "sends a notification" do
      it "equal to the backoff hours" do
        cs = PR.changeset pr_with(%{backoff: 2, latest_comment: two_hours_ago, opened_at: three_hours_ago}), %{latest_comment: two_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 4 = pr.backoff # Bumps to the next
        assert true = send_notification
      end
      it "more than the backoff hours" do
        cs = PR.changeset pr_with(%{backoff: 2, latest_comment: three_hours_ago, opened_at: three_hours_ago}), %{latest_comment: three_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 4 = pr.backoff # Bumps to the next
        assert true = send_notification
      end
      it "more than one backoff step" do
        cs = PR.changeset pr_with(%{backoff: 2, latest_comment: ten_hours_ago, opened_at: ten_hours_ago}), %{latest_comment: ten_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 16 = pr.backoff
        assert true = send_notification
      end
      it "handles a new PR" do
        cs = PR.changeset pr_with(%{backoff: 2, opened_at: ten_hours_ago}), %{latest_comment: ten_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 16 = pr.backoff
        assert 10 = Timex.Date.diff(pr.latest_comment, Helper.now, :hours)
        assert true = send_notification
      end
    end

    describe "does not send a notification" do
      it "below the backoff" do
        cs = PR.changeset pr_with(%{backoff: 4, latest_comment: two_hours_ago, opened_at: three_hours_ago}), %{latest_comment: two_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 4 = pr.backoff # Keeps the same
        assert 2 = Timex.Date.diff(pr.latest_comment, Helper.now, :hours)
        assert send_notification == nil
      end
      it "handles a new PR" do
        cs = PR.changeset pr_with(%{backoff: 4, opened_at: three_hours_ago}), %{latest_comment: two_hours_ago}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 4 = pr.backoff # Keeps the same
        assert 2 = Timex.Date.diff(pr.latest_comment, Helper.now, :hours)
        assert send_notification == nil
      end
      it "1 backoff" do
        cs = PR.changeset pr_with(%{backoff: 1, latest_comment: now, opened_at: three_hours_ago}), %{latest_comment: now}
        {pr, send_notification} = Watcher.stale_pr cs
        assert 1 = pr.backoff # Keeps the same
        assert 0 = Timex.Date.diff(pr.latest_comment, Helper.now, :hours)
        assert send_notification == nil
      end
    end
  end

end
