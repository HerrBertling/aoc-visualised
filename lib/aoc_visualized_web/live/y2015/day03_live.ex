defmodule AocVisualizedWeb.Y2015.Day03Live do
  use Phoenix.LiveView
  import Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:running, false)
     |> assign(:input, "")
     |> assign(:santa_position, {0, 0})
     |> assign(:visited_houses, %{{0, 0} => 1})
     |> assign(:message, nil)
     |> assign(:mode, "part1")
     |> assign(:delay_ms, 50)}
  end

  def handle_event("start", _, %{assigns: %{running: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("start", %{"input" => input}, socket) do
    moves = String.trim(input) |> String.graphemes()

    case socket.assigns.mode do
      "part1" ->
        send(self(), {:santa_tick, moves, {0, 0}, %{{0, 0} => 1}})

      "part2" ->
        send(self(), {:santa_robo_tick, moves, 0, {0, 0}, {0, 0}, %{{0, 0} => 2}})
    end

    {:noreply,
     socket
     |> assign(:running, true)
     |> assign(:input, input)
     |> assign(:santa_position, {0, 0})
     |> assign(:robo_position, {0, 0})
     |> assign(:visited_houses, %{{0, 0} => 2})
     |> assign(:message, "Santa is delivering presents...")}
  end

  def handle_event("update_delay", %{"delay_ms" => delay}, socket) do
    delay = String.to_integer(delay)
    {:noreply, assign(socket, :delay_ms, delay)}
  end

  def handle_event("set_mode", %{"mode" => mode}, socket) when mode in ["part1", "part2"] do
    {:noreply, assign(socket, :mode, mode)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:running, false)
     |> assign(:input, "")
     |> assign(:santa_position, {0, 0})
     |> assign(:visited_houses, %{{0, 0} => 1})
     |> assign(:message, nil)}
  end

  def handle_info({:santa_tick, [], _pos, visited}, socket) do
    {:noreply,
     socket
     |> assign(:message, "Finished! 🎁")
     |> assign(:visited_houses, visited)
     |> assign(:running, false)}
  end

  def handle_info({:santa_tick, _moves, _pos, _visited}, %{assigns: %{running: false}} = socket) do
    {:noreply, socket}
  end

  def handle_info({:santa_tick, [move | rest], pos, visited}, socket) do
    new_pos =
      case move do
        "^" -> {elem(pos, 0), elem(pos, 1) + 1}
        "v" -> {elem(pos, 0), elem(pos, 1) - 1}
        ">" -> {elem(pos, 0) + 1, elem(pos, 1)}
        "<" -> {elem(pos, 0) - 1, elem(pos, 1)}
      end

    new_grid = Map.update(visited, new_pos, 1, &(&1 + 1))

    # Push new state to canvas
    visited_list =
      Enum.map(new_grid, fn {{x, y}, count} -> [%{x: x, y: y}, count] end)

    socket =
      socket
      |> assign(:santa_position, new_pos)
      |> assign(:visited_houses, new_grid)
      |> push_event("santa:update", %{
        santa: Tuple.to_list(new_pos),
        visited: visited_list
      })

    # Queue up next tick
    Process.send_after(self(), {:santa_tick, rest, new_pos, new_grid}, socket.assigns.delay_ms)

    {:noreply, socket}
  end

  def handle_info({:santa_robo_tick, [], _step, _santa_pos, _robo_pos, visited}, socket) do
    {:noreply,
     socket
     |> assign(:message, "Finished! 🎁")
     |> assign(:visited_houses, visited)
     |> assign(:running, false)}
  end

  def handle_info({:santa_robo_tick, [move | rest], step, santa_pos, robo_pos, visited}, socket) do
    actor = if rem(step, 2) == 0, do: :santa, else: :robo
    current_pos = if actor == :santa, do: santa_pos, else: robo_pos

    new_pos =
      case move do
        "^" -> {elem(current_pos, 0), elem(current_pos, 1) + 1}
        "v" -> {elem(current_pos, 0), elem(current_pos, 1) - 1}
        ">" -> {elem(current_pos, 0) + 1, elem(current_pos, 1)}
        "<" -> {elem(current_pos, 0) - 1, elem(current_pos, 1)}
      end

    new_grid = Map.update(visited, new_pos, 1, &(&1 + 1))
    new_santa = if actor == :santa, do: new_pos, else: santa_pos
    new_robo = if actor == :robo, do: new_pos, else: robo_pos

    visited_list =
      Enum.map(new_grid, fn {{x, y}, count} -> [%{x: x, y: y}, count] end)

    socket =
      socket
      |> assign(:santa_position, new_santa)
      |> assign(:robo_position, new_robo)
      |> assign(:visited_houses, new_grid)
      |> push_event("santa_robo:update", %{
        santa: Tuple.to_list(new_santa),
        robo: Tuple.to_list(new_robo),
        visited: visited_list
      })

    Process.send_after(
      self(),
      {:santa_robo_tick, rest, step + 1, new_santa, new_robo, new_grid},
      socket.assigns.delay_ms
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4 space-y-4">
      <h1 class="text-xl font-bold">Day 3 Visualization</h1>

      <div class="grid grid-cols-3 gap-4">
        <div class="col-start-3 space-y-4 flex flex-col gap-6">
          <form phx-submit="start" class="flex flex-col gap-2">
            <textarea
              name="input"
              class="w-full h-64 p-2 border border-slate-300 rounded text-sm font-mono"
              placeholder="Paste your puzzle input here"
            ><%= @input %></textarea>

            <div class="flex space-x-2">
              <button
                type="submit"
                class="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
                disabled={@running}
              >
                Start
              </button>

              <button
                type="button"
                phx-click="reset"
                class="bg-gray-500 text-white px-4 py-2 rounded disabled:opacity-50"
                disabled={!@running}
              >
                Reset
              </button>
            </div>
          </form>

          <form>
            <label class="block text-sm font-medium text-slate-700">
              Speed (delay per step): {@delay_ms} ms
            </label>
            <input
              type="range"
              min="10"
              max="1000"
              step="10"
              value={@delay_ms}
              name="delay_ms"
              phx-change="update_delay"
              disabled={@running}
              class="w-full"
            />
          </form>
          <form class="mt-4">
            <fieldset disabled={@running} class="disabled:opacity-50">
              <div class="flex flex-col gap-2">
                <legend class="text-sm font-medium text-slate-700">Mode:</legend>
                <label class="inline-flex items-center gap-1">
                  <input
                    type="radio"
                    name="mode"
                    value="part1"
                    checked={@mode == "part1"}
                    phx-change="set_mode"
                  />
                  <span>Part 1 (Santa only)</span>
                </label>
                <label class="inline-flex items-center gap-1">
                  <input
                    type="radio"
                    name="mode"
                    value="part2"
                    checked={@mode == "part2"}
                    phx-change="set_mode"
                  />
                  <span>Part 2 (Santa + Robo)</span>
                </label>
              </div>
            </fieldset>
          </form>
        </div>
        <div class="col-start-1 col-span-2 row-start-1">
          <p class="font-mono text-sm text-slate-700">Visited houses: {map_size(@visited_houses)}</p>
          <p class="text-green-600 font-semibold">{@message}</p>

          <canvas
            id="grid-canvas"
            width="500"
            height="500"
            phx-hook="SantaCanvas"
            class="border border-slate-800 w-full"
          />
        </div>
      </div>
    </div>
    """
  end
end
