defmodule HydepwnsLiveviewWeb.Components.StyleGuide do
  @moduledoc """
  Provides a comprehensive style guide showcasing all UI components.
  
  This component acts as a living documentation of the design system,
  displaying examples of all available components along with their usage.
  """
  use HydepwnsLiveviewWeb, :live_component
  import Phoenix.Component
  import Phoenix.HTML.Form

  alias HydepwnsLiveviewWeb.Components.MonoGrid
  alias HydepwnsLiveviewWeb.Components.Terminal
  alias HydepwnsLiveviewWeb.Components.AsciiArtGenerator
  alias HydepwnsLiveviewWeb.Components.DiagramEditor
  alias HydepwnsLiveviewWeb.Components.ThemeToggle
  alias HydepwnsLiveviewWeb.Components.ApiDocs
  alias HydepwnsLiveviewWeb.Components.UI.Timeline
  alias HydepwnsLiveviewWeb.Components.UI.ProgressIndicator

  @doc """
  Renders the style guide component.
  """
  def render(assigns) do
    ~H"""
    <div class="style-guide" id={@id}>
      <h1 class="style-guide-title">Hydepwns Monospace Style Guide</h1>
      
      <p class="style-guide-intro">
        This style guide documents the components, typography, and design patterns used
        throughout the Hydepwns monospace web application.
      </p>
      
      <div class="style-guide-toc">
        <h2>Table of Contents</h2>
        <ul>
          <li><a href="#typography">Typography</a></li>
          <li><a href="#color-palette">Color Palette</a></li>
          <li><a href="#grid-system">Grid System</a></li>
          <li><a href="#components">Components</a></li>
        </ul>
      </div>

      <section id="typography" class="style-guide-section">
        <h2>Typography</h2>
        <p>Typography section content</p>
      </section>
      
      <section id="color-palette" class="style-guide-section">
        <h2>Color Palette</h2>
        <p>Color palette section content</p>
      </section>
      
      <section id="grid-system" class="style-guide-section">
        <h2>Grid System</h2>
        <p>Grid system section content</p>
      </section>
      
      <section id="components" class="style-guide-section">
        <h2>Components</h2>
        <p>Components section content</p>
        
        <h3>MonoGrid</h3>
        <.mono_grid cols={40} debug={true}>
          <.mono_grid_row>
            <.mono_grid_cell cols={40}>
              This is a demo of the MonoGrid component
            </.mono_grid_cell>
          </.mono_grid_row>
        </.mono_grid>
        
        <h3>Terminal Component</h3>
        <.live_component
          module={Terminal}
          id="demo-terminal"
          prompt="user@hydepwns:~$"
          welcome_message="Welcome to the Terminal component demo"
        />
        
        <h3>Theme Toggle</h3>
        <ThemeToggle.theme_toggle />
        
        <h3>ASCII Art Generator</h3>
        <.live_component
          module={AsciiArtGenerator}
          id="demo-ascii-art-generator"
        />
        
        <h3>Info Box Component</h3>
        <p>The Info Box component is used to display contextual information and tips.</p>
        
        <h4>Standard Info Box</h4>
        <.info_box id="demo-info-box" type={:info}>
          This is an information box. It provides useful context to users.
        </.info_box>
        
        <h4>Tip Box</h4>
        <.info_box id="demo-tip-box" type={:tip} title="Pro Tip">
          You can press <.kbd>Alt+R</.kbd> to replay animations on this site.
        </.info_box>
        
        <h4>Warning Box</h4>
        <.info_box id="demo-warning-box" type={:warning}>
          This is a warning message. Be careful with this operation.
        </.info_box>
        
        <h4>Error Box</h4>
        <.info_box id="demo-error-box" type={:error} title="Error Occurred">
          Something went wrong. Please try again or contact support.
        </.info_box>
        
        <h4>Dismissible Info Box</h4>
        <.info_box id="demo-dismissible-box" type={:info} dismissible={true} title="Dismissible Box">
          This box can be dismissed by clicking the X button. The dismissal state is saved in localStorage.
        </.info_box>
        
        <h3>Monospace Form Components</h3>
        <p>The monospace form components maintain grid alignment while providing styled form controls.</p>
        
        <.mono_form for={%{}} as={:demo_form} phx-submit="demo_submit">
          <.mono_input field={to_form(%{})[:name]} label="Name" placeholder="Enter your name" required={true} />
          
          <.mono_input field={to_form(%{})[:email]} type="email" label="Email" placeholder="your@email.com" helper_text="We'll never share your email" />
          
          <.mono_input field={to_form(%{})[:password]} type="password" label="Password" />
          
          <.mono_input field={to_form(%{})[:bio]} type="textarea" label="Biography" placeholder="Tell us about yourself" rows={3} />
          
          <.mono_input 
            field={to_form(%{})[:plan]} 
            type="select" 
            label="Subscription Plan" 
            options={[{"free", "Free Plan"}, {"pro", "Pro Plan"}, {"enterprise", "Enterprise Plan"}]}
          />
          
          <.mono_input 
            field={to_form(%{})[:agree]} 
            type="checkbox" 
            label="I agree to the terms of service" 
            required={true}
          />
          
          <div style="display: flex; gap: 1ch;">
            <.mono_submit>Subscribe</.mono_submit>
            <.mono_button type="button">Cancel</.mono_button>
          </div>
        </.mono_form>
        
        <h3>Monospace Tabs Component</h3>
        <p>The monospace tabs component provides a tabbed interface that maintains grid alignment.</p>
        
        <h4>Bordered Tabs (Default)</h4>
        <.mono_tabs id="demo-tabs-bordered">
          <:tab id="tab1" title="First Tab">
            <p>This is the content of the first tab.</p>
            <p>The content is wrapped in a MonoGrid to maintain character alignment.</p>
          </:tab>
          <:tab id="tab2" title="Second Tab">
            <p>Content for the second tab goes here.</p>
            <p>You can navigate between tabs using keyboard arrow keys.</p>
          </:tab>
          <:tab id="tab3" title="Third Tab">
            <p>This is the third tab's content.</p>
            <p>Tab state is persisted in localStorage.</p>
          </:tab>
        </.mono_tabs>
        
        <h4>Underlined Tabs</h4>
        <.mono_tabs id="demo-tabs-underlined" style={:underlined}>
          <:tab id="tab1" title="Documentation">
            <p>Documentation tab content.</p>
          </:tab>
          <:tab id="tab2" title="Examples">
            <p>Examples tab content.</p>
          </:tab>
          <:tab id="tab3" title="API Reference">
            <p>API Reference tab content.</p>
          </:tab>
        </.mono_tabs>
        
        <h4>Boxed Tabs</h4>
        <.mono_tabs id="demo-tabs-boxed" style={:boxed}>
          <:tab id="tab1" title="HTML">
            <pre><code>&lt;div&gt;Example HTML code&lt;/div&gt;</code></pre>
          </:tab>
          <:tab id="tab2" title="CSS">
            <pre><code>.example &#123; color: blue; &#125;</code></pre>
          </:tab>
          <:tab id="tab3" title="JavaScript">
            <pre><code>function example() &#123; return true; &#125;</code></pre>
          </:tab>
        </.mono_tabs>
        
        <h4>Vertical Tabs</h4>
        <.mono_tabs id="demo-tabs-vertical" vertical={true}>
          <:tab id="tab1" title="Section 1">
            <p>Content for Section 1.</p>
            <p>Vertical tabs are useful for documentation or settings pages.</p>
          </:tab>
          <:tab id="tab2" title="Section 2">
            <p>Content for Section 2.</p>
          </:tab>
          <:tab id="tab3" title="Section 3">
            <p>Content for Section 3.</p>
          </:tab>
        </.mono_tabs>
        
        <h3>Timeline Component</h3>
        <p>The timeline component uses ASCII art to represent chronological events.</p>
        
        <h4>Vertical Timeline</h4>
        <Timeline.vertical_timeline id="demo-vertical-timeline" line_style="solid">
          <:event title="Project Start" date="2023-01-15">
            Initial project setup and planning phase.
          </:event>
          <:event title="Alpha Release" date="2023-03-22" highlight={true}>
            First alpha version released to early testers.
          </:event>
          <:event title="Beta Release" date="2023-06-10">
            Beta version with core features implemented.
          </:event>
          <:event title="Version 1.0" date="2023-09-01" highlight={true}>
            Official release with all planned features.
          </:event>
        </Timeline.vertical_timeline>
        
        <h4>Horizontal Timeline</h4>
        <Timeline.horizontal_timeline id="demo-horizontal-timeline" line_style="dashed">
          <:event title="Planning" date="Q1 2023">
            Project planning and requirements gathering.
          </:event>
          <:event title="Development" date="Q2 2023" highlight={true}>
            Core feature development.
          </:event>
          <:event title="Testing" date="Q3 2023">
            QA and beta testing phase.
          </:event>
          <:event title="Release" date="Q4 2023" highlight={true}>
            Public release and marketing.
          </:event>
        </Timeline.horizontal_timeline>
        
        <h4>Dotted Timeline</h4>
        <Timeline.vertical_timeline id="demo-dotted-timeline" line_style="dotted">
          <:event title="Concept" date="Week 1">
            Initial concept and brainstorming.
          </:event>
          <:event title="Design" date="Week 2" highlight={true}>
            UI/UX design and prototyping.
          </:event>
          <:event title="Development" date="Week 3-4">
            Implementation of core features.
          </:event>
        </Timeline.vertical_timeline>
        
        <h3>Progress Indicators</h3>
        <p>Progress indicators provide visual feedback about the status of operations.</p>
        
        <h4>Linear Progress Bar</h4>
        <ProgressIndicator.linear_progress id="demo-progress-bar" value={75} max={100} label="75% Complete" />
        
        <h4>Custom Progress Bar</h4>
        <ProgressIndicator.linear_progress id="demo-custom-progress" value={50} max={100} 
                                          empty_char="░" filled_char="█" width={30} />
        
        <h4>Animated Progress Bar</h4>
        <ProgressIndicator.linear_progress id="demo-animated-progress" value={60} max={100} 
                                          animate={true} label="Loading..." />
        
        <h4>Step Indicator (Numbered)</h4>
        <ProgressIndicator.step_indicator id="demo-step-indicator" 
                                         current_step={2} 
                                         total_steps={4} 
                                         labels={["Cart", "Shipping", "Payment", "Confirmation"]} />
        
        <h4>Step Indicator (Dots)</h4>
        <ProgressIndicator.step_indicator id="demo-dots-indicator" 
                                         style="dots"
                                         current_step={2} 
                                         total_steps={3} 
                                         labels={["Input", "Processing", "Output"]} />
        
        <h4>Step Indicator (Arrows)</h4>
        <ProgressIndicator.step_indicator id="demo-arrows-indicator" 
                                         style="arrows"
                                         current_step={1} 
                                         total_steps={3} />
        
        <h4>Loading Spinners</h4>
        <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
          <ProgressIndicator.spinner id="demo-braille-spinner" label="Loading..." />
          
          <ProgressIndicator.spinner id="demo-ascii-spinner" 
                                    style="ascii" 
                                    frames={["/", "-", "\\", "|"]} 
                                    speed={150} 
                                    label="Processing..." />
          
          <ProgressIndicator.spinner id="demo-dots-spinner" 
                                    style="dots" 
                                    label="Fetching data..." />
          
          <ProgressIndicator.spinner id="demo-line-spinner" 
                                    style="line" 
                                    label="Uploading..." />
        </div>
        
        <h4>Circular Progress Indicators</h4>
        <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
          <ProgressIndicator.circular_progress id="demo-small-circle" 
                                              size="small"
                                              value={25} 
                                              max={100} />
          
          <ProgressIndicator.circular_progress id="demo-medium-circle" 
                                              value={50} 
                                              max={100} 
                                              label="Half Complete" />
          
          <ProgressIndicator.circular_progress id="demo-large-circle" 
                                              size="large"
                                              value={75} 
                                              max={100} />
        </div>
      </section>
    </div>
    """
  end

  @doc """
  Mount function for the StyleGuide component.
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  Update function for the StyleGuide component.
  """
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end 