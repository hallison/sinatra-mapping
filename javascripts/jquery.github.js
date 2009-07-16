jQuery.githubUser = function(username, callback) {
  jQuery.getJSON("http://github.com/api/v1/json/" + username + "?callback=?", callback);
}

jQuery.githubCommits = function(username, project, branch, callback) {
  jQuery.getJSON("http://github.com/api/v2/json/commits/list/" + username + "/" + project + "/" + branch + "?callback=?", callback);
}

jQuery.githubIssues  = function(username, project, state, callback) {
  jQuery.getJSON("http://github.com/api/v2/json/issues/list/" + username + "/" + project + "/" + state + "?callback=?", callback);
}
