Seed Generator
==============
This was created using the [Yeoman Angular Generator](https://github.com/yeoman/generator-angular).  The bootstrap files were replaced with [bootstrap-stylus](https://github.com/Acquisio/bootstrap-stylus) and [Angular UI Bootstrap Directives](http://angular-ui.github.io/bootstrap/)

Quick Start
===========
    `npm install -g bower grunt-cli` unless you have them already
    `npm install`
    `bower install`
    `grunt dev`
    `http://localhost:8080`

How to add new angular modules using yeoman
===========================================
Have [Yeoman](http://yeoman.io/) installed globally
Have [Yeoman Angular Generator](https://github.com/yeoman/generator-angular) installed
Follow the directions [here](https://github.com/yeoman/generator-angular) *USING* flags: `--coffee --minsafe`
Note: yeoman generators should not be executed in the root directory but rather within the /client or /server directories.

Global Package Requirements
===========================
* [Node](http://nodejs.org/)
* after node is installed run: `npm install -g bower grunt-cli yo generator-angular`
 * [Bower](http://bower.io/)
 * [Grunt-CLI](http://gruntjs.com/)
 * yo and angular-generator info the Yeoman Section above

License
=========
Influence is licensed under the [Affero General Public License](LICENSE), which is like the GPL but *requires* you provide access to the source code for any modified versions that are running publicly (among other things). The [intent](http://www.gnu.org/licenses/why-affero-gpl.html) is to make sure that anyone improving the software makes those improvements available to others, as we have to them.
