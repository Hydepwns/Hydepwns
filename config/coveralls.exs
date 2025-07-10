import Config

# Coverage-specific configuration
config :excoveralls,
  coverage_options: [
    minimum_coverage: 70,
    output_dir: "cover",
    template: "excoveralls.html.eex"
  ],
  ignore_modules: [
    HydepwnsLiveview.Utils.LiveViewResource,
    HydepwnsLiveviewWeb.AccessibilityHelper,
    HydepwnsLiveview.Utils.ChangeTracker,
    HydepwnsLiveview.Utils.ContextValidation,
    # Add test support modules
    HydepwnsLiveview.TestSetup,
    HydepwnsLiveviewWeb.WallabyCase,
    # Add any other modules with macro-generated functions
    HydepwnsLiveview.Utils.ValidationEngine,
    HydepwnsLiveview.Utils.ResourceHelpers
  ]
