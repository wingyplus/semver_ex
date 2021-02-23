defmodule SemanticVersion do
  @moduledoc """
  A module for read/parse semantic version.
  """

  @type major() :: non_neg_integer()
  @type minor() :: non_neg_integer()
  @type patch() :: non_neg_integer()
  @type pre_release() :: binary() | nil
  @type build_metadata() :: binary() | nil

  @type t() :: {major(), minor(), patch(), pre_release(), build_metadata()}

  import NimbleParsec

  major = integer(min: 1)

  minor = integer(min: 1)

  patch = integer(min: 1)

  pre_release = concat(string("-"), ascii_string([?a..?z, ?0..?9, ?.], min: 1))

  build_metadata = concat(string("+"), ascii_string([?a..?z, ?0..?9, ?.], min: 1))

  defparsecp :semantic_version,
             major
             |> ignore(string("."))
             |> concat(minor)
             |> ignore(string("."))
             |> concat(patch)
             |> optional(pre_release)
             |> optional(build_metadata)

  @doc """
  Parse a `version` string to semver structure.

  ## Examples

    iex> SemanticVersion.parse("1.0.0")
    {:ok, {1, 0, 0, nil, nil}}
    iex> SemanticVersion.parse("1.0.0-beta+20200121")
    {:ok, {1, 0, 0, "beta", "20200121"}}
  """
  @spec parse(binary()) ::
          {:ok, t()} | {:error, term()}
  def parse(version) when is_binary(version) do
    version
    |> semantic_version()
    |> case do
      {:ok, [major, minor, patch], _, _, _, _} ->
        {:ok, {major, minor, patch, nil, nil}}

      {:ok, [major, minor, patch, "-", pre_release], _, _, _, _} ->
        {:ok, {major, minor, patch, pre_release, nil}}

      {:ok, [major, minor, patch, "+", build_metadata], _, _, _, _} ->
        {:ok, {major, minor, patch, nil, build_metadata}}

      {:ok, [major, minor, patch, "-", pre_release, "+", build_metadata], _, _, _, _} ->
        {:ok, {major, minor, patch, pre_release, build_metadata}}

      {:error, reason, _, _, _, _} ->
        {:error, reason}
    end
  end

  @doc """
  Convert SemanticVersion.t() into string.
  """
  @spec format(t()) :: binary()
  def format(semver)

  def format({major, minor, patch, nil, nil}) do
    "#{major}.#{minor}.#{patch}"
  end

  def format({major, minor, patch, pre_release, nil}) do
    format({major, minor, patch, nil, nil}) <> "-#{pre_release}"
  end

  def format({major, minor, patch, pre_release, build_metadata}) do
    format({major, minor, patch, pre_release, nil}) <> "+#{build_metadata}"
  end
end
