(function () {
  const url = ctx.url;
  const m = url.pathname.match(/\/archives\/([^/]+)\/p(\d+)/);
  if (!m) {
    return;
  }

  url.href =
    'slack://channel?team=YOUR_TEAM_ID&id=' +
    m[1] +
    '&message=' +
    m[2].slice(0, -6) +
    '.' +
    m[2].slice(-6) +
    '&host=slack.com';
})();
