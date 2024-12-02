defmodule TodolistWeb.CoreComponents do
  use Phoenix.Component
  use Phoenix.HTML

  alias Phoenix.LiveView.JS
  import Phoenix.Component

  # Only import the functions we need from Phoenix.HTML.Form
  import Phoenix.HTML.Form, except: [label: 1]
  
  # Import all Gettext functions
  import TodolistWeb.Gettext

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct"
  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false
  attr :rest, :global, include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                                 multiple pattern placeholder readonly required rows size step)
  attr :class, :string, default: nil

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_value(assigns.value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={if @type == "checkbox", do: "true", else: Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  attr :for, :any, default: nil, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"
  attr :id, :string, default: nil
  attr :multipart, :boolean, default: false
  attr :rest, :global, include: ~w(autocomplete name rel action enctype method novalidate target)
  attr :errors, :list, default: []
  attr :action, :string, default: nil

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} id={@id} action={@action} multipart={@multipart} {@rest}>
      <div class="mt-10 space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={error <- @errors} class="text-rose-600 text-sm"><%= error %></div>
        <div class="mt-2 flex items-center justify-end gap-4">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc """
  Renders a button.
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an error message.
  """
  attr :rest, :global
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden" {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Renders a checkbox.
  """
  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :label, :string, default: nil
  attr :value, :any
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(required form)

  def checkbox(assigns) do
    ~H"""
    <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value={@value}
        checked={@checked}
        class={[
          "rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900",
          @class
        ]}
        {@rest}
      />
      <%= @label %>
    </label>
    """
  end

  @doc """
  Shows a flash message.
  """
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :message, :string
  attr :rest, :global, default: %{}

  def flash(assigns) do
    ~H"""
    <div
      :if={@message}
      role="alert"
      class={[
        "rounded-lg p-3 ring-1 mb-4",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500"
      ]}
      {@rest}
    >
      <p class="text-sm leading-5"><%= @message %></p>
    </div>
    """
  end

  @doc """
  Renders a group of flash messages.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages to display"

  def flash_group(assigns) do
    ~H"""
    <div class="mb-8">
      <.flash
        :for={{kind, message} <- Map.to_list(@flash)}
        kind={kind}
        message={message}
      />
    </div>
    """
  end

  @doc """
  Renders an icon.
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  defp input_value(value), do: Phoenix.HTML.Form.normalize_value("checkbox", value)

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
