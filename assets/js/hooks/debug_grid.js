const DebugGrid = {
  mounted() {
    window.toggleDebugGrid = () => {
      const grid = document.getElementById('debug-grid');
      if (grid) {
        grid.style.display = grid.style.display === "none" ? "block" : "none";
      }
    };
  }
};

export default DebugGrid; 