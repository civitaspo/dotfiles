(function () {
  const url = ctx.url;
  const pullRequest = url.pathname.match(/^\/([^/]+)\/([^/]+)\/pull\/(\d+)(?:\/.*)?$/);

  if (url.hostname === 'github.com' && pullRequest) {
    url.href = `linear://review/${pullRequest[1]}/${pullRequest[2]}/pull/${pullRequest[3]}`;
  }
})();
