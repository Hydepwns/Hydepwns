(() => {
  // js/app.js
  window.phxLiveViewPids = window.phxLiveViewPids || [];
  window.addEventListener("phx:live_view_pid", (e) => {
    window.phxLiveViewPids.push(e.detail.pid);
  });
})();
