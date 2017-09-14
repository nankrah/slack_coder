defmodule SlackCoder.Services.RandomFailureService do
  @moduledoc """
  """
  alias SlackCoder.Models.RandomFailure
  alias SlackCoder.BuildSystem.Job
  alias SlackCoder.Repo
  alias SlackCoder.Models.PR
  require Logger

  def save(changeset) do
    changeset
    |> Repo.insert_or_update()
    |> case do
      {:ok, random_failure} ->
        {:ok, random_failure} # All is good
      errored_changeset ->
        Logger.error("Unable to save random failure\n\tchangeset: #{inspect changeset}\n\trandom failure: #{inspect changeset.data}")
        errored_changeset
    end
  end

  def save_random_failure(%PR{last_failed_jobs: []} = pr) do
    Logger.warn """
    Attempt to save random failed job but found no failure data.

    #{inspect pr, pretty: true}
    """
  end
  def save_random_failure(%PR{last_failed_jobs: [_ | _] = last_failed_jobs} = pr) do
    for %Job{id: id, system: system, rspec: rspec, rspec_seed: rspec_seed, cucumber: cucumber, cucumber_seed: cucumber_seed} <- last_failed_jobs do
      find_or_create_and_update!(rspec, id, system, :rspec, rspec_seed, pr)
      find_or_create_and_update!(cucumber, id, system, :cucumber, cucumber_seed, pr)
    end
  end

  defp find_or_create_and_update!([], _id, _system, _type, _seed, _pr), do: nil
  defp find_or_create_and_update!([{file, line, description} | failures], id, system, type, seed, pr) do
    RandomFailure.find_unique(pr.owner, pr.repo, file, line, description)
    |> Repo.one()
    |> case do
      %RandomFailure{count: count} = random_failure ->
        RandomFailure.changeset(random_failure, %{count: count + 1})
      nil ->
        RandomFailure.changeset(%RandomFailure{}, %{
          owner: pr.owner,
          repo: pr.repo,
          pr: pr.number,
          sha: pr.sha,
          file: file,
          line: to_string(line),
          description: description,
          seed: seed,
          count: 1,
          external_id: id,
          system: system,
          type: to_string(type)
        })
    end
    |> save()

    find_or_create_and_update!(failures, id, system, type, seed, pr)
  end
end
