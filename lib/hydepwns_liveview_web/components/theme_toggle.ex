defmodule HydepwnsLiveviewWeb.Components.ThemeToggle do
  use Phoenix.Component
  import Phoenix.HTML

  attr :class, :string, default: nil
  attr :rest, :global

  def theme_toggle(assigns) do
    ~H"""
    <div class={["flex items-center", @class]} {@rest}>
      <span class="mr-2 text-sm font-medium text-gray-700 dark:text-gray-200">Theme:</span>
      <button
        type="button"
        phx-hook="ThemeToggle"
        class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2 dark:bg-gray-700"
        role="switch"
        aria-checked="false"
      >
        <span class="sr-only">Toggle theme</span>
        <span
          id="theme-toggle-circle"
          class="pointer-events-none relative inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out dark:translate-x-5"
        >
          <span
            class="absolute inset-0 flex h-full w-full items-center justify-center transition-opacity duration-200 ease-in dark:opacity-0"
            aria-hidden="true"
          >
            <svg class="h-3 w-3 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" fill-rule="evenodd" clip-rule="evenodd"></path>
            </svg>
          </span>
          <span
            class="absolute inset-0 flex h-full w-full items-center justify-center transition-opacity duration-200 ease-in opacity-0 dark:opacity-100"
            aria-hidden="true"
          >
            <svg class="h-3 w-3 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
            </svg>
          </span>
        </span>
      </button>
      <.script>
      document.addEventListener("DOMContentLoaded", () => {
        const toggleTheme = () => {
          if (localStorage.theme === 'dark' || 
             (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
          } else {
            document.documentElement.classList.remove('dark');
          }
        };

        toggleTheme();

        window.addEventListener("phx:hook-themetoggle", e => {
          if (localStorage.theme === 'dark') {
            localStorage.theme = 'light';
          } else {
            localStorage.theme = 'dark';
          }
          toggleTheme();
        });
      });
      </.script>
    </div>
    """
  end
end
