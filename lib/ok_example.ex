defmodule OKExample do
  @moduledoc """
  Examples using OK
  """

  import OK, only: [~>: 2, ~>>: 2]

  def failure do
    OK.failure("a custom reason for the failure") == {:error, "a custom reason for the failure"}
  end

  def success do
    OK.success(1) == {:ok, 1}
  end

  @doc """
  Unwraps ok tuples, but leaves error tuples unchanged
  """
  def flat_map_success do
    OK.flat_map({:ok, 1}, &double/1) == 2
  end

  def flat_map_failure do
    OK.flat_map({:error, "oh no"}, &double/1) == {:error, "oh no"}
  end

  def for_success do
    OK.for do
      one <- OK.success(1)
      two <- OK.success(2)
    after
      one + two
    end == {:ok, 3}
  end

  def for_failure do
    OK.for do
      one <- OK.success(1)
      two <- OK.failure("oops")
    after
      one + two
    end == {:error, "oops"}
  end

  def map_success do
    OK.map({:ok, 1}, &double/1) == {:ok, 2}
  end

  def map_failure do
    OK.map({:error, "eek"}, &double/1) == {:error, "eek"}
  end

  @doc """
  OK.map_all must return an ok/error tuple
  """
  def map_all_success do
    OK.map_all(["1", "2", "3"], &safe_to_int/1) == {:ok, [1, 2, 3]}
  end

  def map_all_failure do
    OK.map_all(["1", "abc", 666], &safe_to_int/1) == {:error, :not_a_number}
  end

  def required_success do
    OK.required("any value") == {:ok, "any value"}
  end

  @doc """
  OK.required can take an optional second argument for an error reason
  """
  def required_failure do
    OK.required(nil) == {:error, :value_required}
  end

  @doc """
  OK.try returns the after unwrapped
  """
  def try_success do
    OK.try do
      one <- OK.success(1)
      two <- OK.success(2)
    after
      one + two
    rescue
      :who_cares -> "doesn't matter"
    end == 3
  end

  def try_failure do
    OK.try do
      one <- OK.success(1)
      two <- OK.required(nil, :i_need_this)
    after
      one + two
    rescue
      :i_need_this ->
        :i_really_needed_that
    end == :i_really_needed_that
  end

  def wrap_success do
    Enum.all?(
      [
        OK.wrap(1),
        {:ok, 1},
        OK.success(1)
      ],
      & &1
    )
  end

  def wrap_failure do
    Enum.all?(
      [
        OK.wrap({:error, :wrong}),
        {:error, :wrong},
        OK.failure(:wrong)
      ],
      & &1
    )
  end

  @doc """
  ~> wraps your result in a tuple
  """
  def pipe_map_success do
    {:ok, 1}
    ~> Kernel.+(2)
    ~> Kernel.+(3)
    |> Kernel.==({:ok, 6})
  end

  def pipe_map_failure do
    {:error, :reason}
    ~> Kernel.+(2)
    ~> Kernel.+(3)
    |> Kernel.==({:error, :reason})
  end

  def pipe_map_internal_failure do
    {:ok, 1}
    ~>> create_an_error()
    ~> Kernel.+(3)
    |> Kernel.==({:error, :an_error})
  end

  def pipe_flat_map_success do
    {:ok, 1}
    ~>> Kernel.+(2)
    |> Kernel.==(3)
  end

  def pipe_flat_map_failure do
    {:error, :reason}
    ~>> Kernel.+(2)
    |> Kernel.==({:error, :reason})
  end

  # Utils
  defp create_an_error(_), do: {:error, :an_error}

  defp double(x), do: x + x

  defp safe_to_int(x) when is_binary(x) do
    if Regex.match?(~r/\d/, x) do
      {:ok, String.to_integer(x)}
    else
      {:error, :not_a_number}
    end
  end

  defp safe_to_int(_) do
    {:error, :not_a_string}
  end
end
