defmodule Mix.Tasks.Aoc.Gen.Live do
  use Mix.Task

  @shortdoc "Generates a LiveView for a specific Advent of Code year/day"

  @moduledoc """
  Generates a namespaced Phoenix LiveView for Advent of Code.

      mix aoc.gen.live 2015 3

  This will generate:

      lib/aoc_visualized_web/live/y2015/day03_live.ex
      Module: AocVisualizedWeb.Y2015.Day03Live

  Then add this to your router:

      live "/2015/day3", Y2015.Day03Live
  """

  def run([year, day]) do
    app = Mix.Project.config()[:app]
    app_module = Macro.camelize(to_string(app))

    year_mod = "Y#{year}"
    day_padded = String.pad_leading(day, 2, "0")
    day_mod = "Day#{day_padded}Live"

    file_path = "lib/#{app}_web/live/y#{year}/day#{day_padded}_live.ex"
    create_file_path(file_path)

    contents = """
    defmodule #{app_module}Web.#{year_mod}.#{day_mod} do
      use Phoenix.LiveView
      import Phoenix.Component

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> assign(:running, false)
         |> assign(:input, "")
         |> assign(:message, nil)}
      end

      def handle_event("update_input", %{"input" => input}, socket) do
        {:noreply, assign(socket, :input, input)}
      end

      def handle_event("start", _params, socket) do
        # Add your logic here to start visualizing based on socket.assigns.input
        {:noreply, assign(socket, running: true, message: "Visualization started!")}
      end

      def render(assigns) do
        ~H\"""
        <div class="p-4 space-y-4">
          <h1 class="text-xl font-bold">Day #{String.trim_leading(day_padded, "0")} Visualization</h1>

          <div class="grid grid-cols-2 gap-4">
            <form phx-change="update_input" phx-submit="start" class="col-start-2">
              <textarea
                name="input"
                class="w-full h-32 p-2 border border-gray-300 rounded"
                placeholder="Paste your puzzle input here"
              ><%= @input %></textarea>

              <button type="submit" class="mt-2 bg-blue-600 text-white px-4 py-2 rounded">
                Start
              </button>
            </form>
            <div class="col-start-1 row-start-1">
              <%= if @running do %>
                <p class="text-green-600 font-semibold"><%= @message || "Running..." %></p>
              <% else %>
                <p class="text-gray-500">Waiting to start...</p>
              <% end %>
            </div>
          </div>
        </div>
        \"""
      end
    end
    """

    File.write!(file_path, contents)

    Mix.shell().info([:green, "✅ Created: ", :reset, file_path])
    Mix.shell().info("\nNow add this to your router:\n")
    Mix.shell().info("    live \"/#{year}/day#{day}\", #{year_mod}.#{day_mod}\n")
  end

  def run(_args) do
    Mix.shell().error("Usage: mix aoc.gen.live YEAR DAY")
  end

  defp create_file_path(path) do
    path |> Path.dirname() |> File.mkdir_p!()
  end
end
