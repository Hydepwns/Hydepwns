defmodule HydepwnsLiveviewWeb.Components.UI.DebugGrid do
  use Phoenix.Component

  @doc """
  Renders a debug grid toggle for visualizing the monospace grid alignment.
  
  ## Example
  
      <.debug_grid />
  """
  attr :class, :string, default: nil
  attr :rest, :global

  def debug_grid(assigns) do
    ~H"""
    <div class={["debug-toggle", @class]} {@rest}>
      <label class="debug-toggle-label">
        <input
          type="checkbox"
          id="debug-grid-toggle"
          phx-hook="DebugGridToggle"
          aria-label="Toggle debug grid"
        /> Show grid
      </label>
    </div>
    <div class="debug-grid" style="display: none;" aria-hidden="true"></div>
    <.script>
    document.addEventListener("DOMContentLoaded", () => {
      const toggle = document.getElementById('debug-grid-toggle');
      const grid = document.querySelector('.debug-grid');
      
      const setDebugMode = (enabled) => {
        document.body.classList.toggle('debug', enabled);
        grid.style.display = enabled ? 'block' : 'none';
        
        // Highlight elements that might be misaligned
        if (enabled) {
          document.querySelectorAll('*').forEach(el => {
            const rect = el.getBoundingClientRect();
            const width = rect.width;
            const height = rect.height;
            
            // Check if element width is a multiple of character width (ch)
            const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
            const isOffGridX = width % charWidth !== 0;
            const isOffGridY = height % parseFloat(getComputedStyle(document.documentElement).lineHeight) !== 0;
            
            if (isOffGridX || isOffGridY) {
              el.classList.add('off-grid');
            } else {
              el.classList.remove('off-grid');
            }
          });
        } else {
          document.querySelectorAll('.off-grid').forEach(el => {
            el.classList.remove('off-grid');
          });
        }
      };
      
      // Initialize from localStorage
      const debugEnabled = localStorage.getItem('debugGrid') === 'true';
      toggle.checked = debugEnabled;
      setDebugMode(debugEnabled);
      
      // Toggle debug mode
      toggle.addEventListener('change', () => {
        localStorage.setItem('debugGrid', toggle.checked);
        setDebugMode(toggle.checked);
      });
    });
    </.script>
    """
  end
end 