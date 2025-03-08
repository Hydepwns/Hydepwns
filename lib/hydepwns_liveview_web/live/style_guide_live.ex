defmodule HydepwnsLiveviewWeb.StyleGuideLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Components.ThemeToggle

  def mount(_params, _session, socket) do
    # Set default theme if not already set by the client
    system_theme = if connected?(socket), do: get_system_theme(), else: "light"
    
    {:ok, assign(socket, theme_class: "#{system_theme}-theme")}
  end

  def handle_event("change_theme", %{"theme" => theme}, socket) do
    {:noreply, 
      socket
      |> assign(:theme_class, "#{theme}-theme")
      |> push_event("change_theme", %{theme: theme})
    }
  end

  def render(assigns) do
    ~H"""
    <main phx-hook="GridFadeIn" class="grid-fade-in">
      <.header_table>
        <:left>
          <h1>Monospace Style Guide</h1>
        </:left>
        <:right>
          <.link navigate={~p"/"}>← Back to Home</.link>
          <ThemeToggle.theme_toggle />
        </:right>
      </.header_table>

      <p>
        This style guide showcases the monospace web components and design patterns 
        used in the Hydepwns application. All elements are aligned to a character grid
        for precise, pixel-perfect typography.
      </p>

      <h2>Typography</h2>

      <h3>Headings</h3>
      <h1>Heading 1</h1>
      <h2>Heading 2</h2>
      <h3>Heading 3</h3>
      <h4>Heading 4</h4>
      <h5>Heading 5</h5>
      <h6>Heading 6</h6>

      <h3>Paragraphs</h3>
      <p>
        This is a standard paragraph with monospace typography. The text aligns perfectly
        to the character grid, with line height set to multiples of the base unit.
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
        incididunt ut labore et dolore magna aliqua.
      </p>

      <h3>Text Formatting</h3>
      <p><strong>Bold text</strong> and <em>italic text</em> and <code>inline code</code>.</p>

      <h3>Block Quote</h3>
      <blockquote>
        This is a blockquote. It's indented and has a border on the left side.
        The typography inside maintains the monospace grid.
      </blockquote>

      <h2>Grid & Layout</h2>

      <h3>Header Table</h3>
      <.header_table>
        <:left>
          <strong>Left Column</strong>
        </:left>
        <:right>
          <strong>Right Column</strong>
        </:right>
      </.header_table>

      <h3>Standard Table</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>John Doe</td>
            <td>john@example.com</td>
            <td>Admin</td>
          </tr>
          <tr>
            <td>Jane Smith</td>
            <td>jane@example.com</td>
            <td>User</td>
          </tr>
        </tbody>
      </table>

      <h3>Grid Layout</h3>
      <div class="grid">
        <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">Column 1</div>
        <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">Column 2</div>
        <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">Column 3</div>
      </div>

      <h2>Components</h2>

      <h3>Navigation</h3>
      <.nav>
        <:item link={~p"/"}>Home</:item>
        <:item link={~p"/style-guide"} active>Style Guide</:item>
        <:item link="#typography">Typography</:item>
        <:item link="#components">Components</:item>
      </.nav>

      <h3>Lists</h3>
      <h4>Unordered List</h4>
      <ul>
        <li>Item one</li>
        <li>Item two</li>
        <li>Item three</li>
        <li>
          Item with sublist
          <ul>
            <li>Subitem one</li>
            <li>Subitem two</li>
          </ul>
        </li>
      </ul>

      <h4>Ordered List</h4>
      <ol>
        <li>First item</li>
        <li>Second item</li>
        <li>Third item</li>
        <li>
          Item with sublist
          <ol>
            <li>Subitem one</li>
            <li>Subitem two</li>
          </ol>
        </li>
      </ol>

      <h3>Details & Summary</h3>
      <details>
        <summary>Click to expand</summary>
        <p>
          This is collapsible content that maintains the monospace grid layout.
          All spacing is calculated in character units.
        </p>
      </details>

      <h3>Form Elements</h3>
      <form phx-submit="noop">
        <label>
          Text Input
          <input type="text" placeholder="Enter some text" />
        </label>

        <label>
          <input type="checkbox" /> Checkbox
        </label>

        <label>
          <input type="radio" name="radio-example" /> Radio Option 1
        </label>
        <label>
          <input type="radio" name="radio-example" /> Radio Option 2
        </label>

        <button type="submit">Submit Form</button>
      </form>

      <h3>Code Block</h3>
      <pre><code>defmodule Example do
  def hello do
    IO.puts("Hello, Monospace World!")
  end
end</code></pre>

      <h2>Grid-Based Animations</h2>

      <h3>Typewriter Effect</h3>
      <p phx-hook="CharacterAnimation" class="typewriter">This text is revealed character by character.</p>

      <h3>Character Fade In</h3>
      <p phx-hook="CharacterAnimation" class="char-fade">Each character fades in separately.</p>

      <h3>Grid Slide In</h3>
      <p class="grid-slide-in">This text slides in by character increments.</p>

      <h3>Cursor Blink</h3>
      <p>Command prompt <span class="cursor-blink"></span></p>

      <h3>ASCII Spinner</h3>
      <p>Loading <span class="ascii-spinner"></span></p>

      <h3>Border Draw Animation</h3>
      <div class="border-draw">
        This box has an animated border that follows the character grid.
      </div>

      <h2>Theme Support</h2>

      <p>
        The monospace web design includes built-in theme support. You can toggle 
        between Light, Dark, and Dim themes using the toggle in the header.
      </p>

      <h3>Light Theme</h3>
      <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">
        Default light theme with black text on white background.
      </div>

      <h3>Dark Theme</h3>
      <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">
        Dark theme with white text on black background.
      </div>

      <h3>Dim Theme</h3>
      <div style="border: var(--border-thickness) solid var(--text-color); padding: 1ch;">
        Dim theme with a synthwave-inspired color palette.
      </div>

      <h2>Debug Tools</h2>

      <p>
        Use the Debug Grid toggle in the bottom left corner to visualize the 
        character grid and identify any misaligned elements.
      </p>

      <hr />
      <p>Monospace Web Design - © <%= DateTime.utc_now.year %> Hydepwns</p>
    </main>
    """
  end

  # Get system theme preference (if connected)
  defp get_system_theme do
    # Default to light theme if we can't detect
    "light"
  end

  # Placeholder for form submission
  def handle_event("noop", _params, socket) do
    {:noreply, socket}
  end
end
