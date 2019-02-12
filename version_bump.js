var v = require('./package.json').version
console.log(v)
const replace = require('replace-in-file');
const regex = new RegExp(/.*/, 'i');
const options = {
    files: 'startpage/_includes/version.html',
    from: regex,
    to: "v" + v,
};

var changes = replace.sync(options)

console.log("chore(release): " + v)
