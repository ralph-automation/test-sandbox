// Minimal hash-based router
(function() {
  'use strict';

  // Route definitions
  const routes = {
    '/': () => '<h2>Welcome to Dashboard</h2>',
    '/status': () => '<h2>Status</h2>',
    '/tasks': () => '<h2>Tasks</h2>',
    '/agents': () => '<h2>Agents</h2>'
  };

  // Get current route from hash
  function getCurrentRoute() {
    const hash = window.location.hash.slice(1) || '/';
    return hash;
  }

  // Render the current route
  function render() {
    const route = getCurrentRoute();
    const app = document.getElementById('app');

    if (!app) {
      console.error('Element with id "app" not found');
      return;
    }

    const renderFn = routes[route];

    if (renderFn) {
      app.innerHTML = renderFn();
    } else {
      app.innerHTML = '<h2>404 - Route not found</h2>';
    }
  }

  // Listen for hash changes
  window.addEventListener('hashchange', render);

  // Initialize router on page load
  window.addEventListener('DOMContentLoaded', render);
})();
