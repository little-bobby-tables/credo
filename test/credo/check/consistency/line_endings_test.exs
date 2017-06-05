defmodule Credo.Check.Readability.LineEndingsTest do
  use Credo.TestHelper

  @described_check Credo.Check.Consistency.LineEndings

  @unix_line_endings """
defmodule Credo.Sample do
  defmodule InlineModule do
    def foobar do
      {:ok} = File.read
    end
  end
end
"""
  @unix_line_endings2 """
defmodule OtherModule do
  defmacro foo do
    {:ok} = File.read
  end

  defp bar do
    :ok
  end
end
"""
  @windows_line_endings "defmodule Credo.Sample\r\ndo\r\n@test :foo\r\nend\r\n"

  #
  # cases NOT raising issues
  #

  test "it should not report cosistent line endings across different files" do
    [@unix_line_endings, @unix_line_endings2]
    |> to_source_files
    |> refute_issues(@described_check)
  end

  test "it should not report enforced line endings" do
    @windows_line_endings
    |> to_source_file
    |> refute_issues(@described_check,
        enforced: Credo.Check.Consistency.LineEndings.Windows)
  end

  #
  # cases raising issues
  #

  test "it should report an issue for incosistent line endings across different files" do
    [@unix_line_endings, @windows_line_endings]
    |> to_source_files
    |> assert_issue(@described_check)
  end

  test "it should report an issue for line endings that do not match enforced" do
    @unix_line_endings
    |> to_source_file
    |> assert_issue(@described_check,
        [enforced: Credo.Check.Consistency.LineEndings.Windows],
        &assert(String.match?(&1.message, ~r/using unix.+enforced style is windows/)))
  end

end
