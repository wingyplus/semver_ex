defmodule SemanticVersionTest do
  use ExUnit.Case
  doctest SemanticVersion

  test "parse/1" do
    assert SemanticVersion.parse("1.0.0") == {:ok, {1, 0, 0, nil, nil}}
    assert SemanticVersion.parse("100.23.101") == {:ok, {100, 23, 101, nil, nil}}
  end

  test "parse/1 - error" do
    assert {:error, _} = SemanticVersion.parse("a.0.0")
  end

  test "parse/1 - pre-release" do
    assert SemanticVersion.parse("1.0.0-alpha") == {:ok, {1, 0, 0, "alpha", nil}}
    assert SemanticVersion.parse("1.0.0-0.3.7") == {:ok, {1, 0, 0, "0.3.7", nil}}
    assert SemanticVersion.parse("1.0.0-x.7.z.92") == {:ok, {1, 0, 0, "x.7.z.92", nil}}
  end

  test "parse/1 - build metadata" do
    assert SemanticVersion.parse("1.0.0+001") == {:ok, {1, 0, 0, nil, "001"}}

    assert SemanticVersion.parse("1.0.0+20130313144700") ==
             {:ok, {1, 0, 0, nil, "20130313144700"}}

    assert SemanticVersion.parse("1.0.0+exp.sha.5114f85") ==
             {:ok, {1, 0, 0, nil, "exp.sha.5114f85"}}
  end

  test "parse/1 - mixed pre-release and build metadata" do
    assert SemanticVersion.parse("1.0.0-beta+exp.sha.5114f85") ==
             {:ok, {1, 0, 0, "beta", "exp.sha.5114f85"}}
  end
end
